# PR 标题

docs: 添加插件复用性和平台兼容性文档

---

# PR 描述

## 概述

为 Claude Code 插件系统添加了完整的复用性和平台兼容性文档，帮助用户了解如何在公司内部（特别是使用 GitLab/Bitbucket 的团队）部署和使用这些插件。

## 变更内容

### 新增文档

1. **PLATFORM_COMPATIBILITY.md** - 平台兼容性完整指南
   - 8 个插件的详细兼容性矩阵（GitHub、GitLab、Bitbucket）
   - 针对不同平台的推荐配置
   - GitLab/Bitbucket 代码审查工作流指南
   - CI/CD 集成示例

2. **gitlab-bitbucket-marketplace-example.json** - GitLab/Bitbucket 专用配置
   - 排除了 GitHub 专用的 code-review 插件
   - 包含 7 个适用于所有平台的插件
   - 添加了详细的标签和说明

3. **company-marketplace-example.json** - 通用公司配置示例
   - 包含所有 8 个插件的配置
   - 添加了 GitHub 专用标签标注

## 关键发现

### ✅ 可跨平台复用（7/8）

以下插件适用于所有 Git 平台：
- commit-commands（Git 工作流）
- feature-dev（特性开发）
- pr-review-toolkit（PR 审查）
- agent-sdk-dev（SDK 开发）
- security-guidance（安全检查）
- explanatory-output-style（教育模式）
- learning-output-style（学习模式）

### ❌ 仅限 GitHub（1/8）

- **code-review** - 硬性依赖 GitHub CLI，无法在 GitLab/Bitbucket 上使用

### 💡 GitLab/Bitbucket 替代方案

对于 GitLab/Bitbucket 用户，推荐使用 **pr-review-toolkit** 替代 code-review：
- 包含 6 个专化代理（vs code-review 的 4 个）
- 功能更全面（测试覆盖率、错误处理、类型设计、代码简化）
- 基于 git diff 分析，平台无关

## 使用场景

此文档特别适合以下场景：
- 公司内部使用 GitLab 或 Bitbucket
- 希望统一团队的 Claude Code 插件配置
- 需要了解插件的平台兼容性
- 想要在 CI/CD 中集成代码审查

## 文件变更

```
docs/
├── PLATFORM_COMPATIBILITY.md          (新增 - 平台兼容性指南)
├── gitlab-bitbucket-marketplace-example.json  (新增 - GitLab/Bitbucket 配置)
└── company-marketplace-example.json   (更新 - 添加平台标注)
```

## 测试计划

- [x] 验证所有插件的 marketplace 配置格式正确
- [x] 确认平台兼容性信息准确
- [x] 检查文档的完整性和可读性

## 相关 Issue

回答了用户关于"插件能否直接拿来就可用"的问题，特别是针对 GitLab/Bitbucket 平台的兼容性。

---

🤖 Generated with Claude Code
