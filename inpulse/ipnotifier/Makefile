include theos/makefiles/common.mk

TWEAK_NAME = IPNotifier
IPNotifier_FILES = Tweak.xm ../PulseMessage.m PulseMessageManager.m ../BTstackManager.m ../BTDevice.m ../INPreferenceManager.m
IPNotifier_CFLAGS = -I../ -I../include
IPNotifier_LDFLAGS = -lBTstack
IPNotifier_FRAMEWORKS = UIKit AddressBook CoreTelephony CFNetwork

include $(THEOS_MAKE_PATH)/tweak.mk
