#import "InPulseDaemonDelegate.h"
#import "GCDAsyncSocket.h"
#import "config.h"

@implementation InPulseDaemonDelegate

@synthesize listenSocket = _listenSocket;
@synthesize connectedSockets = _connectedSockets;
@synthesize socketQueue = _socketQueue;
@synthesize isRunning = _isRunning;

- (void)dealloc {
	[_listenSocket release];
	[_connectedSockets release];
	[super dealloc];
}

- (id)init {
	if((self = [super init])) {
		// Set up dispatch queue for our server to run on
		_socketQueue = dispatch_queue_create("SocketQueue", NULL);
		_listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_socketQueue];

		// Setup an array to store all accepted client connections
		_connectedSockets = [[NSMutableArray alloc] init];

		_isRunning = NO;
	}
	
	return self;
}

- (void)startServer {
	if(!self.isRunning) {
		int port = kPort;

		NSError *error = nil;
		if(![self.listenSocket acceptOnPort:port error:&error]) {
			NSLog(@"Error starting server %@",error);
			return;
		}
		
		self.isRunning = YES;
		
		dispatch_async(dispatch_get_main_queue(), ^{
			UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Started!" message:@"Server Started :)" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
		    [alert show];
		});
		
	}
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
	// This method is executed on the socketQueue (not the main thread)
	@synchronized(self.connectedSockets)
	{
		[self.connectedSockets addObject:newSocket];
	}
	
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Connected!" message:@"Client Connected :)" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
    [alert show];
}

@end