#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "XHSKeychainCleaner.h"
#import "XHSDeviceIdentifier.h"
#import "XHSCleanerHelper.h"

static BOOL gPluginLoaded = NO;
static UIWindow *gFloatWindow = nil;
static UIButton *gFloatButton = nil;

%ctor {
    NSLog(@"[XHSPlugin] ========== 插件加载成功 ==========");
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification 
                                                      object:nil 
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
        NSLog(@"[XHSPlugin] 应用已启动，准备显示悬浮按钮");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setupFloatButton];
        });
    }];
}

static void setupFloatButton() {
    if (gFloatButton) {
        NSLog(@"[XHSPlugin] 悬浮按钮已存在");
        return;
    }
    
    NSLog(@"[XHSPlugin] 创建悬浮按钮");
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if (!keyWindow) {
        NSLog(@"[XHSPlugin] 无法获取 keyWindow");
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
    [gFloatButton addTarget:self action:@selector(showPluginMenu) forControlEvents:UIControlEventTouchUpInside];
    
    [gFloatWindow addSubview:gFloatButton];
    [gFloatWindow makeKeyAndVisible];
    
    NSLog(@"[XHSPlugin] 悬浮按钮已显示");
    
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

static void showPluginMenu() {
    NSLog(@"[XHSPlugin] 显示插件菜单");
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"🧹 XHS 清理工具"
                                                                     message:@"请选择操作"
                                                              preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"🔑 清理 Keychain"
                                               style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction *action) {
        cleanKeychain();
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"🎲 随机生成设备ID"
                                               style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction *action) {
        randomDeviceId();
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"🆔 手动输入设备ID"
                                               style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction *action) {
        customDeviceId();
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"♻️ 完整清理+随机ID"
                                               style:UIAlertActionStyleDestructive
                                             handler:^(UIAlertAction *action) {
        fullCleanAndRandom();
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"📊 查看当前状态"
                                               style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction *action) {
        showStatus();
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"❌ 取消"
                                               style:UIAlertActionStyleCancel
                                             handler:nil]];
    
    alert.popoverPresentationController.sourceView = gFloatButton;
    alert.popoverPresentationController.sourceRect = gFloatButton.bounds;
    
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (rootVC) {
        [rootVC presentViewController:alert animated:YES completion:nil];
    } else {
        NSLog(@"[XHSPlugin] 无法获取 rootViewController");
    }
}

static void cleanKeychain() {
    NSLog(@"[XHSPlugin] 开始清理 Keychain");
    
    XHSCleanerHelper *helper = [XHSCleanerHelper sharedHelper];
    BOOL success = [helper cleanXHSSpecificKeychain];
    
    showAlertWithTitle(@"清理结果", success ? @"✅ Keychain 清理成功！" : @"❌ Keychain 清理失败");
}

static void randomDeviceId() {
    UIAlertController *confirm = [UIAlertController alertControllerWithTitle:@"🎲 随机生成设备ID"
                                                                        message:@"将随机生成一个新的设备UUID\n并清理Keychain残留\n确定继续吗？"
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    
    [confirm addAction:[UIAlertAction actionWithTitle:@"确定"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action) {
        XHSDeviceIdentifier *manager = [XHSDeviceIdentifier sharedManager];
        NSString *newUUID = [manager generateNewUUID];
        BOOL success = [manager changeDeviceIdentifier];
        
        showAlertWithTitle(@"结果", success ? 
            [NSString stringWithFormat:@"✅ 已生成新设备ID：\n\n%@", newUUID] : 
            @"❌ 操作失败");
    }]];
    
    [confirm addAction:[UIAlertAction actionWithTitle:@"取消"
                                                 style:UIAlertActionStyleCancel
                                               handler:nil]];
    
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (rootVC) {
        [rootVC presentViewController:confirm animated:YES completion:nil];
    }
}

static void customDeviceId() {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"🆔 输入设备ID"
                                                                     message:@"请输入新的设备UUID\n格式：XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
                                                              preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        XHSDeviceIdentifier *manager = [XHSDeviceIdentifier sharedManager];
        textField.placeholder = @"F7BA64F3-E617-4C84-AF05-054693115440";
        textField.text = [manager generateNewUUID];
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                               style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction *action) {
        NSString *newId = alert.textFields.firstObject.text;
        if (newId.length > 0) {
            XHSDeviceIdentifier *manager = [XHSDeviceIdentifier sharedManager];
            BOOL success = [manager changeToCustomIdentifier:newId];
            
            showAlertWithTitle(@"结果", success ? 
                [NSString stringWithFormat:@"✅ 已设置设备ID：\n\n%@", newId] : 
                @"❌ 操作失败");
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

static void fullCleanAndRandom() {
    UIAlertController *confirm = [UIAlertController alertControllerWithTitle:@"⚠️ 确认完整清理"
                                                                        message:@"这将：\n1. 清理所有Keychain数据\n2. 生成新的随机设备ID\n\n确定继续吗？"
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    
    [confirm addAction:[UIAlertAction actionWithTitle:@"确定"
                                                 style:UIAlertActionStyleDestructive
                                               handler:^(UIAlertAction *action) {
        XHSCleanerHelper *helper = [XHSCleanerHelper sharedHelper];
        [helper fullClean];
        
        XHSDeviceIdentifier *manager = [XHSDeviceIdentifier sharedManager];
        NSString *newUUID = [manager generateNewUUID];
        [manager changeToCustomIdentifier:newUUID];
        
        showAlertWithTitle(@"✅ 完成", 
            [NSString stringWithFormat:
             @"完整清理完成！\n\n新设备ID：\n%@\n\n请重启应用以生效", 
             newUUID]);
    }]];
    
    [confirm addAction:[UIAlertAction actionWithTitle:@"取消"
                                                 style:UIAlertActionStyleCancel
                                               handler:nil]];
    
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (rootVC) {
        [rootVC presentViewController:confirm animated:YES completion:nil];
    }
}

static void showStatus() {
    XHSDeviceIdentifier *deviceManager = [XHSDeviceIdentifier sharedManager];
    XHSKeychainCleaner *cleaner = [XHSKeychainCleaner sharedCleaner];
    
    NSString *currentId = [deviceManager currentDeviceIdentifier];
    NSArray *keychainItems = [cleaner queryAllKeychainItems];
    NSArray *foundIds = [deviceManager findDeviceIdentifiersInKeychain];
    
    NSString *message = [NSString stringWithFormat:
        @"📱 当前设备ID:\n%@\n\n"
        @"🔑 Keychain项目数:\n%lu\n\n"
        @"🔍 找到的设备ID数:\n%lu",
        currentId,
        (unsigned long)keychainItems.count,
        (unsigned long)foundIds.count];
    
    if (foundIds.count > 0) {
        message = [message stringByAppendingString:@"\n\n找到的ID:\n"];
        for (NSString *foundId in foundIds) {
            message = [message stringByAppendingFormat:@"\n• %@", foundId];
        }
    }
    
    showAlertWithTitle(@"📊 当前状态", message);
}

static void showAlertWithTitle(NSString *title, NSString *message) {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
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
