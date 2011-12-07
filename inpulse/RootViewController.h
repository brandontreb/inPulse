#import <BTstack/BTstackManager.h>
#import "config.h"

@class INPreferenceManager;

@interface RootViewController: UIViewController<UITableViewDelegate, UITableViewDataSource, BTstackManagerListener, BTstackManagerDelegate> 

@property(nonatomic, retain) UITableView *tableview;
@property(nonatomic, retain) INPreferenceManager *preferenceManager;
@property(nonatomic, retain) BTstackManager *bt;
@property(nonatomic, assign) BOOL enabled;
@property(nonatomic, assign) kInPulseTestState state;

- (void) setTime;

@end
