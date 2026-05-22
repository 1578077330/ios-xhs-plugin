TARGET := iphone:clang:latest:13.0
INSTALL_TARGET_PROCESSES = Xiaohongshu

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = XHSPlugin

XHSPlugin_FILES = Tweak.xm XHSKeychainCleaner.m XHSConstants.m XHSCleanerHelper.m XHSDeviceIdentifier.m
XHSPlugin_CFLAGS = -fobjc-arc
XHSPlugin_FRAMEWORKS = Security Foundation UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
