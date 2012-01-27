#import "PulseMessageManager.h"
#import "PulseMessage.h"
#import "INPreferenceManager.h"
#import <substrate.h>
#import <AddressBook/AddressBook.h>
#import <btstack/hci_cmds.h>
#import <btstack/BTDevice.h>
#import "inPulseProtocol.h"

// address of watch
bd_addr_t addr = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00};	// inPulse

// For looking up the phone number
typedef struct __CTCall * CTCallRef;
CFStringRef CTCallCopyAddress(CFAllocatorRef alloc, CTCallRef call);
ABRecordRef ABCFindPersonMatchingPhoneNumber(ABAddressBookRef addressBook, NSString *phoneNumber, int identifier, int uid);

@implementation PulseMessageManager

@synthesize bt = _bt;
@synthesize pendingMessage = _pendingMessage;
@synthesize preferenceManager = _preferenceManager;

int store_inpulse_string(char *dest, const char *string){
	int len = strlen(string) + 1;
	*dest++ = len;
	strcpy(dest, string);
	return len+1;
}

- (void) dealloc {
    [_bt release];
	[_pendingMessage release];
	[_preferenceManager release];
	[super dealloc];
}

- (id) init {

	self = [super init];

	if(self) {
        [[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(incomingCall:) 
												     name:@"kCTCallIdentificationChangeNotification" 
												   object:nil];        
        self.bt = [BTstackManager sharedInstance];
        [self.bt setDelegate:self];
        [self.bt addListener:self];

		self.preferenceManager = [[[INPreferenceManager alloc] init] autorelease];
		
	}
	
	return self;
}


-(void)incomingCall:(id)notification{
    //retain the notification to prevent crashes
    [[notification object] retain];
    
    //Get the callref from the notification
    CTCallRef call=(CTCallRef)[notification object];
    
    NSString *number=(NSString *)CTCallCopyAddress(nil,call);
    NSString *callerName=nil;

    if (number){
        ABAddressBookRef ab = ABAddressBookCreate();
        ABRecordRef person=ABCFindPersonMatchingPhoneNumber(ab,number,0,0);
        if (person){
            NSString *firstName= (NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
            NSString *lastName = (NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
            callerName = [[NSString stringWithFormat:@"%@ %@",firstName,lastName] retain];
        }
        CFRelease(ab);
    }


    PulseMessage* message;  
    message = [[[PulseMessage alloc] init] autorelease];
    message.messageType=kMessagePhone;

	if(callerName) {
		message.title = callerName;
	} else {
		message.title = @"Unknown";
	}

    if (!number)
        number=@"Private number";
  
    message.message = number;

    [self newMessageWithMessage: message];
    [[notification object] release];
    //[callerName release];
}


-(void)newMessageWithMessage:(PulseMessage *)pulseMessage {
	
	// Check if btstack is active	
	if(!source_cid) {
		self.pendingMessage = pulseMessage;
        if(![self.bt isActive]) {
		    [self.bt activate];
        } else {
            NSString *address = [self.preferenceManager.preferences objectForKey:@"inpulseWatchAddress"];
            [BTDevice address:&addr fromString:address];	
            bt_send_cmd(&l2cap_create_channel, addr, 0x1001);
        }

		return;
	}
	
	// Check the preferences
	BOOL push = [[self.preferenceManager.preferences objectForKey:@"inpulsePushEnabled"] boolValue];
	BOOL sms = [[self.preferenceManager.preferences objectForKey:@"inpulseSMSEnabled"] boolValue];
	BOOL cal = [[self.preferenceManager.preferences objectForKey:@"inpulseCalendarEnabled"] boolValue];
	BOOL phone = [[self.preferenceManager.preferences objectForKey:@"inpulsePhoneEnabled"] boolValue];

    if(self.preferenceManager.preferences == nil ||
            [self.preferenceManager.preferences count] == 0) {
        push = sms = cal = phone = YES;
    }

	if(pulseMessage.messageType == kMessagePush && !push) {
		return;
	} else if(pulseMessage.messageType == kMessageSMS && !sms) {
		return;
	} else if(pulseMessage.messageType == kMessageCalendar && !cal) {
		return;
	} else if(pulseMessage.messageType == kMessagePhone && !phone) {
		return;
	}
	
	self.pendingMessage = nil;
	
    // TODO: Save pending messages if no connection
	uint8_t buffer[256];
	notification_message_header *message = (notification_message_header*) &buffer;
	message->m_header.endpoint = PP_ENDPOINT_NOTIFICATION;
	message->m_header.header_length = 8;
	message->m_header.time = time(NULL);
	message->notification_type = pulseMessage.messageType;
	message->pp_alert_configuration.on1 = 10;
	message->pp_alert_configuration.type = 1;
	int pos = sizeof(notification_message_header);
	int len;

	const char *sndr = [[pulseMessage title] UTF8String];
	const char *msg = [[pulseMessage message] UTF8String];
	len = store_inpulse_string((char*)&buffer[pos], sndr); pos += len;
	len = store_inpulse_string((char*)&buffer[pos], msg);
	pos += len;
	message->m_header.length = pos;

    bt_send_l2cap( source_cid, (uint8_t*) &buffer, pos);
}

-(void)newMessageWithData:(NSData *)data {
	
	if(!source_cid) {
		[self.bt activate];
		return;
	}
	
	/*uint8_t buffer[256];
	[data getBytes:&buffer length:sizeof(buffer)];	
	bt_send_l2cap( source_cid, (uint8_t*) &buffer, 255);*/
}

#pragma mark - BTStack manager protocol for discovery

-(void) activatedBTstackManager:(BTstackManager*) manager {
	NSString *address = [self.preferenceManager.preferences objectForKey:@"inpulseWatchAddress"];
	[BTDevice address:&addr fromString:address];	
	bt_send_cmd(&l2cap_create_channel, addr, 0x1001);
}
-(void) btstackManager:(BTstackManager*)manager activationFailed:(BTstackError)error {
	//NSLog(@"activationFailed error 0x%02x!", error);
};
-(void) discoveryInquiryBTstackManager:(BTstackManager*) manager {
	//NSLog(@"discoveryInquiry!");
}
-(void) discoveryStoppedBTstackManager:(BTstackManager*) manager {
	//NSLog(@"discoveryStopped!");
}
-(void) btstackManager:(BTstackManager*)manager discoveryQueryRemoteName:(int)deviceIndex {
	//NSLog(@"discoveryQueryRemoteName %u/%u!", deviceIndex+1, [self.bt numberOfDevicesFound]);
}

/**
 * BTStack's main run loop
 */
-(void) btstackManager:(BTstackManager*) manager
  handlePacketWithType:(uint8_t) packet_type
			forChannel:(uint16_t) channel
			   andData:(uint8_t *)packet
			   withLen:(uint16_t) size
{
	bd_addr_t event_addr;
	
	switch (packet_type) {			
		case L2CAP_DATA_PACKET:			
			break;			
		case HCI_EVENT_PACKET:

			switch (packet[0]){
				case L2CAP_EVENT_CHANNEL_OPENED:
					// inform about new l2cap connection
					bt_flip_addr(event_addr, &packet[3]);
					//uint16_t psm = READ_BT_16(packet, 11); 
					source_cid = READ_BT_16(packet, 13); 
					con_handle = READ_BT_16(packet, 9);
	
					if (packet[2] == 0) {							
						// TODO: Connection Established
						if(self.pendingMessage) {
							[self newMessageWithMessage:self.pendingMessage];
						}
					} else {
						// TODO: Failed Connection
					}
					break;
				case L2CAP_EVENT_CHANNEL_CLOSED:
					// TODO: Disconnect Notice
					break;
				case L2CAP_EVENT_CREDITS:
					// Confirms event					
					break; 
				case L2CAP_EVENT_TIMEOUT_CHECK: 
				{
					// heartbeat
					source_cid = READ_BT_16(packet, 13); 
					con_handle = READ_BT_16(packet, 9);
                    if(source_cid > 1000) {
                        source_cid = 0;   
                    }
					break;
				}
				default: 					
					break;
			}
			break;
			
		default:
			break;
	}	
}

@end
