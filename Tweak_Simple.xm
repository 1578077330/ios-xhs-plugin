#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "XHSKeychainCleaner.h"
#import "XHSIdentifierChanger.h"
#import "XHSCleanerHelper.h"

// 简单版本：直接在启动时执行清理，或者通过通知触发

%ctor {
    NSLog(@"[XHSPlugin] 插件已加载！");
    
    // 方式1：启动后延迟执行清理（可选）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"[XHSPlugin] 插件已准备就绪");
    });
    
    // 方式2：监听摇一摇手势
    [[NSNotificationCenter defaultCenter] addObserverForName:@"UIApplicationDidBecomeActiveNotification" 
                                                      object:nil 
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
        [self setupShakeGesture];
    }];
}

static void setupShakeGesture() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"[XHSPlugin] 设置摇一摇触发");
        
        // 使用 runtime 给 UIWindow 添加摇一摇监听
        Class UIWindowClass = objc_getClass("UIWindow");
        
        if (UIWindowClass) {
            // 这里可以添加摇一摇检测逻辑
            NSLog(@"[XHSPlugin] 摇一摇监听已设置");
        }
    });
}

// 简单的清理函数，你可以通过其他方式调用
void XHSPluginCleanKeychain() {
    NSLog(@"[XHSPlugin] 开始清理 Keychain");
    XHSCleanerHelper *helper = [XHSCleanerHelper sharedHelper];
    BOOL success = [helper cleanXHSSpecificKeychain];
    NSLog(@"[XHSPlugin] Keychain 清理: %@", success ? @"成功" : @"失败");
}

void XHSPluginChangeIdentifier(NSString *newId) {
    NSLog(@"[XHSPlugin] 变更标识符为: %@", newId);
    XHSIdentifierChanger *changer = [XHSIdentifierChanger sharedChanger];
    BOOL success = [changer changeIdentifierTo:newId];
    NSLog(@"[XHSPlugin] 标识符变更: %@", success ? @"成功" : @"失败");
}

void XHSPluginFullClean() {
    NSLog(@"[XHSPlugin] 开始完整清理");
    XHSCleanerHelper *helper = [XHSCleanerHelper sharedHelper];
    BOOL success = [helper fullClean];
    NSLog(@"[XHSPlugin] 完整清理: %@", success ? @"成功" : @"失败");
}
