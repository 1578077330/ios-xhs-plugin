#!/bin/bash

echo "==================================="
echo "XHSPlugin - Build Script"
echo "==================================="

# 检查 Theos
if [ -z "$THEOS" ]; then
    echo "Error: THEOS environment variable not set!"
    echo "Please install Theos first and set THEOS environment variable."
    exit 1
fi

echo "Theos found at: $THEOS"

# 清理旧的构建
echo ""
echo "Cleaning previous builds..."
make clean

# 编译
echo ""
echo "Building package..."
make package

if [ $? -eq 0 ]; then
    echo ""
    echo "==================================="
    echo "Build successful!"
    echo "==================================="
    
    # 列出生成的包
    if [ -d "packages" ]; then
        echo ""
        echo "Generated packages:"
        ls -lh packages/
    fi
else
    echo ""
    echo "==================================="
    echo "Build failed!"
    echo "==================================="
    exit 1
fi
