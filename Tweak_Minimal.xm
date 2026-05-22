#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "XHSKeychainCleaner.h"
#import "XHSDeviceIdentifier.h"
#import "XHSCleanerHelper.h"

static UIWindow *gFloatWindow = nil;
static UIButton *gFloatButton = nil;

%ctor {
    NSLog(@"[XHSPlugin] Plugin loaded!");
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification 
                                                      object:nil 
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
        NSLog(@"[XHSPlugin] App launched");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self createFloatButton];
        });
    }];
}

static void createFloatButton() {
    if (gFloatButton) {
        return;
    }
    
    NSLog(@"[XHSPlugin] Creating float button");
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if (!keyWindow) {
        NSLog(@"[XHSPlugin] No key window");
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
    gFloatButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [gFloatButton setTitle:@"🧹" forState:UIControlStateNormal];
    
    [gFloatButton addTarget:self action:@selector(showCleanMenu) forControlEvents:UIControlEventTouchUpInside];
    
    [gFloatWindow addSubview:gFloatButton];
    [gFloatWindow makeKeyAndVisible];
    
    NSLog(@"[XHSPlugin] Float button visible");
}

static void showCleanMenu() {
    NSLog(@"[XHSPlugin] Showing menu");
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"XHS 清理工具"
                                                                     message:@"请选择操作"
                                                              preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"清理 Keychain"
                                               style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction *action) {
        XHSCleanerHelper *helper = [XHSCleanerHelper sharedHelper];
        [helper cleanXHSSpecificKeychain];
        showAlertWithMessage(@"清理完成！");
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"随机设备ID"
                                               style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction *action) {
        XHSDeviceIdentifier *manager = [XHSDeviceIdentifier sharedManager];
        NSString *uuid = [manager generateNewUUID];
        [manager changeDeviceIdentifier];
        showAlertWithMessage([NSString stringWithFormat:@"新ID：%@", uuid]);
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                               style:UIAlertActionStyleCancel
                                             handler:nil]];
    
    alert.popoverPresentationController.sourceView = gFloatButton;
    alert.popoverPresentationController.sourceRect = gFloatButton.bounds;
    
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (rootVC) {
        [rootVC presentViewController:alert animated:YES completion:nil];
    }
}

static void showAlertWithMessage(NSString *message) {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"结果"
                                                                     message:message
                                                              preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                               style:UIAlertActionStyleDefault
                                             handler:nil]];
    
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (rootVC) {
        [rootVC presentViewController:alert animated:YES completion:nil];
    }
}
