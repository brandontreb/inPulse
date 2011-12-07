#import "RootViewController.h"

@interface inPulseApplication: UIApplication <UIApplicationDelegate> {
	UIWindow *_window;
	RootViewController *_viewController;
	UINavigationController *_navController;
}
@property (nonatomic, retain) UIWindow *window;
@end

@implementation inPulseApplication
@synthesize window = _window;
- (void)applicationDidFinishLaunching:(UIApplication *)application {
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	_viewController = [[RootViewController alloc] init];
	
	_navController = [[UINavigationController alloc] initWithRootViewController:_viewController];
	
	[_window addSubview:_navController.view];
	[_window makeKeyAndVisible];
}

- (void)dealloc {
	[_window release];
	[super dealloc];
}
@end

// vim:ft=objc
