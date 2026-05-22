include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = XHSPluginPrefs

XHSPluginPrefs_FILES = XXXRootListController.m
XHSPluginPrefs_FRAMEWORKS = UIKit
XHSPluginPrefs_PRIVATE_FRAMEWORKS = Preferences
XHSPluginPrefs_INSTALL_PATH = /Library/PreferenceBundles
XHSPluginPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
