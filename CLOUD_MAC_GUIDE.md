# 云 Mac 编译完全指南

## 推荐的云 Mac 服务

| 服务 | 价格 | 特点 |
|------|------|------|
| MacinCloud | ~$1/小时 | 稳定，按小时付费 |
| MacStadium | 按需付费 | 企业级 |
| CircleCI | 按使用付费 | 适合 CI/CD |

**推荐：MacinCloud 的 Pay-As-You-Go 计划**

---

## 完整步骤（从租 Mac 到拿到 dylib）

### 第一步：租用云 Mac

1. 访问 https://www.macincloud.com/
2. 注册账号
3. 选择 "Pay-As-You-Go" 计划
4. 支付并启动 Mac 实例
5. 通过远程桌面连接（RDP）进入 Mac

---

### 第二步：在云 Mac 上下载项目

你需要把你的项目文件传到云 Mac 上。有几种方法：

#### 方法 A：上传到网盘（推荐）

1. 在 Windows 上把整个 `ios-xhs-plugin` 文件夹压缩成 zip
2. 上传到百度网盘/OneDrive/Google Drive
3. 在云 Mac 上下载并解压

#### 方法 B：使用 GitHub

1. 在 Windows 上把项目推送到 GitHub
2. 在云 Mac 上克隆：
   ```bash
   git clone https://github.com/你的用户名/ios-xhs-plugin.git
   ```

---

### 第三步：在云 Mac 上安装环境

打开云 Mac 上的 **Terminal**（终端）应用，依次执行：

#### 1. 安装 Homebrew（包管理器）

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

安装完成后，执行提示的两个命令来配置环境变量（类似这样的）：
```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

#### 2. 安装依赖

```bash
brew install ldid xz git
```

#### 3. 安装 Theos

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/theos/theos/master/bin/install-theos)"
```

安装完成后，配置环境变量：
```bash
echo 'export THEOS=~/theos' >> ~/.zprofile
echo 'export PATH=$THEOS/bin:$PATH' >> ~/.zprofile
source ~/.zprofile
```

#### 4. 下载 iOS SDK（如果需要）

```bash
# 检查是否已有 SDK
ls -la $THEOS/sdks/

# 如果没有，下载最新的 SDK
# 可以从 https://github.com/theos/sdks 下载
```

---

### 第四步：编译项目！

进入你的项目文件夹：

```bash
cd ios-xhs-plugin
```

然后运行我为你准备的自动编译脚本：

```bash
bash compile_on_mac.sh
```

或者手动编译：

```bash
# 清理旧的构建
make clean

# 编译
make package
```

---

### 第五步：获取 dylib 文件

编译成功后，你会看到两个文件出现在项目文件夹里：
- `XHSPlugin.dylib`
- `XHSPlugin.plist`

把这两个文件下载回你的 Windows 电脑！

#### 下载方法：

1. **网盘方式**：把这两个文件上传到网盘，在 Windows 上下载
2. **邮件方式**：发给自己邮件
3. **远程桌面复制**：如果远程桌面支持文件传输，直接复制

---

### 第六步：回到 Windows 使用

拿到 `XHSPlugin.dylib` 和 `XHSPlugin.plist` 后：

1. 下载 Sideloadly：https://sideloadly.io/
2. 打开 Sideloadly
3. 拖入小红书 IPA 文件
4. 点击 **Advanced Options**
5. 在 **Inject dylibs/frameworks** 中添加 `XHSPlugin.dylib`
6. 点击 **Start** 开始注入
7. 等待完成，拿到注入好的 IPA
8. 传到手机用 TrollStore 安装

---

## 常见问题

### Q: 编译失败怎么办？
A: 检查以下几点：
- Theos 环境变量是否正确设置：`echo $THEOS`
- 是否在项目文件夹里
- SDK 是否存在：`ls $THEOS/sdks/`

### Q: 怎么确认编译成功？
A: 看到类似这样的输出就是成功：
```
> Making all for tweak XHSPlugin…
> Making stage for tweak XHSPlugin…
> Making package…
```

### Q: 需要租多长时间的 Mac？
A: 第一次配置环境大约需要 30-60 分钟，之后编译只需要 1-2 分钟。建议租 1-2 小时足够了。

### Q: 以后修改了代码还要重新租 Mac 吗？
A: 是的，每次修改代码后都需要重新编译。你可以：
- 保留 dylib 文件，下次小修改直接改代码重新编译
- 或者用版本控制，只在需要时租 Mac 编译

---

## 快速命令速查

在云 Mac 终端里执行：

```bash
# 1. 配置环境（第一次）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install ldid xz git
bash -c "$(curl -fsSL https://raw.githubusercontent.com/theos/theos/master/bin/install-theos)"
echo 'export THEOS=~/theos' >> ~/.zprofile
echo 'export PATH=$THEOS/bin:$PATH' >> ~/.zprofile
source ~/.zprofile

# 2. 进入项目并编译
cd ios-xhs-plugin
bash compile_on_mac.sh

# 3. 或者手动编译
make clean
make package
```

就这么简单！祝你顺利！🎉
