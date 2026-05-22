# 巨魔插件简单注入指南

## 最简单的方法（推荐新手）

### 使用工具：Sideloadly + 已编译的dylib

---

## 步骤

### 1. 获取已编译的 dylib

如果你不想自己编译，可以直接使用预编译好的 dylib 文件。

### 2. 下载 Sideloadly

访问：https://sideloadly.io/

### 3. 准备材料

- 小红书 IPA 文件
- XHSPlugin.dylib（已编译）
- XHSPlugin.plist（配置文件）

### 4. 使用 Sideloadly 注入

1. 打开 Sideloadly
2. 拖入小红书 IPA
3. 点击 "Advanced Options"
4. 在 "Inject dylibs/frameworks" 中添加 `XHSPlugin.dylib`
5. 点击 "Start" 开始注入
6. 等待完成

### 5. 安装到 TrollStore

1. 将注入好的 IPA 传到手机
2. 用 TrollStore 打开并安装

---

## 另一种方法：使用 AltStore

### 1. 安装 AltStore

从 https://altstore.io/ 下载安装

### 2. 创建插件文件夹

在你的电脑上创建文件夹结构：
```
XHSPlugin.altplugin/
  Info.plist
  XHSPlugin.dylib
```

### 3. Info.plist 内容

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.yourname.xhsplugin</string>
    <key>CFBundleName</key>
    <string>XHSPlugin</string>
    <key>Filter</key>
    <dict>
        <key>Bundles</key>
        <array>
            <string>com.xingin.xhs</string>
        </array>
    </dict>
</dict>
</plist>
```

### 4. 在 AltStore 中添加插件

1. 打开 AltStore
2. 进入 "My Apps"
3. 点击小红书应用旁边的 "+"
4. 选择 "Add Plug-in"
5. 选择你的 XHSPlugin.altplugin

---

## 使用 Frida 注入（临时注入，用于测试）

### 1. 安装 Frida

```bash
pip install frida-tools
```

### 2. 手机上安装 Frida Server

从 https://github.com/frida/frida/releases 下载对应版本

### 3. 注入脚本

创建 `inject.js`：
```javascript
console.log("[XHSPlugin] Frida injection script loaded");

// 加载 dylib
Module.load("/var/mobile/Containers/Data/Application/.../XHSPlugin.dylib");
```

### 4. 执行注入

```bash
frida -U -f com.xingin.xhs -l inject.js --no-pause
```

---

## 推荐工具总结

| 工具 | 难度 | 持久性 | 推荐度 |
|------|------|--------|--------|
| Sideloadly | ⭐ 简单 | 永久 | ⭐⭐⭐⭐⭐ |
| TrollStore + Azule | ⭐⭐ 中等 | 永久 | ⭐⭐⭐⭐ |
| AltStore | ⭐⭐ 中等 | 永久 | ⭐⭐⭐⭐ |
| Frida | ⭐⭐⭐⭐ 复杂 | 临时 | ⭐⭐⭐ (测试用) |

---

## 常见问题

### Q: 注入后应用闪退？
A: 检查 dylib 架构是否匹配（arm64），查看设备日志。

### Q: 插件没有生效？
A: 确认 Bundle ID 匹配，检查 plist 配置是否正确。

### Q: 如何查看日志？
A: 使用 `idevicesyslog` 或 Xcode 的 Console 查看，搜索 "XHSPlugin"。
