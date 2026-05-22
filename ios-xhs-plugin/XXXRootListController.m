#import "XXXRootListController.h"
#import "XHSPluginManager.h"
#import "XHSCleanerHelper.h"

@implementation XXXRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}
	return _specifiers;
}

- (void)cleanKeychain:(PSSpecifier *)specifier {
	XHSCleanerHelper *helper = [XHSCleanerHelper sharedHelper];
	BOOL success = [helper cleanXHSSpecificKeychain];
	
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"结果"
																 message:success ? @"Keychain 清理成功！" : @"Keychain 清理失败"
														  preferredStyle:UIAlertControllerStyleAlert];
	[alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
	[self presentViewController:alert animated:YES completion:nil];
}

- (void)fullReset:(PSSpecifier *)specifier {
	UIAlertController *confirm = [UIAlertController alertControllerWithTitle:@"确认重置"
																  message:@"这将清理所有数据并重置应用，确定继续吗？"
														   preferredStyle:UIAlertControllerStyleAlert];
	
	[confirm addAction:[UIAlertAction actionWithTitle:@"确定"
												 style:UIAlertActionStyleDestructive
											   handler:^(UIAlertAction *action) {
		XHSPluginManager *manager = [XHSPluginManager sharedManager];
		[manager resetAppWithNewIdentifier:@"com.xiaohongshu.fresh"];
		
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"完成"
																	 message:@"重置完成！请重启应用"
															  preferredStyle:UIAlertControllerStyleAlert];
		[alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
		[self presentViewController:alert animated:YES completion:nil];
	}]];
	
	[confirm addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
	[self presentViewController:confirm animated:YES completion:nil];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

@end
