# TrollStore 小红书插件使用指南

## 前提条件

1. 已安装 TrollStore 的 iOS 设备（支持 iOS 14.0 - 16.6.1）
2. 已安装 Theos 开发环境
3. 已下载小红书 IPA 文件

## 目录
1. [环境搭建](#环境搭建)
2. [编译插件](#编译插件)
3. [注入插件到 IPA](#注入插件到-ipa)
4. [安装到 TrollStore](#安装到-trollstore)
5. [使用插件](#使用插件)

---

## 环境搭建

### 1. 安装 Theos

```bash
# 安装依赖
brew install ldid xz

# 克隆 Theos
git clone --recursive https://github.com/theos/theos.git $THEOS

# 设置环境变量（添加到 ~/.zshrc 或 ~/.bash_profile）
export THEOS=~/theos
export PATH=$THEOS/bin:$PATH
```

### 2. 安装 iOS SDK

```bash
# 下载最新的 iOS SDK
# 或从 Xcode 中复制
```

---

## 编译插件

### 1. 修改配置

编辑 `control` 文件，修改以下信息：
```
Package: com.yourname.xhsplugin
Maintainer: Your Name
Author: Your Name
```

### 2. 编译

```bash
cd ios-xhs-plugin
make clean
make package
```

编译成功后会在 `packages/` 目录下生成 `.deb` 文件。

---

## 注入插件到 IPA

### 方法一：使用 Azule（推荐）

1. 安装 Azule：
```bash
git clone https://github.com/Al4ise/Azule.git
cd Azule
./install.sh
```

2. 注入插件：
```bash
azule -i Xiaohongshu.ipa -o output -f com.yourname.xhsplugin.deb
```

### 方法二：手动注入

1. 解压 IPA：
```bash
unzip Xiaohongshu.ipa -d extracted
```

2. 复制插件文件：
```bash
# 解压 deb 文件
dpkg -x packages/com.yourname.xhsplugin_1.0.0_iphoneos-arm.deb deb_extracted

# 复制 dylib 到应用目录
cp deb_extracted/Library/MobileSubstrate/DynamicLibraries/XHSPlugin.dylib extracted/Payload/Xiaohongshu.app/
cp deb_extracted/Library/MobileSubstrate/DynamicLibraries/XHSPlugin.plist extracted/Payload/Xiaohongshu.app/
```

3. 修改可执行文件加载 dylib：
```bash
# 使用 insert_dylib 或 optool
optool install -c load -p @executable_path/XHSPlugin.dylib -t extracted/Payload/Xiaohongshu.app/Xiaohongshu
```

4. 重新打包：
```bash
cd extracted
zip -qr ../Xiaohongshu_Modified.ipa Payload/
```

---

## 安装到 TrollStore

1. 将修改后的 IPA 文件传输到 iOS 设备
2. 在 TrollStore 中打开该 IPA 文件
3. 点击安装
4. 等待安装完成

---

## 使用插件

### 方式一：通过应用内菜单（推荐）

插件会在小红书启动时自动加载，并在适当时机显示功能菜单。

### 方式二：通过通知触发

发送通知来显示菜单：
```objc
[[NSNotificationCenter defaultCenter] postNotificationName:@"XHSPluginShowMenu" object:nil];
```

### 可用功能

1. **清理 Keychain** - 清理小红书相关的 Keychain 数据
2. **变更标识符** - 输入新的 Bundle ID 并变更
3. **完整清理并重置** - 清理所有数据并重置应用
4. **查看当前状态** - 显示当前标识符和 Keychain 状态

---

## 注意事项

1. **备份数据**：使用前请先备份重要数据
2. **测试环境**：建议先在测试账号上测试
3. **重启应用**：某些操作需要重启应用才能生效
4. **合规使用**：请遵守相关法律法规和平台规则

---

## 故障排除

### 插件未加载
- 检查 IPA 是否正确注入
- 查看设备日志：`idevicesyslog | grep XHSPlugin`

### 功能异常
- 确保有足够的权限
- 检查小红书版本兼容性

### 编译失败
- 确认 Theos 环境正确配置
- 检查 SDK 版本是否匹配
