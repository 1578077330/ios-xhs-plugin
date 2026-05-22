#import "XHSIdentifierChanger.h"
#import "XHSKeychainCleaner.h"

static NSString * const kXHSDefaultIdentifier = @"com.xiaohongshu";
static NSString * const kXHSIdentifierKey = @"XHS_CurrentIdentifier";
static NSString * const kXHSAvailableIdentifiersKey = @"XHS_AvailableIdentifiers";

@implementation XHSIdentifierChanger

+ (instancetype)sharedChanger {
    static XHSIdentifierChanger *changer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        changer = [[self alloc] init];
        [changer setupDefaultIdentifiers];
    });
    return changer;
}

- (void)setupDefaultIdentifiers {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (![defaults objectForKey:kXHSAvailableIdentifiersKey]) {
        NSArray *defaultIdentifiers = @[
            @"com.xiaohongshu",
            @"com.xiaohongshu.new",
            @"com.xiaohongshu.alt",
            @"com.xiaohongshu.dev"
        ];
        [defaults setObject:defaultIdentifiers forKey:kXHSAvailableIdentifiersKey];
    }
    
    if (![defaults objectForKey:kXHSIdentifierKey]) {
        [defaults setObject:kXHSDefaultIdentifier forKey:kXHSIdentifierKey];
    }
    
    [defaults synchronize];
}

- (BOOL)changeIdentifierTo:(NSString *)newIdentifier {
    return [self changeIdentifierTo:newIdentifier keepKeychain:NO];
}

- (BOOL)changeIdentifierTo:(NSString *)newIdentifier keepKeychain:(BOOL)keep {
    if (!newIdentifier || newIdentifier.length == 0) {
        NSLog(@"Invalid identifier: %@", newIdentifier);
        return NO;
    }
    
    if (!keep) {
        XHSKeychainCleaner *cleaner = [XHSKeychainCleaner sharedCleaner];
        [cleaner cleanAllKeychainItems];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:newIdentifier forKey:kXHSIdentifierKey];
    
    NSMutableArray *availableIdentifiers = [[self availableIdentifiers] mutableCopy];
    if (![availableIdentifiers containsObject:newIdentifier]) {
        [availableIdentifiers addObject:newIdentifier];
        [defaults setObject:availableIdentifiers forKey:kXHSAvailableIdentifiersKey];
    }
    
    [defaults synchronize];
    
    NSLog(@"Successfully changed identifier to: %@", newIdentifier);
    return YES;
}

- (NSString *)currentIdentifier {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:kXHSIdentifierKey] ?: kXHSDefaultIdentifier;
}

- (NSArray<NSString *> *)availableIdentifiers {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults arrayForKey:kXHSAvailableIdentifiersKey] ?: @[kXHSDefaultIdentifier];
}

- (NSString *)generateRandomIdentifier {
    NSString *prefix = @"com.xiaohongshu";
    
    NSArray *suffixes = @[
        @"pro", @"new", @"alt", @"dev", @"test", @"demo",
        @"fresh", @"clean", @"temp", @"backup", @"copy",
        @"extra", @"plus", @"premium", @"lite", @"mini"
    ];
    
    NSString *randomSuffix = suffixes[arc4random_uniform((uint32_t)suffixes.count)];
    int randomNum = arc4random_uniform(1000);
    
    NSString *randomId = [NSString stringWithFormat:@"%@.%@%d", prefix, randomSuffix, randomNum];
    
    NSLog(@"Generated random identifier: %@", randomId);
    return randomId;
}

- (BOOL)changeToRandomIdentifier {
    NSString *randomId = [self generateRandomIdentifier];
    return [self changeIdentifierTo:randomId];
}

@end
