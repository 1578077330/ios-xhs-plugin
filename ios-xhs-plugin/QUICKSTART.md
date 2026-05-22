# 快速开始指南

## 3步上手使用

### 第1步：添加文件到项目

将所有 `.h` 和 `.m` 文件拖入你的Xcode项目：

```
XHSKeychainCleaner.h/m
XHSIdentifierChanger.h/m
XHSCleanerHelper.h/m
XHSConstants.h/m
XHSPluginManager.h/m
```

### 第2步：导入头文件

在你需要使用的地方：

```objc
#import "XHSPluginManager.h"
```

### 第3步：调用功能

```objc
// 一键清理并换新标识
[[XHSPluginManager sharedManager] resetAppWithNewIdentifier:@"com.xiaohongshu.new"];
```

就这么简单！🎉

---

## 最常用的3个功能

### 1. 完整清理小红书数据
```objc
[[XHSCleanerHelper sharedHelper] fullClean];
```

### 2. 变更标识符
```objc
[[XHSIdentifierChanger sharedChanger] changeIdentifierTo:@"com.xiaohongshu.fresh"];
```

### 3. 查看当前状态
```objc
NSDictionary *status = [[XHSPluginManager sharedManager] getCurrentStatus];
NSLog(@"%@", status);
```

---

## 就这些！

详细说明请查看 `USAGE_GUIDE.md`
