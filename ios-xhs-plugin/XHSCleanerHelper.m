#import "XHSCleanerHelper.h"
#import "XHSKeychainCleaner.h"
#import "XHSConstants.h"

@implementation XHSCleanerHelper

+ (instancetype)sharedHelper {
    static XHSCleanerHelper *helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[self alloc] init];
    });
    return helper;
}

- (BOOL)cleanXHSSpecificKeychain {
    XHSKeychainCleaner *cleaner = [XHSKeychainCleaner sharedCleaner];
    BOOL success = YES;
    
    NSArray<NSString *> *services = [XHSConstants xhSKeychainServices];
    for (NSString *service in services) {
        if (![cleaner cleanKeychainItemsForService:service]) {
            success = NO;
        }
    }
    
    return success;
}

- (BOOL)cleanXHSCaches {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    if (paths.count == 0) {
        return NO;
    }
    
    NSString *cachesPath = [paths firstObject];
    BOOL success = YES;
    
    NSArray *cacheItems = [fileManager contentsOfDirectoryAtPath:cachesPath error:nil];
    for (NSString *item in cacheItems) {
        if ([item containsString:@"xhs"] || [item containsString:@"xiaohongshu"] || [item containsString:@"xingin"]) {
            NSString *itemPath = [cachesPath stringByAppendingPathComponent:item];
            NSError *error = nil;
            [fileManager removeItemAtPath:itemPath error:&error];
            if (error) {
                NSLog(@"Failed to remove cache item: %@, error: %@", item, error);
                success = NO;
            }
        }
    }
    
    return success;
}

- (BOOL)cleanXHSPreferences {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *defaultsDict = [defaults dictionaryRepresentation];
    BOOL success = YES;
    
    for (NSString *key in defaultsDict.allKeys) {
        if ([key containsString:@"xhs"] || [key containsString:@"xiaohongshu"] || [key containsString:@"xingin"]) {
            [defaults removeObjectForKey:key];
        }
    }
    
    [defaults synchronize];
    return success;
}

- (BOOL)fullClean {
    NSLog(@"Starting full clean for Xiaohongshu");
    
    BOOL keychainCleaned = [self cleanXHSSpecificKeychain];
    BOOL cachesCleaned = [self cleanXHSCaches];
    BOOL prefsCleaned = [self cleanXHSPreferences];
    
    if (keychainCleaned && cachesCleaned && prefsCleaned) {
        NSLog(@"Full clean completed successfully");
        return YES;
    } else {
        NSLog(@"Full clean encountered some issues");
        return NO;
    }
}

@end
