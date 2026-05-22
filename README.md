# iOS 小红书插件 - Keychain清理与标识符变更

专门为小红书应用设计的iOS插件，用于清理Keychain残留数据和变更应用标识符。

## 功能特性

- 清理小红书应用的Keychain残留数据
- 变更应用标识符（Bundle ID）
- 支持多种Keychain访问组清理
- 安全的操作流程

## 使用方法

### 1. Keychain清理

```objc
[XHSKeychainCleaner cleanAllKeychainItems];
```

### 2. 标识符变更

```objc
[XHSIdentifierChanger changeIdentifierTo:@"com.new.bundleid"];
```
