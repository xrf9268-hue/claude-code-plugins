# Claude Code Extensions Library

[![Validate Plugins](https://github.com/xrf9268-hue/claude-code-plugins/actions/workflows/validate-plugins.yml/badge.svg)](https://github.com/xrf9268-hue/claude-code-plugins/actions/workflows/validate-plugins.yml)

A curated collection of plugins, hooks, skills, and development tools for [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) - the agentic coding tool that helps you code faster through natural language commands.

This repository is designed for developers who want to extend Claude Code's capabilities through custom extensions and share best practices for plugin development.

## 🎯 What's Inside

### 📦 Plugins

Production-ready plugins that extend Claude Code with custom commands, specialized agents, and automated workflows. See the [plugins directory](./plugins/README.md) for detailed documentation.

**Featured Plugins:**
- **[agent-sdk-dev](./plugins/agent-sdk-dev/)** - Streamline Claude Agent SDK application development
- **[commit-commands](./plugins/commit-commands/)** - Automate git workflows (commit, push, PR creation)
- **[code-review](./plugins/code-review/)** - Automated PR code reviews with confidence scoring
- **[feature-dev](./plugins/feature-dev/)** - Structured 7-phase feature development workflow
- **[security-guidance](./plugins/security-guidance/)** - Security best practices and vulnerability detection
- **[doc-generator-with-skills](./plugins/doc-generator-with-skills/)** - Automated documentation generation using skills
- **[plugin-developer-toolkit](./plugins/plugin-developer-toolkit/)** - Meta-plugin for building and managing plugins
- **[context-preservation](./plugins/context-preservation/)** - Optimize context window with PreCompact hook

### 📚 Documentation

Development guides and reference materials in the [docs directory](./docs/):

#### Quick Start
- **[QUICK-REFERENCE.md](./docs/QUICK-REFERENCE.md)** - 📌 One-page quick reference (bookmark this!)
- **[QUICK_PLUGIN_INSTALLATION.md](./docs/QUICK_PLUGIN_INSTALLATION.md)** - Quick start guide for plugin installation

#### Component Guides
- **[INTEGRATING-SKILLS-IN-PLUGINS.md](./docs/INTEGRATING-SKILLS-IN-PLUGINS.md)** - Complete guide to integrating skills in plugins
- **[AGENTS-DEVELOPMENT-GUIDE.md](./docs/AGENTS-DEVELOPMENT-GUIDE.md)** - Complete guide to developing agents (sub-agents)
- **[HOOKS-DEVELOPMENT-GUIDE.md](./docs/HOOKS-DEVELOPMENT-GUIDE.md)** - Complete guide to developing hooks

#### Platform & Examples
- **[PLATFORM_COMPATIBILITY.md](./docs/PLATFORM_COMPATIBILITY.md)** - Cross-platform development best practices
- **Marketplace Examples** - Sample configurations for company and GitLab/Bitbucket marketplaces

### 🔧 Examples

Sample hooks and configuration files in the [examples directory](./examples/) to help you get started with custom integrations.

### 🐳 Development Environment

Pre-configured DevContainer setup for consistent cross-platform development:
- `.devcontainer/` - DevContainer configuration
- `Script/run_devcontainer_claude_code.ps1` - Windows DevContainer helper script

## 🚀 Getting Started

### Prerequisites

1. Install Claude Code globally:
```bash
npm install -g @anthropic-ai/claude-code
```

2. Navigate to your project directory:
```bash
cd your-project
claude
```

### Installing Plugins

Use the `/plugin` command within Claude Code or configure them in your project's `.claude/settings.json`:

```json
{
  "plugins": [
    {
      "source": "github",
      "owner": "xrf9268-hue",
      "repo": "claude-code-plugins",
      "path": "plugins/commit-commands"
    }
  ]
}
```

For detailed installation instructions, see [QUICK_PLUGIN_INSTALLATION.md](./docs/QUICK_PLUGIN_INSTALLATION.md).

## 📖 Plugin Development

### Plugin Structure

Each plugin follows this standard structure:

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json          # Plugin metadata
├── commands/                 # Slash commands (optional)
│   └── command-name.md
├── agents/                   # Specialized agents (optional)
│   └── agent-name.md
├── skills/                   # Skills (optional)
│   └── skill-name/
│       └── SKILL.md
├── hooks/                    # Event hooks (optional)
│   └── hook-name.ts
└── README.md                # Plugin documentation
```

### Key Concepts

- **Slash Commands**: User-invoked actions (e.g., `/commit`, `/review`)
- **Agents**: Specialized sub-agents with defined capabilities
- **Skills**: Model-invoked capabilities that Claude uses contextually
- **Hooks**: Event handlers for workflow automation (e.g., PreCompact, PostToolUse)
- **MCP Servers**: Integration with external tools and services

### Official Resources

- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code/overview)
- [Plugins Guide](https://code.claude.com/docs/en/plugins)
- [Skills Guide](https://code.claude.com/docs/en/skills)
- [Hooks Guide](https://code.claude.com/docs/en/hooks-guide)
- [Plugins Reference](https://code.claude.com/docs/en/plugins-reference)
- [Sub-Agents Guide](https://code.claude.com/docs/en/sub-agents)
- [DevContainer Guide](https://code.claude.com/docs/en/devcontainer)

## ✅ Quality Assurance

This repository maintains high quality standards through:

- **Automated Validation**: GitHub Actions workflow validates all plugin configurations
- **Pre-commit Hooks**: Optional git hooks prevent invalid commits (install with `./Script/install-git-hooks.sh`)
- **Validation Scripts**: Run `./Script/validate-all.sh` to check your changes locally
- **Debugging Tools**: Run `./Script/debug-plugins.sh` to test plugin functionality
- **Documentation**: Comprehensive guides for plugin development and maintenance

All plugins are validated for:
- JSON syntax and schema compliance
- Hook structure correctness
- Complete metadata (keywords, repository, license)
- Security best practices

**Guides**:
- [Plugin Maintenance Guide](./docs/PLUGIN_MAINTENANCE_GUIDE.md) - Best practices and standards
- [Plugin Debugging Guide](./docs/PLUGIN_DEBUGGING_GUIDE.md) - Troubleshooting and testing

## 🤝 Contributing

Contributions are welcome! When adding new plugins:

1. Follow the standard plugin structure
2. Include comprehensive README.md with usage examples
3. Add plugin metadata in `.claude-plugin/plugin.json`
4. Document all commands, agents, and skills
5. Run `./Script/validate-all.sh` before committing
6. Test across different platforms when possible

The CI/CD pipeline will automatically validate your changes on pull requests.

## 💬 Community

Join the [Claude Developers Discord](https://anthropic.com/discord) to:
- Get help with plugin development
- Share your extensions
- Discuss best practices
- Connect with other Claude Code developers

## 📄 License

See individual plugin directories for specific licenses.

---

**Note:** This is a community-maintained collection of Claude Code extensions. For official Claude Code support and bug reports, visit the [official repository](https://github.com/anthropics/claude-code).
