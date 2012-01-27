#import "RootViewController.h"
#import "INPreferenceManager.h"
#import "TroubleshootingViewController.h"
#import "NotificationSettingsViewController.h"
#import "SVProgressHUD.h"

#import <BTstack/BTDiscoveryViewController.h>
#import <btstack/hci_cmds.h>
#import <btstack/BTDevice.h>

#import "inPulseProtocol.h"

bd_addr_t addr = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00};	// inPulse

@interface RootViewController(Private)
- (void) connect:(id) sender;
@end

@implementation RootViewController

@synthesize tableview = _tableview;
@synthesize enabled = _enabled;
@synthesize preferenceManager = _preferenceManager;
@synthesize bt = _bt;
@synthesize state = _state;
@synthesize timeoutTimer = _timeoutTimer;

- (void) dealloc {
	[_tableview release]; 
	[_preferenceManager release];
	[_bt release];
	[_timeoutTimer release];
	[super dealloc];
}

- (void)loadView {
	self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
	self.tableview = [[[UITableView alloc] initWithFrame:self.view.bounds] autorelease] ;
	self.tableview.delegate = self;
	self.tableview.dataSource = self;
    [self.tableview setScrollEnabled:NO];
	[self.view addSubview:self.tableview];
	
	self.preferenceManager = [[[INPreferenceManager alloc] init] autorelease];
	self.enabled = [self.preferenceManager.preferences valueForKey:@"inpulseEnabled"]  ? 
					[[self.preferenceManager.preferences valueForKey:@"inpulseEnabled"] boolValue] : YES;
					
	self.bt = [BTstackManager sharedInstance];
	[self.bt setDelegate:self];
	[self.bt addListener:self];

    UIBarButtonItem *connect = [[[UIBarButtonItem alloc] initWithTitle:@"Connect" 
                                                                 style:UIBarButtonItemStylePlain 
                                                                target:self 
                                                                action:@selector(connect:)] autorelease];
    self.navigationItem.rightBarButtonItem = connect;

	/*UIBarButtonItem *disconnect = [[[UIBarButtonItem alloc] initWithTitle:@"Disconnect" 
                                                                 style:UIBarButtonItemStylePlain 
                                                                target:self 
                                                                action:@selector(disconnect:)] autorelease];
    self.navigationItem.leftBarButtonItem = disconnect;*/

    self.title = @"inPulse";
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
    
	cell.accessoryType =  UITableViewCellAccessoryNone;

    switch(indexPath.row) {
		case kRowToggleEnabled: {
			NSString *enabledString = self.enabled ? @"on" : @"off";			
			cell.textLabel.text = [NSString stringWithFormat:@"Toggle Notifications to Watch (%@)",enabledString];
			cell.textLabel.numberOfLines = 2;
			cell.imageView.image = [UIImage imageNamed:@"Respring.png"];
			break;
		}
		case kRowSetTime:		
			cell.textLabel.text = @"Synchronize Watch Time";
			cell.imageView.image = [UIImage imageNamed:@"Clock.png"];
			break;
		case kRowNotificationSettings:
			cell.textLabel.text = @"Notification Settings";
			cell.imageView.image = [UIImage imageNamed:@"SMSD.png"];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		case kRowTroubleshooting:
			cell.textLabel.text = @"Troubleshooting";
			cell.imageView.image = [UIImage imageNamed:@"Settings.png"];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
    }
    
    return cell;
}

#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch(indexPath.row) {
    	case kRowToggleEnabled: {
			self.enabled = !self.enabled;
			[self.preferenceManager.preferences setObject:[NSNumber numberWithBool:self.enabled] forKey:@"inpulseEnabled"];
			[self.preferenceManager save];
			[self.tableview reloadData];
			break;
		}
		case kRowSetTime: {
			[self setTime];
			break;
		}
		case kRowTroubleshooting: {			
			
			if(source_cid) {						
				TroubleshootingViewController *controller = [[TroubleshootingViewController alloc] initWithSourceCID:source_cid];
				[self.navigationController pushViewController:controller animated:YES];
				[controller release];
			} else {
				self.state = kStateTroubleshootingTappedWhileDisconnected;
				[self connect:self];
			}
			break;
		}
        case kRowNotificationSettings:
            NotificationSettingsViewController * controller = [[NotificationSettingsViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
            [controller release];
            break;
    }

	[[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 22.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view =  [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 22)] autorelease];
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0,0,320,22)] autorelease];
    label.text = [NSString stringWithFormat:@" inPulse %@",kAppVersion];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14];
    view.backgroundColor = [UIColor grayColor];
	label.backgroundColor = [UIColor clearColor];
    label.shadowOffset = CGSizeMake(1,1);
    label.shadowColor = [UIColor darkGrayColor];
    [view addSubview:label];
    return view;
}

#pragma mark - Actions

- (void) connect:(id) sender {	
	BTstackError err = [self.bt activate];
	if (err) NSLog(@"activate err 0x%02x!", err);
	
	self.timeoutTimer = [NSTimer timerWithTimeInterval:5
												target:self 
											  selector:@selector(timeout:) 
											  userInfo:nil 
											   repeats:NO];
	
	[SVProgressHUD showWithStatus:@"Connecting to inPulse..." maskType:SVProgressHUDMaskTypeClear];
}

- (void) disconnect:(id) sender {
	if(source_cid) {
		bt_send_cmd(&l2cap_disconnect,source_cid,0x1001);
		[SVProgressHUD showWithStatus:@"Disconnecting from inPulse..." maskType:SVProgressHUDMaskTypeClear];
	}
}

- (void) setTime {
	
	self.state = kStateSettingTime;	

	self.timeoutTimer = [NSTimer timerWithTimeInterval:10
												target:self 
											  selector:@selector(timeout:) 
											  userInfo:nil 
											   repeats:NO];

	// If there is no connection, connect first
	if(!source_cid) {
		self.state = kStateSetTimeTappedWhileDisconnected;
		[self connect:self];
		return;
	}
	
	[SVProgressHUD showWithStatus:@"Synchronizing Time..." maskType:SVProgressHUDMaskTypeClear];

	struct timecmd {
		command_query_header cmd;
		struct tm ts;
	} __attribute__((packed)) timecmd;

	time_t now;
	struct tm *ts;

	now = time(NULL);
	ts = localtime(&now);
	memcpy(&timecmd.ts, ts, sizeof(struct tm));

	timecmd.cmd.m_header.endpoint = PP_ENDPOINT_COMMAND;
	timecmd.cmd.m_header.header_length = sizeof(timecmd.cmd.m_header);
	timecmd.cmd.m_header.length = sizeof(timecmd);
	timecmd.cmd.command = command_set_time;
	timecmd.cmd.parameter1 = now;
	timecmd.cmd.parameter2 = +1;

    bt_send_l2cap( source_cid, (uint8_t*) &timecmd, 50);
}

- (void) timeout:(id) sender {
	[SVProgressHUD dismissWithError:@"Connection Failed"];
	source_cid = 0;
}

#pragma mark - BTStack manager protocol for discovery

-(void) activatedBTstackManager:(BTstackManager*) manager {
	[self.bt startDiscovery];
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

// Counter used to determine if watch isn't available
static int attempts = 0;

/**
 * This method gets called whenever BTStack has found a new device.  When
 * we encounter a device containing the name "inPulse", we assume that it's
 * the watch and connect to it.
 */
-(void) btstackManager:(BTstackManager*)manager deviceInfo:(BTDevice*)device {
	
	NSString *deviceName = [device name];

	if(deviceName && [deviceName rangeOfString:@"inPulse"].length > 0) {
		[self.bt stopDiscovery];
		NSString *address = [device addressString];
		[self.preferenceManager.preferences setObject:address forKey:@"inpulseWatchAddress"];
		[self.preferenceManager save];		
		attempts = 0;
		
		// Connect to the watch
		[BTDevice address:&addr fromString:address];	
		bt_send_cmd(&l2cap_create_channel, addr, 0x1001);
	}
	
	attempts++;
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
		{
			switch (packet[0]){
				case L2CAP_EVENT_CHANNEL_OPENED: 
				{
					// inform about new l2cap connection
					bt_flip_addr(event_addr, &packet[3]);
					//uint16_t psm = READ_BT_16(packet, 11); 
					source_cid = READ_BT_16(packet, 13); 
					con_handle = READ_BT_16(packet, 9);
					
					if (packet[2] == 0) {							
						[SVProgressHUD dismissWithSuccess:@"Connection established."];
						
						if(self.timeoutTimer) {
							[self.timeoutTimer invalidate];
							self.timeoutTimer = nil;
						}
						
						// If we were connecting because of troubleshooting
						if(self.state == kStateTroubleshootingTappedWhileDisconnected) {
							self.state = kStateIdle;
							NSIndexPath *indexPath = [NSIndexPath indexPathForRow:kRowTroubleshooting inSection:0];
							[self tableView:self.tableview didSelectRowAtIndexPath:indexPath];
						} else if(self.state == kStateSetTimeTappedWhileDisconnected) {
							self.state = kStateIdle;
							NSIndexPath *indexPath = [NSIndexPath indexPathForRow:kRowSetTime inSection:0];
							[self tableView:self.tableview didSelectRowAtIndexPath:indexPath];
						}
					} else {
						// TODO: Failed Connection
						[SVProgressHUD dismissWithError:@"Connection failure."];
					}
					break;
				}	
				case L2CAP_EVENT_CHANNEL_CLOSED:
					// TODO: Disconnect Notice
					[SVProgressHUD dismissWithSuccess:@"Disconnected."];
					break;
				case L2CAP_EVENT_CREDITS:
				{												
					// Confirms event
					if(self.state == kStateSettingTime) {
						
						if(self.timeoutTimer) {
							[self.timeoutTimer invalidate];
							self.timeoutTimer = nil;
						}
						
						[SVProgressHUD dismissWithSuccess:@"Time Synchronized."];
                        self.state = kStateIdle;
						break;
					}
					break; 
				}
				case L2CAP_EVENT_TIMEOUT_CHECK: 
				{
					// heartbeat
					source_cid = READ_BT_16(packet, 13); 
					con_handle = READ_BT_16(packet, 9);					
					break;
				}
				default: {
						
					break;
				}
			}
			break;
		}
		default:
			break;
	}	
}

@end
