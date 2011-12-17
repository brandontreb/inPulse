#import "TroubleshootingViewController.h"
#import "PulseMessage.h"
#import "SVProgressHUD.h"
#import "config.h"

@interface TroubleshootingViewController(Private)
- (void)sendTestMessageOfType:(PulseMessageType) type title:(NSString *) title message:(NSString *) message;
- (void)newAlertWithData:(PulseMessage *)data;
@end

int store_inpulse_string(char *dest, const char *string){
	int len = strlen(string) + 1;
	*dest++ = len;
	strcpy(dest, string);
	return len+1;
}

@implementation TroubleshootingViewController

@synthesize tableview = _tableview;
@synthesize bt = _bt;

- (void)dealloc {
	[_tableview release];
	[_bt removeListener:self];
	[_bt release];
	[super dealloc];
}

- (id)initWithSourceCID:(uint16_t)cid {
	if((self = [super init])) {
		
		// localize these so we can interact with the watch
		source_cid = cid;
		
		self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
		self.tableview = [[[UITableView alloc] initWithFrame:self.view.bounds] autorelease] ;
		self.tableview.delegate = self;
		self.tableview.dataSource = self;
	    [self.tableview setScrollEnabled:NO];
		[self.view addSubview:self.tableview];
		
		self.bt = [BTstackManager sharedInstance];
		[self.bt addListener:self];
		
		self.title = @"Troubleshooting";
	}
	
	return self;
}

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
	switch(indexPath.row) {
		case kTestRowEmail: {	
			cell.textLabel.text = @"Send Test Push";
			cell.imageView.image = [UIImage imageNamed:@"GMail.png"];
			break;
		}
		case kTestRowSMS: {	
			cell.textLabel.text = @"Send Test SMS";
			cell.imageView.image = [UIImage imageNamed:@"SMSD.png"];
			break;
		}
		case kTestRowCalendar: {	
			cell.textLabel.text = @"Send Test Calendar Alert";
			cell.imageView.image = [UIImage imageNamed:@"Calendar.png"];
			break;
		}
		case kTestRowPhone: {	
			cell.textLabel.text = @"Send Test Phone Call";
			cell.imageView.image = [UIImage imageNamed:@"Phone.png"];
			break;
		}
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66.0;
}

#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch(indexPath.row) {
		case kTestRowEmail: {	
			NSString *title = @"brandontreb";
			NSString *message = @"Hey there,\n\nThanks for checking out the inPulse app for iOS.\n-Brandon";
			[self sendTestMessageOfType:kMessagePush title:title message:message];			
			break;
		}
		case kTestRowSMS: {	
			NSString *title = @"Eddard Stark";
			NSString *message = @"Winter is coming!";
			[self sendTestMessageOfType:kMessageSMS title:title message:message];			
			break;
		}
		case kTestRowCalendar: {	
			NSString *title = @"Conf Room B";
			NSString *message = @"Meeting with the Bobs";
			[self sendTestMessageOfType:kMessageCalendar title:title message:message];
			break;
		}
		case kTestRowPhone: {	
			NSString *title = @"Mom";
			NSString *message = @"867-5309";
			[self sendTestMessageOfType:kMessagePhone title:title message:message];			
			break;
		}
    }
}

#pragma mark - BTStack

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
						// TODO: Connection notice
					} else {
						// TODO: Failed Connection
					}
					break;
				case L2CAP_EVENT_CHANNEL_CLOSED:
					// TODO: Disconnect Notice
					break;
				default:
					break;
			}
			break;
			
		default:
			break;
	}	
}

#pragma mark - Actions

- (void) sendTestMessageOfType:(PulseMessageType) type title:(NSString *) title message:(NSString *) message {
	PulseMessage *data = [[[PulseMessage alloc] init] autorelease];
    data.messageType = type;
	data.title = title;
	data.message = message;
	[self newAlertWithData:data];
}

-(void)newAlertWithData:(PulseMessage *)data {	
	uint8_t buffer[256];
	notification_message_header * message = (notification_message_header*) &buffer;
	message->m_header.endpoint = PP_ENDPOINT_NOTIFICATION;
	message->m_header.header_length = 8;
	message->m_header.time = time(NULL);
	message->notification_type = data.messageType;
	message->pp_alert_configuration.on1 = 10;
	message->pp_alert_configuration.type = 1;
	int pos = sizeof(notification_message_header);
	int len;

	const char *sndr = [[data title] UTF8String];
	const char *msg = [[data message] UTF8String];
	len = store_inpulse_string((char*)&buffer[pos], sndr); pos += len;
	len = store_inpulse_string((char*)&buffer[pos], msg);
	pos += len;
	message->m_header.length = pos;

    bt_send_l2cap( source_cid, (uint8_t*) &buffer, pos);
}

@end