#import <BTstack/BTstackManager.h>
#import "inPulseProtocol.h"

@interface TroubleshootingViewController : UIViewController<BTstackManagerListener,UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, retain) UITableView *tableview;
@property(nonatomic, retain) BTstackManager *bt;

- (id)initWithSourceCID:(uint16_t)cid;

@end