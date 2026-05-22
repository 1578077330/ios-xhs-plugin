#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "XHSKeychainCleaner.h"
#import "XHSIdentifierChanger.h"
#import "XHSCleanerHelper.h"

// 手动触发版本：需要你在合适的地方调用这些函数

%ctor {
    NSLog(@"[XHSPlugin] ========== 插件加载成功 ==========");
    NSLog(@"[XHSPlugin] 版本: 1.0.0");
    NSLog(@"[XHSPlugin] 功能: Keychain清理 + 标识符变更");
}

// 导出函数，供外部调用
void XHSPlugin_CleanKeychain() {
    @autoreleasepool {
        NSLog(@"[XHSPlugin] ========== 开始清理 Keychain ==========");
        
        XHSCleanerHelper *helper = [XHSCleanerHelper sharedHelper];
        BOOL success = [helper cleanXHSSpecificKeychain];
        
        if (success) {
            NSLog(@"[XHSPlugin] ✅ Keychain 清理成功");
        } else {
            NSLog(@"[XHSPlugin] ❌ Keychain 清理失败");
        }
    }
}

void XHSPlugin_ChangeIdentifier(const char *newIdCStr) {
    @autoreleasepool {
        NSString *newId = [NSString stringWithUTF8String:newIdCStr];
        NSLog(@"[XHSPlugin] ========== 变更标识符 ==========");
        NSLog(@"[XHSPlugin] 新标识符: %@", newId);
        
        XHSIdentifierChanger *changer = [XHSIdentifierChanger sharedChanger];
        BOOL success = [changer changeIdentifierTo:newId];
        
        if (success) {
            NSLog(@"[XHSPlugin] ✅ 标识符变更成功");
        } else {
            NSLog(@"[XHSPlugin] ❌ 标识符变更失败");
        }
    }
}

void XHSPlugin_FullReset(const char *newIdCStr) {
    @autoreleasepool {
        NSString *newId = [NSString stringWithUTF8String:newIdCStr];
        NSLog(@"[XHSPlugin] ========== 完整重置 ==========");
        NSLog(@"[XHSPlugin] 新标识符: %@", newId);
        
        // 1. 清理 Keychain
        XHSCleanerHelper *helper = [XHSCleanerHelper sharedHelper];
        BOOL cleanSuccess = [helper fullClean];
        
        // 2. 变更标识符
        XHSIdentifierChanger *changer = [XHSIdentifierChanger sharedChanger];
        BOOL changeSuccess = [changer changeIdentifierTo:newId keepKeychain:YES];
        
        if (cleanSuccess && changeSuccess) {
            NSLog(@"[XHSPlugin] ✅ 完整重置成功！请重启应用");
        } else {
            NSLog(@"[XHSPlugin] ❌ 完整重置遇到问题");
        }
    }
}

void XHSPlugin_ShowStatus() {
    @autoreleasepool {
        NSLog(@"[XHSPlugin] ========== 当前状态 ==========");
        
        XHSIdentifierChanger *changer = [XHSIdentifierChanger sharedChanger];
        XHSKeychainCleaner *cleaner = [XHSKeychainCleaner sharedCleaner];
        
        NSLog(@"[XHSPlugin] 当前标识符: %@", [changer currentIdentifier]);
        NSLog(@"[XHSPlugin] 可用标识符: %@", [changer availableIdentifiers]);
        
        NSArray *items = [cleaner queryAllKeychainItems];
        NSLog(@"[XHSPlugin] Keychain 项目数: %lu", (unsigned long)items.count);
    }
}
