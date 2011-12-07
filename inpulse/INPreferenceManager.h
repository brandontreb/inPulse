@interface INPreferenceManager : NSObject

- (void)reloadPreferences;
- (void)save;

@property (nonatomic,retain) NSMutableDictionary* preferences;

@end