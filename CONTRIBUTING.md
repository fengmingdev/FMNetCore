# 贡献指南

感谢您考虑为 FMNetCore 做出贡献！我们欢迎各种形式的贡献，包括但不限于：

- 报告 bug
- 提交修复
- 添加新功能
- 改进文档
- 提出改进建议

## 行为准则

请遵守我们的行为准则，确保为每个人创造一个友好的环境。

## 开发规则

在开始贡献之前，请阅读我们的 [开发规则文档](RULES.md)，了解项目中的编码规范和最佳实践，避免重复遇到已知问题。

## 如何贡献

### 报告 Bug

在提交 bug 报告之前，请检查是否已经有类似的报告。如果找不到，请创建一个新的 issue，包含以下信息：

- 清晰的标题和描述
- 尽可能详细的步骤来重现问题
- 期望的行为和实际行为
- 环境信息（操作系统、Swift 版本等）
- 如果可能，提供示例代码或项目

### 提交修复

1. Fork 仓库
2. 创建一个新分支 (`git checkout -b fix/issue-name`)
3. 进行修改
4. 添加测试（如果适用）
5. 确保所有测试都通过
6. 提交更改 (`git commit -am 'Fix: description of fix'`)
7. 推送到分支 (`git push origin fix/issue-name`)
8. 创建一个新的 Pull Request

### 添加新功能

1. Fork 仓库
2. 创建一个新分支 (`git checkout -b feature/feature-name`)
3. 实现新功能
4. 添加文档
5. 添加测试
6. 确保所有测试都通过
7. 提交更改 (`git commit -am 'Add: description of feature'`)
8. 推送到分支 (`git push origin feature/feature-name`)
9. 创建一个新的 Pull Request

## 开发环境设置

1. 克隆仓库：
   ```
   git clone https://github.com/your-username/FMNetCore.git
   ```

2. 进入项目目录：
   ```
   cd FMNetCore
   ```

3. 解析依赖：
   ```
   swift package resolve
   ```

4. 生成 Xcode 项目（可选）：
   ```
   swift package generate-xcodeproj
   ```

## 编码规范

- 遵循 Swift 的官方编码规范
- 使用有意义的变量和函数名
- 添加适当的注释
- 保持代码简洁和可读性
- 遵循项目现有的代码风格
- 参考 [开发规则文档](RULES.md) 中的详细规范

## 测试

- 所有新功能都应包含测试
- 确保所有现有测试都通过
- 测试覆盖率应尽可能高
- 运行测试：
  ```
  swift test
  ```

## 文档

- 更新相关文档以反映代码更改
- 为新功能添加文档
- 确保文档清晰、准确
- 使用 Markdown 格式编写文档

## 提交信息

请使用清晰、简洁的提交信息。建议使用以下格式：

- `Fix: description of fix` - 修复 bug
- `Add: description of feature` - 添加新功能
- `Update: description of update` - 更新现有功能
- `Remove: description of removal` - 删除功能
- `Docs: description of documentation change` - 文档更改
- `Test: description of test change` - 测试更改

## 代码审查

所有 Pull Request 都需要经过代码审查。请耐心等待维护者的反馈，并根据反馈进行相应的修改。

## 许可证

通过贡献代码，您同意您的贡献将根据 MIT 许可证进行许可。

## 联系方式

如果您有任何问题或需要帮助，请通过以下方式联系我们：

- 创建一个新的 issue
- 发送邮件到项目维护者