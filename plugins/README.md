# Claude Code Plugins

This directory contains some official Claude Code plugins that extend functionality through custom commands, agents, and workflows. These are examples of what's possible with the Claude Code plugin system—many more plugins are available through community marketplaces.

## What are Claude Code Plugins?

Claude Code plugins are extensions that enhance Claude Code with custom slash commands, specialized agents, skills, hooks, and MCP servers. Plugins can be shared across projects and teams, providing consistent tooling and workflows.

**Plugin capabilities**:
- **Slash commands**: User-invoked actions (e.g., `/commit`, `/review`)
- **Agents**: Specialized sub-agents with defined capabilities
- **Skills**: Model-invoked tools that Claude autonomously uses based on context
- **Hooks**: Event handlers for workflow automation
- **MCP servers**: Integration with external tools and services

Learn more in the [official plugins documentation](https://docs.claude.com/en/docs/claude-code/plugins).

## Plugins in This Directory

### [agent-sdk-dev](./agent-sdk-dev/)

**Claude Agent SDK Development Plugin**

Streamlines the development of Claude Agent SDK applications with scaffolding commands and verification agents.

- **Command**: `/new-sdk-app` - Interactive setup for new Agent SDK projects
- **Agents**: `agent-sdk-verifier-py` and `agent-sdk-verifier-ts` - Validate SDK applications against best practices
- **Use case**: Creating and verifying Claude Agent SDK applications in Python or TypeScript

### [commit-commands](./commit-commands/)

**Git Workflow Automation Plugin**

Simplifies common git operations with streamlined commands for committing, pushing, and creating pull requests.

- **Commands**:
  - `/commit` - Create a git commit with appropriate message
  - `/commit-push-pr` - Commit, push, and create a PR in one command
  - `/clean_gone` - Clean up stale local branches marked as [gone]
- **Use case**: Faster git workflows with less context switching

### [code-review](./code-review/)

**Automated Pull Request Code Review Plugin**

Provides automated code review for pull requests using multiple specialized agents with confidence-based scoring to filter false positives.

- **Command**:
  - `/code-review` - Automated PR review workflow
- **Use case**: Automated code review on pull requests with high-confidence issue detection (threshold ≥80)

### [feature-dev](./feature-dev/)

**Comprehensive Feature Development Workflow Plugin**

Provides a structured 7-phase approach to feature development with specialized agents for exploration, architecture, and review.

- **Command**: `/feature-dev` - Guided feature development workflow
- **Agents**:
  - `code-explorer` - Deeply analyzes existing codebase features
  - `code-architect` - Designs feature architectures and implementation blueprints
  - `code-reviewer` - Reviews code for bugs, quality issues, and project conventions
- **Use case**: Building new features with systematic codebase understanding and quality assurance

### [security-guidance](./security-guidance/)

**Security Best Practices Plugin**

Proactive security warnings for common vulnerabilities in frontend and backend code using PreToolUse hooks.

- **Hooks**: PreToolUse security validation
- **Coverage**: 17 security rules covering XSS, command injection, unsafe patterns
- **Use case**: Prevent security vulnerabilities before code is written

### [context-preservation](./context-preservation/)

**Context Preservation Plugin**

Automatically preserves important development context before Claude compacts conversation history.

- **Hooks**: PreCompact hook
- **Features**: Saves architecture decisions, debugging insights, design rationales
- **Use case**: Never lose critical context in long coding sessions

### [frontend-dev-guidelines](./frontend-dev-guidelines/)

**Frontend Development Guidelines Plugin**

Comprehensive, modular skill for modern React/TypeScript frontend development.

- **Skills**: Frontend development best practices
- **Coverage**: React, TypeScript, performance, accessibility, testing, state management
- **Use case**: Expert guidance on component design, optimization, and modern frameworks

### [pr-review-toolkit](./pr-review-toolkit/)

**PR Review Toolkit Plugin**

Collection of specialized agents for thorough pull request review.

- **Agents**: 6 specialized review agents (comment-analyzer, test-analyzer, silent-failure-hunter, type-design-analyzer, code-reviewer, code-simplifier)
- **Use case**: Comprehensive PR analysis covering multiple quality dimensions

### [plugin-developer-toolkit](./plugin-developer-toolkit/)

**Plugin Developer Toolkit**

Meta-plugin for creating, developing, and understanding Claude Code plugins.

- **Features**: Interactive plugin creation, comprehensive documentation, ready-to-use templates
- **Templates**: 4 battle-tested templates (basic, with-skill, with-hooks, complete)
- **Use case**: Learning and developing Claude Code plugins

## Installation

These plugins are included in the Claude Code repository. To use them in your own projects:

1. Install Claude Code globally:
```bash
npm install -g @anthropic-ai/claude-code
```

2. Navigate to your project and run Claude Code:
```bash
claude
```

3. Use the `/plugin` command to install plugins from marketplaces, or configure them in your project's `.claude/settings.json`.

For detailed plugin installation and configuration, see the [official documentation](https://docs.claude.com/en/docs/claude-code/plugins).

## Plugin Structure

Each plugin follows the standard Claude Code plugin structure:

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json          # Plugin metadata
├── commands/                 # Slash commands (optional)
├── agents/                   # Specialized agents (optional)
├── skills/                   # Skills (optional)
│   └── skill-name/
│       └── SKILL.md         # Skill definition
├── hooks/                    # Event hooks (optional)
└── README.md                # Plugin documentation
```

### Skills vs Commands

- **Skills** (`skills/` directory): Model-invoked capabilities that Claude automatically uses based on context
  - Defined in `SKILL.md` files with YAML frontmatter
  - Activated automatically when relevant to the conversation
  - Best for: Capabilities that should be available contextually

- **Slash Commands** (`commands/` directory): User-invoked actions triggered explicitly
  - Defined in `.md` files, invoked with `/command-name`
  - Require explicit user action
  - Best for: Specific workflows and operations

See the [plugin-developer-toolkit](./plugin-developer-toolkit/) for comprehensive examples and templates.

## Contributing

When adding new plugins to this directory:

1. Follow the standard plugin structure
2. Include a comprehensive README.md
3. Add plugin metadata in `.claude-plugin/plugin.json`
4. Document all commands and agents
5. Provide usage examples

## Learn More

- [Claude Code Documentation](https://docs.claude.com/en/docs/claude-code/overview)
- [Plugin System Documentation](https://docs.claude.com/en/docs/claude-code/plugins)
- [Agent SDK Documentation](https://docs.claude.com/en/api/agent-sdk/overview)
