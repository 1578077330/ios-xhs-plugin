#import "XHSConstants.h"

NSString * const kXHSMainAppBundleID = @"com.xingin.xhs";
NSString * const kXHSKeychainService = @"com.xiaohongshu.keychain";
NSString * const kXHSAccessTokenKey = @"xhs_access_token";
NSString * const kXHSRefreshTokenKey = @"xhs_refresh_token";
NSString * const kXHSUserIDKey = @"xhs_user_id";
NSString * const kXHSDeviceIDKey = @"xhs_device_id";

@implementation XHSConstants

+ (NSArray<NSString *> *)xhSKeychainServices {
    return @[
        @"com.xingin.xhs",
        @"com.xingin.xhs.keychain",
        @"com.xiaohongshu",
        @"com.xiaohongshu.keychain",
        @"XHSKeychainService",
        @"Xiaohongshu"
    ];
}

+ (NSArray<NSString *> *)xhSAccessGroups {
    return @[
        @"com.xingin.xhs.*",
        @"com.xiaohongshu.*"
    ];
}

@end
