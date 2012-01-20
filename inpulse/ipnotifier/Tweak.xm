#import <SpringBoard/SpringBoard.h>
#import <BulletinBoard/BBBulletin.h>
#import "PulseMessage.h"
#import "PulseMessageManager.h"

NSString *seenBulletinID;
PulseMessageManager *manager;

%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)notification{ 
    %orig;
    manager = [[PulseMessageManager alloc] init];
}

%end;

static PulseMessage* managerMessageFromBulletin(BBBulletin * bulletin){
	if (seenBulletinID){
		[seenBulletinID release];
	}
	seenBulletinID=[bulletin bulletinID];
	[seenBulletinID retain];
	PulseMessage *message = [[PulseMessage alloc] init] ;
	message.title = [[bulletin content] title];
	message.message = [[bulletin content] message] ;
	if ([[bulletin sectionID] isEqual:@"com.apple.MobileSMS"]){
		message.messageType=kMessageSMS;
	}	
	else if ([[bulletin sectionID] isEqual:@"com.apple.mobilephone"]){
		message.messageType=kMessagePhone;
	}	
	else if ([[bulletin sectionID] isEqual:@"com.apple.mobilecal"]){
		message.messageType=kMessageCalendar;
	}
	else{
		message.messageType=kMessagePush;
	}
	return message;
}


%group iOS5Hooks
%hook SBBulletinBannerController
-(void)observer:(id)observer addBulletin:(id)bulletin forFeed:(unsigned)feed{
	if (![seenBulletinID isEqual:[bulletin bulletinID]]){
		PulseMessage *message = [managerMessageFromBulletin(bulletin) autorelease];
		[manager newMessageWithMessage:message];
	}
	%orig;
}
%end
%hook SBBulletinModalController
-(void)observer:(id)observer addBulletin:(id)bulletin forFeed:(unsigned)feed{
	if (![seenBulletinID isEqual:[bulletin bulletinID]]){
		PulseMessage *message = [managerMessageFromBulletin(bulletin) autorelease];
		[manager newMessageWithMessage:message]; 
	}
	%orig;
}
%end
%hook SBAwayBulletinListController
-(void)observer:(id)observer addBulletin:(id)bulletin forFeed:(unsigned)feed{
	if (![seenBulletinID isEqual:[bulletin bulletinID]]){
		PulseMessage *message = [managerMessageFromBulletin(bulletin) autorelease];
		[manager newMessageWithMessage:message];
	}
	%orig;
}
%end
%hook SBAlertItemsController
-(void)observer:(id)observer addBulletin:(id)bulletin forFeed:(unsigned)feed{
	if (![seenBulletinID isEqual:[bulletin bulletinID]]){
		PulseMessage *message = [managerMessageFromBulletin(bulletin) autorelease];
		[manager newMessageWithMessage:message];
	}
	%orig;
}
%end
%end
//iOS5 GROUPS END

%ctor
{
	%init; // init all hooks outside groups
	
    %init(iOS5Hooks);
	//Register for the preferences-did-change notification
//	CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
//	CFNotificationCenterAddObserver(r, NULL, &reloadPrefsNotification, CFSTR("com.brandontreb.inpulsenotifier/reloadPrefs"), NULL, 0);
}

