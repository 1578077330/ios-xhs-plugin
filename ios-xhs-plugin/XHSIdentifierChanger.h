#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XHSIdentifierChanger : NSObject

+ (instancetype)sharedChanger;

- (BOOL)changeIdentifierTo:(NSString *)newIdentifier;
- (BOOL)changeIdentifierTo:(NSString *)newIdentifier keepKeychain:(BOOL)keep;
- (BOOL)changeToRandomIdentifier;
- (NSString *)generateRandomIdentifier;
- (NSString *)currentIdentifier;
- (NSArray<NSString *> *)availableIdentifiers;

@end

NS_ASSUME_NONNULL_END
