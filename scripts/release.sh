#!/bin/bash

# FMNetCore 发布脚本

echo "🚀 发布 FMNetCore 新版本"

# 检查是否提供了版本号
if [ $# -eq 0 ]; then
    echo "❌ 请提供版本号"
    echo "用法: ./release.sh <version>"
    echo "例如: ./release.sh 1.0.0"
    exit 1
fi

VERSION=$1

echo "📦 发布版本 $VERSION"

# 进入项目目录
cd "$(dirname "$0")/../"

# 检查是否有未提交的更改
if [ -n "$(git status --porcelain)" ]; then
    echo "❌ 有未提交的更改，请先提交所有更改"
    exit 1
fi

echo "✅ 工作目录干净"

# 更新版本号
echo "📝 更新版本号..."

# 更新 Package.swift 中的版本号
# 注意：这需要根据实际的 Package.swift 结构进行调整
# sed -i '' "s/\/\/ swift-tools-version:.*/\/\/ swift-tools-version:5.7/" Package.swift

# 更新 CHANGELOG.md
echo "📝 更新 CHANGELOG.md..."
# 这里可以添加更复杂的逻辑来自动更新 CHANGELOG

# 创建 Git 标签
echo "🏷️ 创建 Git 标签..."
git tag -a "v$VERSION" -m "Release version $VERSION"

# 推送标签
echo "📤 推送标签..."
git push origin "v$VERSION"

echo "✅ 版本 $VERSION 发布成功!"
echo "🔗 GitHub 发布页面: https://github.com/your-username/FMNetCore/releases/tag/v$VERSION"