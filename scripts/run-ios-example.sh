#!/bin/bash

# FMNetCore iOS 示例运行脚本

echo "📱 运行 FMNetCore iOS 示例"

# 进入iOS示例目录
cd "$(dirname "$0")/../Examples/iOSExample/iOSExample"

# 检查是否需要解析依赖
if [ ! -d ".build" ]; then
    echo "📦 解析依赖..."
    swift package resolve
    
    if [ $? -eq 0 ]; then
        echo "✅ 依赖解析成功"
    else
        echo "❌ 依赖解析失败"
        exit 1
    fi
fi

echo "🏃 构建iOS示例..."
swift build

if [ $? -eq 0 ]; then
    echo "✅ iOS示例构建成功"
    echo ""
    echo "要运行iOS示例，请执行以下步骤："
    echo "1. 打开Xcode"
    echo "2. 创建一个新的iOS项目"
    echo "3. 通过File > Add Packages...添加FMNetCore包"
    echo "4. 将Examples/iOSExample/iOSExample目录中的所有文件添加到你的项目中"
    echo "5. 构建并运行应用"
else
    echo "❌ iOS示例构建失败"
    exit 1
fi