#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "XHSKeychainCleaner.h"
#import "XHSIdentifierChanger.h"
#import "XHSCleanerHelper.h"
#import "XHSPluginManager.h"

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
    
    // 创建悬浮窗口
    gFloatWindow = [[UIWindow alloc] initWithFrame:CGRectMake(20, 100, 60, 60)];
    gFloatWindow.windowLevel = UIWindowLevelAlert + 1000;
    gFloatWindow.backgroundColor = [UIColor clearColor];
    gFloatWindow.layer.cornerRadius = 30;
    gFloatWindow.clipsToBounds = YES;
    
    // 创建按钮
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
    
    // 添加拖动手势
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
        
        // 限制在屏幕范围内
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
                                                 [self cleanKeychain];
                                             }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"🎲 随机生成ID"
                                               style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction *action) {
                                                 [self randomIdentifier];
                                             }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"🆔 手动输入ID"
                                               style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction *action) {
                                                 [self changeIdentifier];
                                             }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"♻️ 完整清理+随机ID"
                                               style:UIAlertActionStyleDestructive
                                             handler:^(UIAlertAction *action) {
                                                 [self fullResetRandom];
                                             }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"📊 查看当前状态"
                                               style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction *action) {
                                                 [self showStatus];
                                             }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"❌ 取消"
                                               style:UIAlertActionStyleCancel
                                             handler:nil]];
    
    // 适配 iPad
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
    
    [self showAlertWithTitle:@"清理结果" 
                      message:success ? @"✅ Keychain 清理成功！" : @"❌ Keychain 清理失败"];
}

static void changeIdentifier() {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"🆔 输入新标识符"
                                                                     message:@"请输入新的 Bundle ID"
                                                              preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"com.xiaohongshu.new";
        textField.text = @"com.xiaohongshu.new";
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                               style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction *action) {
        NSString *newId = alert.textFields.firstObject.text;
        if (newId.length > 0) {
            XHSIdentifierChanger *changer = [XHSIdentifierChanger sharedChanger];
            BOOL success = [changer changeIdentifierTo:newId];
            [self showAlertWithTitle:@"结果" 
                              message:success ? 
                [NSString stringWithFormat:@"✅ 标识符已变更为：\n%@", newId] : 
                @"❌ 标识符变更失败"];
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

static void randomIdentifier() {
    UIAlertController *confirm = [UIAlertController alertControllerWithTitle:@"🎲 随机生成ID"
                                                                        message:@"将随机生成一个新的标识符\n确定继续吗？"
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    
    [confirm addAction:[UIAlertAction actionWithTitle:@"确定"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action) {
        XHSIdentifierChanger *changer = [XHSIdentifierChanger sharedChanger];
        NSString *randomId = [changer generateRandomIdentifier];
        BOOL success = [changer changeIdentifierTo:randomId];
        
        [self showAlertWithTitle:@"结果" 
                          message:success ? 
            [NSString stringWithFormat:@"✅ 已生成新ID：\n%@", randomId] : 
            @"❌ 操作失败"];
    }]];
    
    [confirm addAction:[UIAlertAction actionWithTitle:@"取消"
                                                 style:UIAlertActionStyleCancel
                                               handler:nil]];
    
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (rootVC) {
        [rootVC presentViewController:confirm animated:YES completion:nil];
    }
}

static void fullReset() {
    UIAlertController *confirm = [UIAlertController alertControllerWithTitle:@"⚠️ 确认重置"
                                                                        message:@"这将清理所有数据并重置应用！\n确定继续吗？"
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    
    [confirm addAction:[UIAlertAction actionWithTitle:@"确定"
                                                 style:UIAlertActionStyleDestructive
                                               handler:^(UIAlertAction *action) {
        XHSPluginManager *manager = [XHSPluginManager sharedManager];
        [manager resetAppWithNewIdentifier:@"com.xiaohongshu.fresh"];
        [self showAlertWithTitle:@"✅ 完成" 
                          message:@"重置完成！\n请重启应用以生效"];
    }]];
    
    [confirm addAction:[UIAlertAction actionWithTitle:@"取消"
                                                 style:UIAlertActionStyleCancel
                                               handler:nil]];
    
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (rootVC) {
        [rootVC presentViewController:confirm animated:YES completion:nil];
    }
}

static void fullResetRandom() {
    UIAlertController *confirm = [UIAlertController alertControllerWithTitle:@"⚠️ 确认完整重置"
                                                                        message:@"这将：\n1. 清理所有数据\n2. 随机生成新ID\n确定继续吗？"
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    
    [confirm addAction:[UIAlertAction actionWithTitle:@"确定"
                                                 style:UIAlertActionStyleDestructive
                                               handler:^(UIAlertAction *action) {
        XHSIdentifierChanger *changer = [XHSIdentifierChanger sharedChanger];
        NSString *randomId = [changer generateRandomIdentifier];
        
        XHSPluginManager *manager = [XHSPluginManager sharedManager];
        [manager resetAppWithNewIdentifier:randomId];
        
        [self showAlertWithTitle:@"✅ 完成" 
                          message:[NSString stringWithFormat:
                                   @"重置完成！\n新ID：%@\n请重启应用以生效", 
                                   randomId]];
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
    XHSPluginManager *manager = [XHSPluginManager sharedManager];
    NSDictionary *status = [manager getCurrentStatus];
    
    NSString *message = [NSString stringWithFormat:
        @"📱 当前标识符:\n%@\n\n"
        @"🔑 Keychain项目数:\n%@",
        status[@"currentIdentifier"],
        status[@"keychainItemCount"]];
    
    [self showAlertWithTitle:@"📊 当前状态" message:message];
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
