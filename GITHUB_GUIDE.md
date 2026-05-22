# GitHub Actions 免费编译指南

## 🎯 目标

不用租 Mac，用 GitHub Actions 免费在线编译！

---

## 📝 步骤

### 第1步：创建 GitHub 账号
1. 访问 https://github.com
2. 注册/登录账号

---

### 第2步：创建新仓库
1. 点击右上角的 "+" → "New repository"
2. 仓库名称：`ios-xhs-plugin`
3. 选择 Public（公开）
4. 点击 "Create repository"

---

### 第3步：上传文件到 GitHub

#### 方法一：用 GitHub Desktop（推荐）

1. 下载 GitHub Desktop：https://desktop.github.com/
2. 安装并登录
3. 点击 "File" → "Add Local Repository"
4. 选择你的 `ios-xhs-plugin` 文件夹
5. 点击 "Publish repository"

#### 方法二：用 Git 命令行（如果你有 Git）

```bash
cd ios-xhs-plugin
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/你的用户名/ios-xhs-plugin.git
git push -u origin main
```

---

### 第4步：等待自动编译！

上传成功后：
1. 在 GitHub 仓库页面，点击 "Actions" 标签
2. 你会看到 "Build XHSPlugin" 工作流正在运行
3. 等待 2-5 分钟...
4. 编译完成！

---

### 第5步：下载编译好的文件！

1. 在 Actions 页面，点击最新的一次构建
2. 向下滚动到 "Artifacts" 部分
3. 下载 `XHSPlugin-dylib`
4. 解压后你会得到：
   - `XHSPlugin.dylib`
   - `XHSPlugin.plist`

---

## ✅ 完成！

拿到这两个文件后，就可以用你的注入软件注入到小红书 IPA 了！

---

## 🆘 常见问题

### Q: Actions 没有运行？
A: 确保 `.github/workflows/build.yml` 文件已经上传到 GitHub。

### Q: 编译失败？
A: 查看 Actions 页面的日志，看看哪里出错了。

### Q: 下载的文件在哪里？
A: 在 Actions 构建页面底部的 "Artifacts" 部分。
