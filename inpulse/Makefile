include theos/makefiles/common.mk

APPLICATION_NAME = inPulse
inPulse_FILES = main.m inPulseApplication.mm RootViewController.mm INPreferenceManager.m BTDevice.m BTstackManager.m TroubleshootingViewController.m INAlertData.m SVProgressHUD.m

inPulse_CFLAGS = -Iinclude
inPulse_LDFLAGS = -lBTstack
inPulse_FRAMEWORKS = QuartzCore CoreGraphics

include $(THEOS_MAKE_PATH)/application.mk

SUBPROJECTS = ipnotifier settings
include $(FW_MAKEDIR)/aggregate.mk
