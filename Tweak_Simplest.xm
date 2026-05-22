#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "XHSKeychainCleaner.h"
#import "XHSDeviceIdentifier.h"
#import "XHSCleanerHelper.h"

static UIWindow *gFloatWindow = nil;
static UIButton *gFloatButton = nil;

%ctor {
    NSLog(@"[XHSPlugin] ========== 插件加载成功 ==========");
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification 
                                                      object:nil 
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
        NSLog(@"[XHSPlugin] 应用已启动");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self createButton];
        });
    }];
}

static void createButton() {
    if (gFloatButton) {
        return;
    }
    
    NSLog(@"[XHSPlugin] 创建按钮");
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if (!keyWindow) {
        return;
    }
    
    gFloatWindow = [[UIWindow alloc] initWithFrame:CGRectMake(20, 100, 60, 60)];
    gFloatWindow.windowLevel = UIWindowLevelAlert + 1000;
    gFloatWindow.backgroundColor = [UIColor clearColor];
    gFloatWindow.layer.cornerRadius = 30;
    gFloatWindow.clipsToBounds = YES;
    
    gFloatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    gFloatButton.frame = gFloatWindow.bounds;
    gFloatButton.backgroundColor = [UIColor colorWithRed:0.9 green:0.3 blue:0.4 alpha:1.0];
    gFloatButton.layer.cornerRadius = 30;
    [gFloatButton setTitle:@"🧹" forState:UIControlStateNormal];
    
    [gFloatButton addTarget:self action:@selector(doClean) forControlEvents:UIControlEventTouchUpInside];
    
    [gFloatWindow addSubview:gFloatButton];
    [gFloatWindow makeKeyAndVisible];
}

static void doClean() {
    NSLog(@"[XHSPlugin] 执行清理");
    
    XHSCleanerHelper *helper = [XHSCleanerHelper sharedHelper];
    [helper cleanXHSSpecificKeychain];
    
    XHSDeviceIdentifier *manager = [XHSDeviceIdentifier sharedManager];
    NSString *uuid = [manager generateNewUUID];
    [manager changeDeviceIdentifier];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"完成"
                                                                     message:[NSString stringWithFormat:@"已清理！\n新ID：%@", uuid]
                                                              preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                               style:UIAlertActionStyleDefault
                                             handler:nil]];
    
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (rootVC) {
        [rootVC presentViewController:alert animated:YES completion:nil];
    }
}
