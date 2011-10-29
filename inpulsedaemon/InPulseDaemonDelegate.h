
@class GCDAsyncSocket;

@interface InPulseDaemonDelegate:NSObject

@property(nonatomic, retain) GCDAsyncSocket *listenSocket;
@property(nonatomic, retain) NSMutableArray *connectedSockets;
@property(nonatomic, assign) dispatch_queue_t socketQueue;
@property(nonatomic, assign) BOOL isRunning;

- (void)startServer;

@end