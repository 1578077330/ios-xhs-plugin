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
            [self createFloatButton];
        });
    }];
}

static void createFloatButton() {
    if (gFloatButton) {
        return;
    }
    
    NSLog(@"[XHSPlugin] 创建悬浮按钮");
    
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
    gFloatButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [gFloatButton setTitle:@"🧹" forState:UIControlStateNormal];
    [gFloatButton addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    
    [gFloatWindow addSubview:gFloatButton];
    [gFloatWindow makeKeyAndVisible];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [gFloatButton addGestureRecognizer:pan];
}

static void handlePan(UIPanGestureRecognizer *gesture) {
    UIView *button = gesture.view;
    UIWindow *window = button.window;
    
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:window];
        CGPoint center = button.center;
        center.x += translation.x;
        center.y += translation.y;
        
        CGFloat margin = 40;
        CGFloat screenWidth = window.bounds.size.width;
        CGFloat screenHeight = window.bounds.size.height;
        
        center.x = MAX(margin, MIN(center.x, screenWidth - margin));
        center.y = MAX(margin, MIN(center.y, screenHeight - margin));
        
        button.center = center;
        [gesture setTranslation:CGPointZero inView:window];
    }
}

static void showMenu() {
    NSLog(@"[XHSPlugin] 显示菜单");
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"🧹 XHS 清理工具"
                                                                     message:@"请选择操作"
                                                              preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"🔑 清理 Keychain"
                                               style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction *action) {
        doCleanKeychain();
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"🎲 随机设备ID"
                                               style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction *action) {
        doRandomDeviceId();
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"🆔 手动设备ID"
                                               style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction *action) {
        doCustomDeviceId();
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"♻️ 完整清理"
                                               style:UIAlertActionStyleDestructive
                                             handler:^(UIAlertAction *action) {
        doFullClean();
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"📊 状态"
                                               style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction *action) {
        doShowStatus();
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"❌ 取消"
                                               style:UIAlertActionStyleCancel
                                             handler:nil]];
    
    alert.popoverPresentationController.sourceView = gFloatButton;
    alert.popoverPresentationController.sourceRect = gFloatButton.bounds;
    
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (rootVC) {
        [rootVC presentViewController:alert animated:YES completion:nil];
    }
}

static void doCleanKeychain() {
    XHSCleanerHelper *helper = [XHSCleanerHelper sharedHelper];
    BOOL success = [helper cleanXHSSpecificKeychain];
    showSimpleAlert(success ? @"✅ Keychain 清理成功！" : @"❌ Keychain 清理失败");
}

static void doRandomDeviceId() {
    XHSDeviceIdentifier *manager = [XHSDeviceIdentifier sharedManager];
    NSString *newUUID = [manager generateNewUUID];
    BOOL success = [manager changeDeviceIdentifier];
    
    NSString *msg = success ? 
        [NSString stringWithFormat:@"✅ 新设备ID：\n\n%@", newUUID] : 
        @"❌ 操作失败";
    showSimpleAlert(msg);
}

static void doCustomDeviceId() {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"🆔 输入设备ID"
                                                                     message:@"格式：XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
                                                              preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        XHSDeviceIdentifier *manager = [XHSDeviceIdentifier sharedManager];
        textField.text = [manager generateNewUUID];
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                               style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction *action) {
        NSString *newId = alert.textFields.firstObject.text;
        if (newId.length > 0) {
            XHSDeviceIdentifier *manager = [XHSDeviceIdentifier sharedManager];
            BOOL success = [manager changeToCustomIdentifier:newId];
            showSimpleAlert(success ? @"✅ 已设置" : @"❌ 失败");
        }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                               style:UIAlertActionStyleCancel
                                             handler:nil]];
    
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (rootVC) {
        [rootVC presentViewController:alert animated:YES completion:nil];
    }
}

static void doFullClean() {
    XHSCleanerHelper *helper = [XHSCleanerHelper sharedHelper];
    [helper fullClean];
    
    XHSDeviceIdentifier *manager = [XHSDeviceIdentifier sharedManager];
    NSString *newUUID = [manager generateNewUUID];
    [manager changeToCustomIdentifier:newUUID];
    
    NSString *msg = [NSString stringWithFormat:@"✅ 完成！\n新ID：\n%@", newUUID];
    showSimpleAlert(msg);
}

static void doShowStatus() {
    XHSDeviceIdentifier *deviceManager = [XHSDeviceIdentifier sharedManager];
    XHSKeychainCleaner *cleaner = [XHSKeychainCleaner sharedCleaner];
    
    NSString *currentId = [deviceManager currentDeviceIdentifier];
    NSArray *keychainItems = [cleaner queryAllKeychainItems];
    
    NSString *msg = [NSString stringWithFormat:
        @"📱 设备ID:\n%@\n\n🔑 Keychain: %lu",
        currentId, (unsigned long)keychainItems.count];
    showSimpleAlert(msg);
}

static void showSimpleAlert(NSString *message) {
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
