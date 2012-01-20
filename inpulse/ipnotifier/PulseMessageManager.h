#import <btstack/btstack.h>
#import <btstack/utils.h>
#import <btstack/BTstackManager.h>

#define kPort 1337
#define kReadTimeout 15.0

@class INPreferenceManager;
@class PulseMessage;
@class GCDAsyncSocket;

@interface PulseMessageManager: NSObject<BTstackManagerListener,BTstackManagerDelegate> 
@property(nonatomic, retain) BTstackManager *bt;
@property(nonatomic, retain) PulseMessage *pendingMessage;
@property(nonatomic, retain) INPreferenceManager *preferenceManager;
@property(nonatomic, retain) NSTimer *timeoutTimer;
// Socket Stuff
@property(nonatomic, retain) GCDAsyncSocket *listenSocket;
@property(nonatomic, retain) NSMutableArray *connectedSockets;
@property(nonatomic, assign) dispatch_queue_t socketQueue;

- (void)newMessageWithMessage:(PulseMessage *)pulseMessage;
- (void)newMessageWithData:(NSData *)data;
- (void)startServer;
@end
