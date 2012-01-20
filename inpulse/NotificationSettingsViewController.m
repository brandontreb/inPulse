#import "NotificationSettingsViewController.h"
#import "INPreferenceManager.h"
#import "config.h"
#import <Foundation/NSTask.h>

@implementation NotificationSettingsViewController

@synthesize tableview = _tableview;
@synthesize preferenceManager = _preferenceManager;
@synthesize modified = _modified;

- (void)dealloc {
    [_tableview release];
    [_preferenceManager release];
    [super dealloc];
}

- (id)init {
    if((self = [super init])) {  
        _tableview = [[UITableView alloc] init];
        _tableview.frame = self.view.bounds;
        _tableview.delegate = self;
        _tableview.dataSource = self;
        [self.view addSubview:_tableview];
        self.title = @"Notification Settings";
	    self.preferenceManager = [[[INPreferenceManager alloc] init] autorelease];
	
		if(!self.preferenceManager.preferences || [self.preferenceManager.preferences count] == 0) {
			UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Preferences not initialized." 
			                                                    message:@"Please visit the inpulse settings in Settings.app to use this feature." 
			                                                   delegate:nil 
			                                          cancelButtonTitle:@"OK" 
			                                           otherButtonTitles:nil] autorelease];
		    [alert show];
		}
	
    }
    return self;
}

- (void) viewWillDisappear:(BOOL)animated {
	if(self.modified) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Restart Springboard" 
		                                                    message:@"You must restart springboard for changes to take effect." 
		                                                   delegate:nil 
		                                          cancelButtonTitle:@"OK" 
		                                           otherButtonTitles:nil] autorelease];
	    [alert show];
		self.modified = NO;
	}
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"Cell %d", indexPath.row];
     
	switch(indexPath.row) {
		case kTestRowEmail: {	
            BOOL on = [[self.preferenceManager.preferences objectForKey:@"inpulsePushEnabled"] boolValue];
            cell.detailTextLabel.text = on ? @"On" : @"Off";
			cell.textLabel.text = @"Push/Local Notifications";
			cell.imageView.image = [UIImage imageNamed:@"GMail.png"];
			break;
		}
		case kTestRowSMS: {	
            BOOL on = [[self.preferenceManager.preferences objectForKey:@"inpulseSMSEnabled"] boolValue];
            cell.detailTextLabel.text = on ? @"On" : @"Off";
			cell.textLabel.text = @"SMS";
			cell.imageView.image = [UIImage imageNamed:@"SMSD.png"];
			break;
		}
		case kTestRowCalendar: {	
            BOOL on = [[self.preferenceManager.preferences objectForKey:@"inpulseCalendarEnabled"] boolValue];
            cell.detailTextLabel.text = on ? @"On" : @"Off";
			cell.textLabel.text = @"Calendar";
			cell.imageView.image = [UIImage imageNamed:@"Calendar.png"];
			break;
		}
		case kTestRowPhone: {	
            BOOL on = [[self.preferenceManager.preferences objectForKey:@"inpulsePhoneEnabled"] boolValue];
            cell.detailTextLabel.text = on ? @"On" : @"Off";
			cell.textLabel.text = @"Phone";
			cell.imageView.image = [UIImage imageNamed:@"Phone.png"];
			break;
		}
    }

    return cell;
}

#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath { 
	self.modified = YES;
	switch(indexPath.row) {
		case kTestRowEmail: {	
            BOOL on = [[self.preferenceManager.preferences objectForKey:@"inpulsePushEnabled"] boolValue];
            [self.preferenceManager.preferences setObject:[NSNumber numberWithBool:!on] forKey:@"inpulsePushEnabled"];
            [self.preferenceManager save];
            break;
		}
		case kTestRowSMS: {	
            BOOL on = [[self.preferenceManager.preferences objectForKey:@"inpulseSMSEnabled"] boolValue];
            [self.preferenceManager.preferences setObject:[NSNumber numberWithBool:!on] forKey:@"inpulseSMSEnabled"];
            [self.preferenceManager save];
			break;
		}
		case kTestRowCalendar: {	
            BOOL on = [[self.preferenceManager.preferences objectForKey:@"inpulseCalendarEnabled"] boolValue];
            [self.preferenceManager.preferences setObject:[NSNumber numberWithBool:!on] forKey:@"inpulseCalendarEnabled"];
            [self.preferenceManager save];
			break;
		}
		case kTestRowPhone: {	
            BOOL on = [[self.preferenceManager.preferences objectForKey:@"inpulsePhoneEnabled"] boolValue];
            [self.preferenceManager.preferences setObject:[NSNumber numberWithBool:!on] forKey:@"inpulsePhoneEnabled"];
            [self.preferenceManager save];
			break;
		}
    }
    [self.tableview reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66.0;
}

@end
