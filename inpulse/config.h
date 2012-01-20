typedef enum {
	kRowToggleEnabled,
	kRowSetTime,
	kRowTroubleshooting,
	kRowNotificationSettings
} kInPulseRows;

typedef enum {
	kTestRowEmail,
	kTestRowSMS,
	kTestRowCalendar,
	kTestRowPhone
} kInPulseTestMessageRows;

typedef enum {
	kStateIdle,
	kStateTroubleshootingTappedWhileDisconnected,
	kStateSetTimeTappedWhileDisconnected,
	kStateSettingTime
} kInPulseTestState;

#define kAppVersion @"1.0"
