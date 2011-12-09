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
	printf("Starting server...\n");
	if(!self.isRunning) {
		int port = kPort;

		NSError *error = nil;
		if(![self.listenSocket acceptOnPort:port error:&error]) {
			printf("Error starting server");
			return;
		} else {
			printf("Listening on port %i\n",port);
		}
		
		self.isRunning = YES;
	}
}

#pragma mark - GCDAsyncSocket Delegate methods

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
	// This method is executed on the socketQueue (not the main thread)
	@synchronized(self.connectedSockets)
	{
		[self.connectedSockets addObject:newSocket];
	}
	
	printf("Client connected...\n");
	
    NSString *welcomeMsg = @"Welcome to the AsyncSocket Echo Server\r\n";
	NSData *welcomeData = [welcomeMsg dataUsingEncoding:NSUTF8StringEncoding];
	[newSocket writeData:welcomeData withTimeout:-1 tag:1];

	[newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:kReadTimeout tag:0];

}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:kReadTimeout tag:0];
    
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{	

    NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
    NSString *msg = [[[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding] autorelease];
    if (msg)
    {
        printf("Received: %s\n",[msg UTF8String]);
    }
    else
    {
        printf("Error receiving data...\n");
    }
}


- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	if (sock != self.listenSocket)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			
			printf("Client Disconnected");
			
			[pool release];
		});
		
		@synchronized(self.connectedSockets)
		{
			[self.connectedSockets removeObject:sock];
		}
	}
}

@end
