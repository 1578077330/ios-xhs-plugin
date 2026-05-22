#import <Foundation/Foundation.h>
#import "XHSKeychainCleaner.h"
#import "XHSIdentifierChanger.h"

NS_ASSUME_NONNULL_BEGIN

@interface XHSPluginManager : NSObject

+ (instancetype)sharedManager;

- (void)resetAppWithNewIdentifier:(NSString *)newIdentifier;
- (void)cleanAndReinitialize;
- (NSDictionary *)getCurrentStatus;

@end

NS_ASSUME_NONNULL_END
