#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const kXHSMainAppBundleID;
FOUNDATION_EXPORT NSString * const kXHSKeychainService;
FOUNDATION_EXPORT NSString * const kXHSAccessTokenKey;
FOUNDATION_EXPORT NSString * const kXHSRefreshTokenKey;
FOUNDATION_EXPORT NSString * const kXHSUserIDKey;
FOUNDATION_EXPORT NSString * const kXHSDeviceIDKey;

@interface XHSConstants : NSObject

+ (NSArray<NSString *> *)xhSKeychainServices;
+ (NSArray<NSString *> *)xhSAccessGroups;

@end

NS_ASSUME_NONNULL_END
