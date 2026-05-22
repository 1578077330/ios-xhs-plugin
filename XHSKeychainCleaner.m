#import "XHSKeychainCleaner.h"
#import <Security/Security.h>

static NSString * const kXHSDefaultService = @"com.xiaohongshu";
static NSString * const kXHSAccessGroupPrefix = @"com.xiaohongshu.";

@implementation XHSKeychainCleaner

+ (instancetype)sharedCleaner {
    static XHSKeychainCleaner *cleaner = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cleaner = [[self alloc] init];
    });
    return cleaner;
}

- (BOOL)cleanAllKeychainItems {
    BOOL success = YES;
    
    NSArray *classes = @[
        (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecClassInternetPassword,
        (__bridge id)kSecClassCertificate,
        (__bridge id)kSecClassKey,
        (__bridge id)kSecClassIdentity
    ];
    
    for (id secClass in classes) {
        NSDictionary *query = @{
            (__bridge id)kSecClass: secClass,
            (__bridge id)kSecAttrSynchronizable: (__bridge id)kSecAttrSynchronizableAny
        };
        
        OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
        if (status != errSecSuccess && status != errSecItemNotFound) {
            NSLog(@"Failed to delete %@ items: %d", secClass, (int)status);
            success = NO;
        }
    }
    
    return success;
}

- (BOOL)cleanKeychainItemsForService:(NSString *)service {
    if (!service) {
        service = kXHSDefaultService;
    }
    
    BOOL success = YES;
    
    NSArray *classes = @[
        (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecClassInternetPassword
    ];
    
    for (id secClass in classes) {
        NSDictionary *query = @{
            (__bridge id)kSecClass: secClass,
            (__bridge id)kSecAttrService: service,
            (__bridge id)kSecAttrSynchronizable: (__bridge id)kSecAttrSynchronizableAny
        };
        
        OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
        if (status != errSecSuccess && status != errSecItemNotFound) {
            NSLog(@"Failed to delete %@ items for service %@: %d", secClass, service, (int)status);
            success = NO;
        }
    }
    
    return success;
}

- (BOOL)cleanKeychainItemsForAccessGroup:(NSString *)accessGroup {
    if (!accessGroup) {
        return NO;
    }
    
    BOOL success = YES;
    
    NSArray *classes = @[
        (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecClassInternetPassword,
        (__bridge id)kSecClassCertificate,
        (__bridge id)kSecClassKey,
        (__bridge id)kSecClassIdentity
    ];
    
    for (id secClass in classes) {
        NSDictionary *query = @{
            (__bridge id)kSecClass: secClass,
            (__bridge id)kSecAttrAccessGroup: accessGroup,
            (__bridge id)kSecAttrSynchronizable: (__bridge id)kSecAttrSynchronizableAny
        };
        
        OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
        if (status != errSecSuccess && status != errSecItemNotFound) {
            NSLog(@"Failed to delete %@ items for access group %@: %d", secClass, accessGroup, (int)status);
            success = NO;
        }
    }
    
    return success;
}

- (NSArray<NSDictionary *> *)queryAllKeychainItems {
    NSMutableArray *items = [NSMutableArray array];
    
    NSArray *classes = @[
        (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecClassInternetPassword,
        (__bridge id)kSecClassCertificate,
        (__bridge id)kSecClassKey,
        (__bridge id)kSecClassIdentity
    ];
    
    for (id secClass in classes) {
        NSDictionary *query = @{
            (__bridge id)kSecClass: secClass,
            (__bridge id)kSecReturnAttributes: (__bridge id)kCFBooleanTrue,
            (__bridge id)kSecReturnData: (__bridge id)kCFBooleanTrue,
            (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitAll,
            (__bridge id)kSecAttrSynchronizable: (__bridge id)kSecAttrSynchronizableAny
        };
        
        CFArrayRef result = NULL;
        OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
        
        if (status == errSecSuccess && result) {
            NSArray *classItems = (__bridge_transfer NSArray *)result;
            [items addObjectsFromArray:classItems];
        }
    }
    
    return [items copy];
}

@end
