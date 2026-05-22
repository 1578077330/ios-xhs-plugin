#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XHSKeychainCleaner : NSObject

+ (instancetype)sharedCleaner;

- (BOOL)cleanAllKeychainItems;
- (BOOL)cleanKeychainItemsForService:(NSString *)service;
- (BOOL)cleanKeychainItemsForAccessGroup:(NSString *)accessGroup;
- (NSArray<NSDictionary *> *)queryAllKeychainItems;

@end

NS_ASSUME_NONNULL_END
