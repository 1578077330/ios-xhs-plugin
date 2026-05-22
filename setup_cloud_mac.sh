#!/bin/bash

# ============================================
# XHSPlugin 云 Mac 一键安装脚本
# ============================================

echo "============================================"
echo "XHSPlugin - 云 Mac 一键安装"
echo "============================================"

# 检查是否在 macOS 上
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ 错误：此脚本需要在 macOS 上运行"
    exit 1
fi

echo ""
echo "📦 第一步：安装 Homebrew..."

# 检查 Homebrew 是否已安装
if ! command -v brew &> /dev/null; then
    echo "正在安装 Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # 配置 Homebrew 环境变量
    echo "配置 Homebrew 环境变量..."
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "✅ Homebrew 已安装"
fi

echo ""
echo "🔧 第二步：安装依赖工具..."
brew install ldid xz git

echo ""
echo "🛠️ 第三步：安装 Theos..."

if [ ! -d "$HOME/theos" ]; then
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/theos/theos/master/bin/install-theos)"
else
    echo "✅ Theos 已安装"
fi

echo ""
echo "⚙️ 第四步：配置环境变量..."

echo 'export THEOS=~/theos' >> ~/.zprofile
echo 'export PATH=$THEOS/bin:$PATH' >> ~/.zprofile
source ~/.zprofile

echo ""
echo "============================================"
echo "✅ 安装完成！"
echo "============================================"
echo ""
echo "验证安装："
echo "THEOS 路径: $THEOS"
echo ""
echo "下一步："
echo "1. 把 ios-xhs-plugin 文件夹放到用户目录"
echo "2. 运行: cd ios-xhs-plugin"
echo "3. 运行: mv Tweak_Final.xm Tweak.xm"
echo "4. 运行: bash compile_on_mac.sh"
echo ""
