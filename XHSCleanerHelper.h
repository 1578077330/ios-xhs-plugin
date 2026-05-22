#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XHSCleanerHelper : NSObject

+ (instancetype)sharedHelper;

- (BOOL)cleanXHSSpecificKeychain;
- (BOOL)cleanXHSCaches;
- (BOOL)cleanXHSPreferences;
- (BOOL)fullClean;

@end

NS_ASSUME_NONNULL_END
