#import <Foundation/Foundation.h>
#import "XHSPluginManager.h"
#import "XHSKeychainCleaner.h"
#import "XHSIdentifierChanger.h"
#import "XHSCleanerHelper.h"

void exampleCleanKeychain() {
    NSLog(@"=== Example: Clean Keychain ===");
    
    XHSKeychainCleaner *cleaner = [XHSKeychainCleaner sharedCleaner];
    
    NSArray *items = [cleaner queryAllKeychainItems];
    NSLog(@"Found %lu Keychain items before cleaning", (unsigned long)items.count);
    
    BOOL success = [cleaner cleanAllKeychainItems];
    NSLog(@"Clean all Keychain items: %@", success ? @"Success" : @"Failed");
    
    items = [cleaner queryAllKeychainItems];
    NSLog(@"Found %lu Keychain items after cleaning", (unsigned long)items.count);
}

void exampleChangeIdentifier() {
    NSLog(@"=== Example: Change Identifier ===");
    
    XHSIdentifierChanger *changer = [XHSIdentifierChanger sharedChanger];
    
    NSLog(@"Current identifier: %@", [changer currentIdentifier]);
    NSLog(@"Available identifiers: %@", [changer availableIdentifiers]);
    
    BOOL success = [changer changeIdentifierTo:@"com.xiaohongshu.new"];
    NSLog(@"Change identifier: %@", success ? @"Success" : @"Failed");
    
    NSLog(@"New identifier: %@", [changer currentIdentifier]);
}

void exampleXHSClean() {
    NSLog(@"=== Example: Xiaohongshu Specific Clean ===");
    
    XHSCleanerHelper *helper = [XHSCleanerHelper sharedHelper];
    
    BOOL success = [helper fullClean];
    NSLog(@"Xiaohongshu full clean: %@", success ? @"Success" : @"Failed");
}

void examplePluginManager() {
    NSLog(@"=== Example: Plugin Manager ===");
    
    XHSPluginManager *manager = [XHSPluginManager sharedManager];
    
    NSDictionary *status = [manager getCurrentStatus];
    NSLog(@"Current status: %@", status);
    
    [manager resetAppWithNewIdentifier:@"com.xiaohongshu.fresh"];
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSLog(@"iOS Xiaohongshu Plugin - Example Usage");
        NSLog(@"========================================");
        
        exampleCleanKeychain();
        NSLog(@"\n");
        
        exampleChangeIdentifier();
        NSLog(@"\n");
        
        exampleXHSClean();
        NSLog(@"\n");
        
        examplePluginManager();
        
        NSLog(@"\nDone!");
    }
    return 0;
}
