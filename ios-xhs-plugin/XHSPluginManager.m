#import "XHSPluginManager.h"

@implementation XHSPluginManager

+ (instancetype)sharedManager {
    static XHSPluginManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (void)resetAppWithNewIdentifier:(NSString *)newIdentifier {
    NSLog(@"Starting app reset with new identifier: %@", newIdentifier);
    
    XHSKeychainCleaner *cleaner = [XHSKeychainCleaner sharedCleaner];
    BOOL keychainCleaned = [cleaner cleanAllKeychainItems];
    
    XHSIdentifierChanger *changer = [XHSIdentifierChanger sharedChanger];
    BOOL identifierChanged = [changer changeIdentifierTo:newIdentifier keepKeychain:YES];
    
    if (keychainCleaned && identifierChanged) {
        NSLog(@"App reset completed successfully");
    } else {
        NSLog(@"App reset encountered some issues");
    }
}

- (void)cleanAndReinitialize {
    NSLog(@"Starting clean and reinitialize");
    
    XHSKeychainCleaner *cleaner = [XHSKeychainCleaner sharedCleaner];
    [cleaner cleanAllKeychainItems];
    
    XHSIdentifierChanger *changer = [XHSIdentifierChanger sharedChanger];
    [changer changeIdentifierTo:[changer currentIdentifier] keepKeychain:YES];
    
    NSLog(@"Clean and reinitialize completed");
}

- (NSDictionary *)getCurrentStatus {
    XHSIdentifierChanger *changer = [XHSIdentifierChanger sharedChanger];
    XHSKeychainCleaner *cleaner = [XHSKeychainCleaner sharedCleaner];
    
    NSArray *keychainItems = [cleaner queryAllKeychainItems];
    
    return @{
        @"currentIdentifier": [changer currentIdentifier],
        @"availableIdentifiers": [changer availableIdentifiers],
        @"keychainItemCount": @(keychainItems.count),
        @"keychainItems": keychainItems
    };
}

@end
