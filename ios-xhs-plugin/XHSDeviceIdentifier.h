#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XHSDeviceIdentifier : NSObject

+ (instancetype)sharedManager;

- (NSString *)generateNewUUID;
- (BOOL)changeDeviceIdentifier;
- (BOOL)changeToCustomIdentifier:(NSString *)customId;
- (NSString *)currentDeviceIdentifier;
- (NSArray<NSString *> *)findDeviceIdentifiersInKeychain;

@end

NS_ASSUME_NONNULL_END
