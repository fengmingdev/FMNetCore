#!/bin/bash

# FMNetCore 文档生成脚本

echo "📚 生成 FMNetCore 文档"

# 进入项目目录
cd "$(dirname "$0")/../"

# 创建文档目录
mkdir -p docs

# 生成 API 文档
echo "📝 生成 API 文档..."
swift package dump-package > docs/package.json

# 复制 Markdown 文档
echo "📝 复制 Markdown 文档..."
cp -r Documentation/* docs/

# 生成主 README
echo "📝 生成主 README..."
cp README.md docs/

echo "✅ 文档生成完成!"
echo "📖 文档位于 docs/ 目录中"