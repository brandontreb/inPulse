#import <btstack/btstack.h>
#import <btstack/utils.h>
#import <btstack/BTstackManager.h>

#define kPort 1337
#define kReadTimeout 15.0

@class INPreferenceManager;
@class PulseMessage;

@interface PulseMessageManager: NSObject<BTstackManagerListener,BTstackManagerDelegate> 
@property(nonatomic, retain) BTstackManager *bt;
@property(nonatomic, retain) PulseMessage *pendingMessage;
@property(nonatomic, retain) INPreferenceManager *preferenceManager;
@property(nonatomic, retain) NSTimer *timeoutTimer;

- (void)newMessageWithMessage:(PulseMessage *)pulseMessage;
- (void)newMessageWithData:(NSData *)data;
@end
