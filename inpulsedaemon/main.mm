#import "InPulseDaemonDelegate.h"

int main(int argc, char **argv, char **envp) {
	
	//start a pool
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	InPulseDaemonDelegate *delegate = [[InPulseDaemonDelegate alloc] init];
	[delegate startServer];
	
	[pool release];
	
	return 0;
}

// vim:ft=objc
