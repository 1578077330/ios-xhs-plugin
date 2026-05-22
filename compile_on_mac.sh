#!/bin/bash

# XHSPlugin - macOS 编译脚本
# 在 Mac 上运行此脚本来编译 dylib

echo "==================================="
echo "XHSPlugin - macOS 编译脚本"
echo "==================================="

# 检查是否在 macOS 上
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "错误：此脚本需要在 macOS 上运行"
    exit 1
fi

# 检查 Theos
if [ -z "$THEOS" ]; then
    echo "Theos 未设置，正在安装..."
    
    # 安装 Theos
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/theos/theos/master/bin/install-theos)"
    
    # 设置环境变量
    export THEOS=~/theos
    export PATH=$THEOS/bin:$PATH
    
    echo "Theos 安装完成！"
else
    echo "Theos 已找到: $THEOS"
fi

# 检查 Xcode 命令行工具
if ! xcode-select -p &>/dev/null; then
    echo "正在安装 Xcode 命令行工具..."
    xcode-select --install
    echo "请等待安装完成后重新运行此脚本"
    exit 1
fi

# 清理并编译
echo ""
echo "正在清理旧构建..."
make clean

echo ""
echo "正在编译..."
make package

if [ $? -eq 0 ]; then
    echo ""
    echo "==================================="
    echo "✓ 编译成功！"
    echo "==================================="
    
    # 列出生成的文件
    if [ -d "packages" ]; then
        echo ""
        echo "生成的包文件："
        ls -lh packages/
        
        # 解压 deb 以获取 dylib
        DEB_FILE=$(ls packages/*.deb | head -1)
        if [ -n "$DEB_FILE" ]; then
            echo ""
            echo "正在解压 $DEB_FILE 以获取 dylib..."
            mkdir -p extracted_deb
            dpkg -x "$DEB_FILE" extracted_deb
            
            if [ -f "extracted_deb/Library/MobileSubstrate/DynamicLibraries/XHSPlugin.dylib" ]; then
                echo ""
                echo "==================================="
                echo "✓ 找到 dylib 文件！"
                echo "==================================="
                
                # 复制到项目根目录
                cp "extracted_deb/Library/MobileSubstrate/DynamicLibraries/XHSPlugin.dylib" ./
                cp "extracted_deb/Library/MobileSubstrate/DynamicLibraries/XHSPlugin.plist" ./
                
                echo ""
                echo "文件已复制到项目根目录："
                echo "  - XHSPlugin.dylib"
                echo "  - XHSPlugin.plist"
                echo ""
                echo "现在你可以把这两个文件复制到 Windows 上使用了！"
            fi
        fi
    fi
else
    echo ""
    echo "==================================="
    echo "✗ 编译失败"
    echo "==================================="
    exit 1
fi
