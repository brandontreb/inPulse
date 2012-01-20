#define kNewAlertForeground 0
#define kNewAlertBackground 1
#define kOldAlert 2

typedef enum {
	kMessagePush = 0,
	kMessageSMS = 1,
	kMessagePhone = 3,
	kMessageCalendar = 5,
	kMessageGeneric = 8
} PulseMessageType;

@interface PulseMessage:NSObject<NSCoding>
@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *message;
@property(nonatomic,assign) PulseMessageType messageType;
@end
