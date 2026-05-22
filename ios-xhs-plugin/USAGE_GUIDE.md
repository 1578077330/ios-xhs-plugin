# iOS 小红书插件使用指南

## 目录
1. [项目集成](#项目集成)
2. [快速开始](#快速开始)
3. [核心功能使用](#核心功能使用)
4. [常见问题](#常见问题)

---

## 项目集成

### 方法一：直接添加文件到Xcode项目

1. 将以下文件添加到你的Xcode项目中：
   - `XHSKeychainCleaner.h`
   - `XHSKeychainCleaner.m`
   - `XHSIdentifierChanger.h`
   - `XHSIdentifierChanger.m`
   - `XHSCleanerHelper.h`
   - `XHSCleanerHelper.m`
   - `XHSConstants.h`
   - `XHSConstants.m`
   - `XHSPluginManager.h`
   - `XHSPluginManager.m`

2. 确保文件添加到正确的target中

3. 导入Security框架（Keychain操作需要）

### 方法二：创建CocoaPods Podspec（可选）

```ruby
Pod::Spec.new do |s|
  s.name             = 'XHSPlugin'
  s.version          = '1.0.0'
  s.summary          = 'Xiaohongshu iOS Plugin for Keychain cleaning and identifier changing'
  s.homepage         = 'https://github.com/your/repo'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Your Name' => 'your@email.com' }
  s.source           = { :git => 'https://github.com/your/repo.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.source_files = '*.{h,m}'
  s.frameworks = 'Security', 'Foundation'
end
```

---

## 快速开始

### 1. 导入头文件

在需要使用的文件中导入：

```objc
#import "XHSPluginManager.h"
```

### 2. 最简单的使用方式

```objc
// 一键清理并变更标识符
[[XHSPluginManager sharedManager] resetAppWithNewIdentifier:@"com.xiaohongshu.new"];
```

---

## 核心功能使用

### 功能一：Keychain清理

#### 清理所有Keychain项目

```objc
#import "XHSKeychainCleaner.h"

XHSKeychainCleaner *cleaner = [XHSKeychainCleaner sharedCleaner];
BOOL success = [cleaner cleanAllKeychainItems];
if (success) {
    NSLog(@"Keychain清理成功");
}
```

#### 查询当前Keychain项目

```objc
NSArray *items = [cleaner queryAllKeychainItems];
NSLog(@"当前Keychain项目数: %lu", (unsigned long)items.count);
```

#### 清理特定服务的Keychain

```objc
[cleaner cleanKeychainItemsForService:@"com.xiaohongshu"];
```

### 功能二：标识符变更

#### 变更标识符（自动清理Keychain）

```objc
#import "XHSIdentifierChanger.h"

XHSIdentifierChanger *changer = [XHSIdentifierChanger sharedChanger];
BOOL success = [changer changeIdentifierTo:@"com.xiaohongshu.new"];
```

#### 变更标识符但保留Keychain

```objc
[changer changeIdentifierTo:@"com.xiaohongshu.new" keepKeychain:YES];
```

#### 查看当前标识符

```objc
NSString *currentId = [changer currentIdentifier];
NSLog(@"当前标识符: %@", currentId);
```

#### 查看所有可用标识符

```objc
NSArray *availableIds = [changer availableIdentifiers];
NSLog(@"可用标识符: %@", availableIds);
```

### 功能三：小红书专用清理

#### 完整清理小红书相关数据

```objc
#import "XHSCleanerHelper.h"

XHSCleanerHelper *helper = [XHSCleanerHelper sharedHelper];
BOOL success = [helper fullClean];
```

#### 单独清理各部分

```objc
// 只清理小红书Keychain
[helper cleanXHSSpecificKeychain];

// 只清理缓存
[helper cleanXHSCaches];

// 只清理偏好设置
[helper cleanXHSPreferences];
```

### 功能四：插件管理器（推荐使用）

#### 获取当前状态

```objc
#import "XHSPluginManager.h"

XHSPluginManager *manager = [XHSPluginManager sharedManager];
NSDictionary *status = [manager getCurrentStatus];
NSLog(@"当前状态: %@", status);
```

#### 一键重置应用

```objc
[manager resetAppWithNewIdentifier:@"com.xiaohongshu.fresh"];
```

#### 清理并重新初始化

```objc
[manager cleanAndReinitialize];
```

---

## 在实际项目中的使用场景

### 场景1：用户登出时清理数据

```objc
- (void)userDidLogout {
    XHSCleanerHelper *helper = [XHSCleanerHelper sharedHelper];
    [helper fullClean];
    
    XHSIdentifierChanger *changer = [XHSIdentifierChanger sharedChanger];
    [changer changeIdentifierTo:@"com.xiaohongshu.fresh"];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}
```

### 场景2：切换账号

```objc
- (void)switchToNewAccount {
    XHSPluginManager *manager = [XHSPluginManager sharedManager];
    [manager resetAppWithNewIdentifier:@"com.xiaohongshu.account2"];
    
    [self presentLoginViewControllerAnimated:YES];
}
```

### 场景3：调试时查看状态

```objc
#ifdef DEBUG
- (void)debugPrintStatus {
    XHSPluginManager *manager = [XHSPluginManager sharedManager];
    NSDictionary *status = [manager getCurrentStatus];
    NSLog(@"调试信息: %@", status);
}
#endif
```

---

## 常见问题

### Q: 是否需要特殊权限？
A: Keychain操作不需要特殊权限，但需要确保你的App有正确的Keychain访问组配置。

### Q: 清理Keychain会影响其他应用吗？
A: 不会。iOS的Keychain是按应用沙箱隔离的，只会清理当前应用的Keychain数据。

### Q: 可以在App Extension中使用吗？
A: 可以，但需要确保App Group配置正确，并且Keychain访问组在Extension和主App之间共享。

### Q: 如何判断清理是否成功？
A: 所有方法都返回BOOL值，YES表示成功，NO表示失败或部分失败。

### Q: 变更标识符后需要重启App吗？
A: 建议重启App以确保所有更改生效。

---

## 注意事项

1. **备份重要数据**：在执行清理操作前，请确保已备份重要数据
2. **测试环境优先**：先在测试环境验证功能
3. **用户提示**：建议在执行清理操作前提示用户
4. **错误处理**：妥善处理可能的失败情况
