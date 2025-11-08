# Claude Code 插件一键安装指南

本文档提供 Claude Code 插件的快速安装指南，帮助你快速上手使用插件系统。

## 📚 目录

- [快速开始](#快速开始)
- [安装方法](#安装方法)
  - [方法一：一键安装（推荐）](#方法一一键安装推荐)
  - [方法二：交互式安装](#方法二交互式安装)
  - [方法三：团队级配置](#方法三团队级配置)
- [平台兼容性](#平台兼容性)
- [插件功能说明](#插件功能说明)
- [Skills vs 命令](#skills-vs-命令)
- [常见问题](#常见问题)

---

## 🚀 快速开始

### 前置条件

确保已安装 Claude Code：

```bash
npm install -g @anthropic-ai/claude-code
```

### 30秒快速安装

```bash
# 1. 启动 Claude Code
claude

# 2. 添加官方插件市场
/plugin marketplace add anthropics/claude-code-plugins

# 3. 一键安装推荐插件
/plugin install commit-commands@claude-code-plugins
/plugin install security-guidance@claude-code-plugins
/plugin install feature-dev@claude-code-plugins

# 4. 重启 Claude Code（必需）
# 按 Ctrl+C 退出，然后重新运行 claude
```

安装完成！使用 `/help` 查看新增的命令。

---

## 安装方法

### 方法一：一键安装（推荐）

#### GitHub 用户完整套装

```bash
# 添加市场
/plugin marketplace add anthropics/claude-code-plugins

# 基础工具
/plugin install commit-commands@claude-code-plugins
/plugin install security-guidance@claude-code-plugins

# 代码审查
/plugin install code-review@claude-code-plugins
/plugin install pr-review-toolkit@claude-code-plugins

# 开发工作流
/plugin install feature-dev@claude-code-plugins
/plugin install agent-sdk-dev@claude-code-plugins

# 输出风格（可选）
/plugin install explanatory-output-style@claude-code-plugins
/plugin install learning-output-style@claude-code-plugins
```

#### GitLab/Bitbucket 用户推荐套装

```bash
# 添加市场
/plugin marketplace add anthropics/claude-code-plugins

# 基础工具
/plugin install commit-commands@claude-code-plugins
/plugin install security-guidance@claude-code-plugins

# 代码审查（使用 pr-review-toolkit，不是 code-review）
/plugin install pr-review-toolkit@claude-code-plugins

# 开发工作流
/plugin install feature-dev@claude-code-plugins
/plugin install agent-sdk-dev@claude-code-plugins
```

**⚠️ 重要提醒**：
- GitHub CLI 专用插件 `code-review` 仅支持 GitHub
- GitLab/Bitbucket 用户应使用 `pr-review-toolkit`

#### 最小化安装（核心功能）

```bash
/plugin marketplace add anthropics/claude-code-plugins
/plugin install commit-commands@claude-code-plugins
/plugin install security-guidance@claude-code-plugins
```

---

### 方法二：交互式安装

适合探索和选择性安装：

```bash
# 1. 打开插件管理界面
/plugin

# 2. 选择 "Browse Plugins"
# 3. 浏览可用插件，查看描述和功能
# 4. 选择插件并点击 "Install now"
# 5. 重启 Claude Code
```

**优点**：
- 可视化浏览所有可用插件
- 查看详细描述和功能列表
- 逐个选择需要的插件

---

### 方法三：团队级配置

在项目中自动安装插件，团队成员 trust 文件夹后自动生效。

#### 步骤 1：创建配置文件

在项目根目录创建或编辑 `.claude/settings.json`：

```json
{
  "extraKnownMarketplaces": [
    {
      "source": {
        "source": "github",
        "repo": "anthropics/claude-code-plugins"
      }
    }
  ],
  "plugins": {
    "commit-commands": {
      "enabled": true
    },
    "security-guidance": {
      "enabled": true
    },
    "feature-dev": {
      "enabled": true
    },
    "pr-review-toolkit": {
      "enabled": true
    }
  }
}
```

#### 步骤 2：提交到版本控制

```bash
git add .claude/settings.json
git commit -m "chore: Add Claude Code plugin configuration"
git push
```

#### 步骤 3：团队成员使用

团队成员克隆项目后：

```bash
cd your-project
claude
# Trust 文件夹时，插件自动安装
```

#### 平台特定配置

**GitHub 团队**：

```json
{
  "extraKnownMarketplaces": [
    {
      "source": {
        "source": "github",
        "repo": "anthropics/claude-code-plugins"
      }
    }
  ],
  "plugins": {
    "commit-commands": { "enabled": true },
    "code-review": { "enabled": true },
    "pr-review-toolkit": { "enabled": true },
    "security-guidance": { "enabled": true },
    "feature-dev": { "enabled": true }
  }
}
```

**GitLab/Bitbucket 团队**：

```json
{
  "extraKnownMarketplaces": [
    {
      "source": {
        "source": "github",
        "repo": "anthropics/claude-code-plugins"
      }
    }
  ],
  "plugins": {
    "commit-commands": { "enabled": true },
    "pr-review-toolkit": { "enabled": true },
    "security-guidance": { "enabled": true },
    "feature-dev": { "enabled": true }
  }
}
```

**注意**：GitLab/Bitbucket 不要启用 `code-review` 插件。

---

## 🌐 平台兼容性

根据 [平台兼容性指南](./PLATFORM_COMPATIBILITY.md)，官方插件的兼容性如下：

| 插件名称 | GitHub | GitLab | Bitbucket | 说明 |
|---------|--------|--------|-----------|------|
| commit-commands | ✅ | ✅ | ✅ | Git 工作流自动化 |
| feature-dev | ✅ | ✅ | ✅ | 特性开发工作流 |
| pr-review-toolkit | ✅ | ✅ | ✅ | 全平台代码审查工具 |
| agent-sdk-dev | ✅ | ✅ | ✅ | Agent SDK 开发工具 |
| security-guidance | ✅ | ✅ | ✅ | 安全提示钩子 |
| explanatory-output-style | ✅ | ✅ | ✅ | 教育性输出风格 |
| learning-output-style | ✅ | ✅ | ✅ | 交互式学习模式 |
| **code-review** | ✅ | ❌ | ❌ | **仅 GitHub（需要 GitHub CLI）** |

### 平台特定说明

#### GitHub
- 所有 8 个插件都可用
- `code-review` 自动发布 PR 评论
- `pr-review-toolkit` 提供更深入的分析

#### GitLab
- 7 个插件可用（除 `code-review`）
- 使用 `pr-review-toolkit` 进行代码审查
- 可配置 CI/CD 使用 `glab` CLI 发布评论

#### Bitbucket
- 7 个插件可用（除 `code-review`）
- 使用 `pr-review-toolkit` 进行代码审查
- 可通过 Bitbucket API 集成到 Pipeline

---

## 🔌 插件功能说明

### 核心工具插件

#### commit-commands
**Git 工作流自动化**

```bash
/commit              # 创建 commit
/commit-push-pr      # Commit + Push + 创建 PR
/clean_gone          # 清理过时的本地分支
```

**适用场景**：日常开发，快速提交代码

---

#### security-guidance
**安全提示钩子**

自动检测安全漏洞：
- XSS 跨站脚本
- SQL 注入
- 命令注入
- 不安全的代码模式

**适用场景**：所有项目，提升代码安全性

---

### 代码审查插件

#### pr-review-toolkit（推荐）
**全平台代码审查工具包**

6 个专化代理：
- `comment-analyzer` - 注释质量分析
- `pr-test-analyzer` - 测试覆盖率检查
- `silent-failure-hunter` - 错误处理检查
- `type-design-analyzer` - 类型设计分析
- `code-reviewer` - 代码质量审查
- `code-simplifier` - 代码简化建议

```bash
/pr-review-toolkit:review-pr all              # 完整审查
/pr-review-toolkit:review-pr tests errors     # 特定方面审查
/pr-review-toolkit:review-pr all parallel     # 并行审查（更快）
```

**适用场景**：所有平台的 PR/MR 审查

---

#### code-review（仅 GitHub）
**自动化 PR 代码审查**

```bash
/code-review    # 自动审查并发布评论到 GitHub PR
```

**特点**：
- 置信度评分（≥80 阈值）
- 自动发布评论到 GitHub
- CLAUDE.md 合规检查

**适用场景**：GitHub PR 快速自动审查

---

### 开发工作流插件

#### feature-dev
**完整特性开发工作流**

7 阶段开发流程 + 3 个专化代理：
- `code-explorer` - 深度代码分析
- `code-architect` - 架构设计
- `code-reviewer` - 代码审查

```bash
/feature-dev    # 启动特性开发工作流
```

**适用场景**：新功能开发，系统性代码理解

---

#### agent-sdk-dev
**Agent SDK 开发工具**

```bash
/new-sdk-app    # 创建新的 Agent SDK 应用
```

**专化代理**：
- `agent-sdk-verifier-py` - Python SDK 验证
- `agent-sdk-verifier-ts` - TypeScript SDK 验证

**适用场景**：开发 Claude Agent SDK 应用

---

### 输出风格插件

#### explanatory-output-style
教育性输出，详细解释每个步骤

#### learning-output-style
交互式学习模式，引导式教学

---

### 文档生成插件（示例）

#### doc-generator-with-skills
**Skills 集成示例插件**

展示如何在插件中集成 Skills：
- `api-docs-generator` - API 文档生成
- `changelog-generator` - CHANGELOG 维护

**用途**：参考示例，学习 Skills 集成模式

**详细文档**：[Skills 集成指南](./INTEGRATING-SKILLS-IN-PLUGINS.md)

---

## 🎯 Skills vs 命令

基于 [Skills 集成指南](./INTEGRATING-SKILLS-IN-PLUGINS.md)，理解两者的区别非常重要：

### 对比表

| 特性 | Skills | Slash Commands |
|-----|--------|---------------|
| **调用方式** | 模型自动调用 | 用户手动调用 |
| **触发条件** | 基于上下文和关键词 | 明确输入 `/command` |
| **文件位置** | `skills/skill-name/SKILL.md` | `commands/command-name.md` |
| **发现机制** | 基于 description 字段 | 列在 `/help` 中 |
| **最佳场景** | 上下文感知的自动辅助 | 特定工作流程 |
| **示例** | API 文档生成器 | `/commit` 命令 |

### 使用示例

**Slash Command（显式调用）**：
```bash
用户: "/generate-docs"
Claude: [执行命令]
```

**Skill（上下文自动调用）**：
```bash
用户: "能帮我生成 API 文档吗？"
Claude: [自动激活 api-docs-generator skill]
```

### 何时使用 Skills

✅ **提供上下文感知的辅助** - 基于对话自动帮助用户
✅ **减少命令记忆负担** - 用户无需记住具体命令名
✅ **增强可发现性** - 用户自然描述需求即可
✅ **组合能力** - 多个 Skills 可在一次对话中激活

### 何时使用 Slash Commands

✅ **提供明确的工作流** - 用户需要精确控制
✅ **组合复杂操作** - 多步骤流程，清晰的入口点
✅ **可发现的操作** - 用户可浏览可用命令

### 最佳实践

**许多插件同时包含 Skills 和 Commands**，提供灵活性：
- Commands：用户明确知道要做什么时使用
- Skills：Claude 根据对话上下文自动辅助

**示例**：`doc-generator-with-skills` 插件
- Skills：`api-docs-generator`、`changelog-generator`（自动激活）
- 可能的 Commands：`/force-regenerate-docs`（明确控制）

---

## 📖 创建自定义插件

### 基本插件结构

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json              # 插件元数据（必需）
├── skills/                      # Skills 目录（可选）
│   └── my-skill/
│       ├── SKILL.md            # Skill 定义
│       ├── scripts/            # 辅助脚本
│       └── templates/          # 模板
├── commands/                    # 命令目录（可选）
│   └── my-command.md
├── agents/                      # 代理目录（可选）
│   └── my-agent.md
├── hooks/                       # 钩子目录（可选）
│   └── hooks.json
└── README.md                   # 插件文档
```

### plugin.json 示例

```json
{
  "name": "my-plugin",
  "description": "My custom Claude Code plugin",
  "version": "1.0.0",
  "author": {
    "name": "Your Name",
    "email": "you@example.com"
  },
  "homepage": "https://github.com/you/my-plugin",
  "repository": "https://github.com/you/my-plugin",
  "license": "MIT",
  "keywords": ["productivity", "development"]
}
```

**必需字段**：仅 `name`
**推荐字段**：`description`、`version`、`author`

### 创建 Skill

在 `skills/my-skill/SKILL.md`：

```markdown
---
name: my-skill
description: Generate unit tests for Python, JavaScript, and TypeScript code. Use when user asks to create tests, write test cases, add test coverage, or generate test suites.
---

# My Skill

This skill does X when the user wants to Y.

## When to Use This Skill

Activate when the user:
- Says "do X"
- Asks to "accomplish Y"
- Needs to "perform Z"

## Instructions

1. First, analyze the request
2. Then, gather necessary information
3. Finally, complete the task

## Output Format

Provide results in this format:
[Details about expected output]
```

**关键点**：
- `description` 字段决定何时激活（最重要！）
- 包含具体关键词和触发短语
- 提供清晰的分步指导

### 创建命令

在 `commands/my-command.md`：

```markdown
---
description: Brief description of the command
---

# My Command

Instructions for what to do when this command is invoked.

1. Step 1
2. Step 2
3. Step 3
```

---

## 🛠️ 常见问题

### 安装后看不到新命令？

**解决方案**：必须重启 Claude Code

```bash
# 按 Ctrl+C 退出
# 重新启动
claude
# 验证安装
/help
```

---

### 插件在 GitLab/Bitbucket 上不工作？

**检查清单**：
- ❌ 是否安装了 `code-review`？（仅 GitHub 支持）
- ✅ 改用 `pr-review-toolkit`
- ✅ 参考[平台兼容性指南](./PLATFORM_COMPATIBILITY.md)

---

### 如何查看已安装的插件？

```bash
/plugin
# 查看已安装插件列表
# 可以启用/禁用/卸载
```

---

### 如何更新插件？

```bash
/plugin uninstall plugin-name@marketplace
/plugin install plugin-name@marketplace
```

---

### Skills 没有自动激活？

**调试步骤**：

1. **检查 description**：是否包含足够的关键词？
   ```yaml
   # ❌ 太模糊
   description: Helps with code

   # ✅ 具体且关键词丰富
   description: Generate unit tests for Python, JavaScript, and TypeScript code. Use when user asks to create tests, write test cases, add test coverage, or generate test suites.
   ```

2. **检查 YAML 格式**：是否有关闭的 `---` 分隔符？

3. **测试触发短语**：尝试在对话中使用 description 中的关键词

---

### 如何分享自定义插件？

**方法 1：GitHub Marketplace**

1. 创建 GitHub 仓库
2. 添加插件文件
3. 提交并推送
4. 团队成员添加：
   ```bash
   /plugin marketplace add your-org/your-plugin-repo
   /plugin install your-plugin@your-org
   ```

**方法 2：项目配置**

在 `.claude/settings.json` 中：

```json
{
  "extraKnownMarketplaces": [
    {
      "source": {
        "source": "github",
        "repo": "your-org/your-plugin-repo"
      }
    }
  ],
  "plugins": {
    "your-plugin": {
      "enabled": true
    }
  }
}
```

---

## 📚 参考资源

### 官方文档
- [Claude Code 插件文档](https://code.claude.com/docs/en/plugins)
- [Skills 文档](https://code.claude.com/docs/en/skills)
- [插件 API 参考](https://code.claude.com/docs/en/plugins-reference)
- [插件市场文档](https://code.claude.com/docs/en/plugin-marketplaces)

### 本仓库文档
- [平台兼容性指南](./PLATFORM_COMPATIBILITY.md) - 各平台插件兼容性详情
- [Skills 集成指南](./INTEGRATING-SKILLS-IN-PLUGINS.md) - 深入的 Skills 开发教程
- [插件 README](../plugins/README.md) - 官方插件概览

### 示例插件
- [doc-generator-with-skills](../plugins/doc-generator-with-skills/) - Skills 集成示例
- [commit-commands](../plugins/commit-commands/) - Git 工作流自动化
- [feature-dev](../plugins/feature-dev/) - 特性开发工作流
- [pr-review-toolkit](../plugins/pr-review-toolkit/) - 代码审查工具包

### 社区资源
- [Claude Cookbooks - Skills](https://github.com/anthropics/claude-cookbooks/tree/main/skills)
- [Claude Developers Discord](https://anthropic.com/discord)

---

## 🎉 总结

### 最快上手（1 分钟）

```bash
claude
/plugin marketplace add anthropics/claude-code-plugins
/plugin install commit-commands@claude-code-plugins
/plugin install security-guidance@claude-code-plugins
# 重启 Claude Code
```

### 推荐安装（GitHub）

```bash
/plugin marketplace add anthropics/claude-code-plugins
/plugin install commit-commands@claude-code-plugins
/plugin install security-guidance@claude-code-plugins
/plugin install code-review@claude-code-plugins
/plugin install pr-review-toolkit@claude-code-plugins
/plugin install feature-dev@claude-code-plugins
# 重启 Claude Code
```

### 推荐安装（GitLab/Bitbucket）

```bash
/plugin marketplace add anthropics/claude-code-plugins
/plugin install commit-commands@claude-code-plugins
/plugin install security-guidance@claude-code-plugins
/plugin install pr-review-toolkit@claude-code-plugins
/plugin install feature-dev@claude-code-plugins
# 重启 Claude Code
```

### 下一步

1. ✅ 安装推荐插件
2. ✅ 运行 `/help` 查看可用命令
3. ✅ 尝试使用 Skills（自然对话即可激活）
4. ✅ 阅读 [Skills 集成指南](./INTEGRATING-SKILLS-IN-PLUGINS.md) 创建自定义插件
5. ✅ 查看 [平台兼容性指南](./PLATFORM_COMPATIBILITY.md) 了解平台特定配置

---

**有问题或反馈？**

- 📖 查看 [官方文档](https://code.claude.com/docs/en/plugins)
- 💬 加入 [Claude Developers Discord](https://anthropic.com/discord)
- 🐛 报告问题到 [GitHub Issues](https://github.com/anthropics/claude-code/issues)

---

**最后更新**：2025-11-08
**版本**：1.0.0
