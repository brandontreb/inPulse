#import "INPreferenceManager.h"

@implementation INPreferenceManager

@synthesize preferences = _preferences;

-(id)init
{
	self = [super init];
	if(self)
	{
		_preferences = [[NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.brandontreb.inpulsenotifiersettings.plist"] retain];
	}
	return self;
}

- (void) save {
	[_preferences writeToFile:@"/var/mobile/Library/Preferences/com.brandontreb.inpulsenotifiersettings.plist" atomically:YES];
}

-(void)reloadPreferences
{
	if(_preferences) {
		[_preferences release];
	}
	_preferences = [[NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.brandontreb.inpulsenotifiersettings.plist"] retain];
}

- (void) dealloc {
	[_preferences release];
	[super dealloc];
}

@end