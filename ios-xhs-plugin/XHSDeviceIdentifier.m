#import "XHSDeviceIdentifier.h"
#import "XHSKeychainCleaner.h"
#import <Security/Security.h>

static NSString * const kXHSDeviceIDKey = @"XHS_DeviceIdentifier";
static NSString * const kXHSStoredDeviceIDsKey = @"XHS_StoredDeviceIDs";

@implementation XHSDeviceIdentifier

+ (instancetype)sharedManager {
    static XHSDeviceIdentifier *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (NSString *)generateNewUUID {
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
    NSString *result = (__bridge_transfer NSString *)uuidString;
    CFRelease(uuid);
    
    NSLog(@"Generated new UUID: %@", result);
    return result;
}

- (NSString *)currentDeviceIdentifier {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentId = [defaults stringForKey:kXHSDeviceIDKey];
    
    if (!currentId) {
        currentId = [self generateNewUUID];
        [defaults setObject:currentId forKey:kXHSDeviceIDKey];
        [defaults synchronize];
    }
    
    return currentId;
}

- (BOOL)changeDeviceIdentifier {
    NSString *newUUID = [self generateNewUUID];
    return [self changeToCustomIdentifier:newUUID];
}

- (BOOL)changeToCustomIdentifier:(NSString *)customId {
    if (!customId || customId.length == 0) {
        NSLog(@"Invalid custom identifier");
        return NO;
    }
    
    NSLog(@"Changing device identifier to: %@", customId);
    
    // 1. 清理 Keychain 中的设备标识
    XHSKeychainCleaner *cleaner = [XHSKeychainCleaner sharedCleaner];
    [cleaner cleanAllKeychainItems];
    
    // 2. 保存新的设备标识
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // 保存旧的到历史记录
    NSString *oldId = [defaults stringForKey:kXHSDeviceIDKey];
    if (oldId) {
        NSMutableArray *history = [[defaults arrayForKey:kXHSStoredDeviceIDsKey] mutableCopy];
        if (!history) {
            history = [NSMutableArray array];
        }
        if (![history containsObject:oldId]) {
            [history addObject:oldId];
            [defaults setObject:history forKey:kXHSStoredDeviceIDsKey];
        }
    }
    
    // 设置新的
    [defaults setObject:customId forKey:kXHSDeviceIDKey];
    [defaults synchronize];
    
    NSLog(@"Device identifier changed successfully");
    return YES;
}

- (NSArray<NSString *> *)findDeviceIdentifiersInKeychain {
    NSMutableArray *foundIds = [NSMutableArray array];
    
    XHSKeychainCleaner *cleaner = [XHSKeychainCleaner sharedCleaner];
    NSArray *items = [cleaner queryAllKeychainItems];
    
    for (NSDictionary *item in items) {
        NSString *service = item[(__bridge id)kSecAttrService];
        NSString *account = item[(__bridge id)kSecAttrAccount];
        NSData *data = item[(__bridge id)kSecValueData];
        
        if (data) {
            NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (dataStr && [self looksLikeUUID:dataStr]) {
                [foundIds addObject:dataStr];
            }
        }
        
        if (service && [self looksLikeUUID:service]) {
            [foundIds addObject:service];
        }
        
        if (account && [self looksLikeUUID:account]) {
            [foundIds addObject:account];
        }
    }
    
    return [foundIds copy];
}

- (BOOL)looksLikeUUID:(NSString *)string {
    if (!string || string.length != 36) {
        return NO;
    }
    
    // UUID 格式: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
    NSCharacterSet *hexChars = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEFabcdef-"];
    NSCharacterSet *invalidChars = [hexChars invertedSet];
    
    if ([string rangeOfCharacterFromSet:invalidChars].location != NSNotFound) {
        return NO;
    }
    
    // 检查连字符位置
    if ([string characterAtIndex:8] != '-' ||
        [string characterAtIndex:13] != '-' ||
        [string characterAtIndex:18] != '-' ||
        [string characterAtIndex:23] != '-') {
        return NO;
    }
    
    return YES;
}

@end
