# 关于代码的重要说明

## ⚠️ 真实情况

**这段代码没有在真实的小红书应用上测试过！**

## 📁 三个版本的 Tweak

我为你准备了三个版本，你可以选择最合适的：

### 1. Tweak.xm（原版）
- 尝试自动显示 UI 菜单
- Hook AppDelegate
- 可能需要根据小红书实际情况调整

### 2. Tweak_Simple.xm（简单版）
- 更简洁的代码
- 通过通知或摇一摇触发
- 更容易调试

### 3. Tweak_Manual.xm（手动版）⭐推荐
- 不自动显示 UI
- 提供导出函数供你手动调用
- 最稳定，最不容易出错
- 你可以通过 Frida 或其他工具调用这些函数

## 🔧 推荐使用方式

### 方式一：使用 Tweak_Manual.xm（最稳妥）

1. 把 `Tweak_Manual.xm` 重命名为 `Tweak.xm`
2. 编译出 dylib
3. 注入到小红书
4. 用 Frida 调用函数测试：

```javascript
// Frida 脚本示例
const module = Process.findModuleByName("XHSPlugin.dylib");

if (module) {
    console.log("找到插件！");
    
    // 调用清理函数
    const cleanKeychain = new NativeFunction(
        Module.findExportByName(null, "XHSPlugin_CleanKeychain"),
        'void', []
    );
    cleanKeychain();
    
    // 或者调用完整重置
    const fullReset = new NativeFunction(
        Module.findExportByName(null, "XHSPlugin_FullReset"),
        'void', ['pointer']
    );
    fullReset(Memory.allocUtf8String("com.xiaohongshu.new"));
}
```

### 方式二：先用 Frida 测试逻辑

在编译之前，你可以先用 Frida 测试清理逻辑是否有效：

```javascript
// Frida 测试脚本
console.log("测试 Keychain 清理");

// 这里可以写测试代码
```

## 🐛 常见问题排查

### 如果注入后闪退

1. 查看设备日志：`idevicesyslog | grep XHSPlugin`
2. 尝试使用 Tweak_Manual.xm（最简化版本）
3. 检查架构是否匹配（arm64）

### 如果功能不工作

1. 先看日志确认插件是否加载
2. 用 Frida 手动调用函数测试
3. 检查小红书版本兼容性

## 💡 建议

1. **先用 Tweak_Manual.xm 测试**，这个最稳定
2. **用 Frida 先验证功能**，确认有效再编译
3. **查看日志**，有问题先看 `NSLog` 输出
4. **从小红书旧版本开始测试**，兼容性可能更好

## 📞 需要帮助？

如果遇到问题，可以：
1. 提供设备日志
2. 说明小红书版本
3. 描述具体的错误现象
