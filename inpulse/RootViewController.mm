#import "RootViewController.h"
#import "config.h"

@implementation RootViewController

@synthesize tableview = _tableview;

- (void) dealloc {
	[_tableview release]; 
	[super dealloc];
}

- (void)loadView {
	self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
	self.tableview = [[[UITableView alloc] initWithFrame:self.view.bounds] autorelease] ;
	self.tableview.delegate = self;
	self.tableview.dataSource = self;
	self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableview setScrollEnabled:NO];
	[self.view addSubview:self.tableview];
}

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    switch(indexPath.row) {
	case kRowTroubleshooting:
		cell.textLabel.text = @"Troubleshooting";
		break;
    }
    
    return cell;
}

#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch(indexPath.row) {
    case kRowTroubleshooting:
        break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view =  [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0,0,320,22)] autorelease];
    label.text = [NSString stringWithFormat:@" inPulse %@",kAppVersion];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14];
    label.backgroundColor = [UIColor grayColor];
    label.shadowOffset = CGSizeMake(1,1);
    label.shadowColor = [UIColor darkGrayColor];
    [view addSubview:label];
    return view;
}


@end
