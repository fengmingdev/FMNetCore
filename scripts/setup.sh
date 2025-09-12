#!/bin/bash

# FMNetCore 设置脚本

echo "🚀 设置 FMNetCore 开发环境"

# 检查是否安装了 Swift
if ! command -v swift &> /dev/null
then
    echo "❌ Swift 未安装，请先安装 Xcode 或 Swift 工具链"
    exit 1
fi

echo "✅ Swift 已安装"

# 进入项目目录
cd "$(dirname "$0")/../"

# 解析依赖
echo "📦 解析依赖..."
swift package resolve

if [ $? -eq 0 ]; then
    echo "✅ 依赖解析成功"
else
    echo "❌ 依赖解析失败"
    exit 1
fi

# 构建项目
echo "🏗️ 构建项目..."
swift build

if [ $? -eq 0 ]; then
    echo "✅ 项目构建成功"
else
    echo "❌ 项目构建失败"
    exit 1
fi

# 运行测试
echo "🧪 运行测试..."
swift test

if [ $? -eq 0 ]; then
    echo "✅ 所有测试通过"
else
    echo "❌ 测试失败"
    exit 1
fi

echo "🎉 FMNetCore 开发环境设置完成!"

echo ""
echo "下一步:"
echo "1. 运行示例应用: swift run -c release ExampleApp"
echo "2. 生成 Xcode 项目: swift package generate-xcodeproj"
echo "3. 查看文档: 打开 Documentation/ 目录"