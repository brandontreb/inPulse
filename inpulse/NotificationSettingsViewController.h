@class INPreferenceManager;

@interface NotificationSettingsViewController:UIViewController<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, retain) UITableView *tableview;
@property(nonatomic, retain) INPreferenceManager *preferenceManager;
@property(nonatomic, assign) BOOL modified;
@end
