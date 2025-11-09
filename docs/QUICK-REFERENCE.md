# Claude Code Plugins Quick Reference

One-page quick reference for Claude Code plugins. Bookmark this page for fast lookups!

## ⚡ 1-Minute Setup

```bash
# Install Claude Code
npm install -g @anthropic-ai/claude-code

# Start in your project
claude

# Add plugin marketplace
/plugin marketplace add anthropics/claude-code-plugins

# Install essential plugins
/plugin install commit-commands@claude-code-plugins
/plugin install security-guidance@claude-code-plugins

# Restart (REQUIRED after installing plugins)
# Press Ctrl+C, then run 'claude' again
```

## 📦 Plugin Components Cheat Sheet

| Component | File Location | Invocation | Best For |
|-----------|--------------|------------|----------|
| **Skill** | `skills/*/SKILL.md` | Auto (context) | Contextual help, auto-activation |
| **Command** | `commands/*.md` | User `/command` | Explicit workflows, user control |
| **Agent** | `agents/*.md` | Claude decides | Complex analysis, multi-step tasks |
| **Hook** | `hooks/hooks.json` | Lifecycle events | Validation, automation, context saving |
| **MCP Server** | `.mcp.json` | Auto-loaded | External tool integration |

### Quick Decision Tree

```
Need to add functionality?
├─ User explicitly invokes? → Slash Command
├─ Auto-activates based on context? → Skill
├─ Complex multi-step analysis? → Agent
├─ Runs on lifecycle events? → Hook
└─ External tool integration? → MCP Server
```

## 🎯 Component Quick Syntax

### Skills

```markdown
<!-- skills/my-skill/SKILL.md -->
---
name: my-skill
description: What it does and when to use it. Include trigger keywords.
---

# Skill content here
Instructions for Claude when this skill is active...
```

### Commands

```markdown
<!-- commands/my-command.md -->
---
description: Brief command description
---

# Command instructions
What to do when `/my-command` is invoked...
```

### Agents

```markdown
<!-- agents/my-agent.md -->
---
name: my-agent
description: What this agent does and when to invoke it
tools: Read, Grep, Glob  # Optional: restrict tools
model: sonnet            # Optional: haiku/sonnet/opus
---

# Agent system prompt
Detailed instructions for the agent...
```

### Hooks

```json
// hooks/hooks.json
{
  "description": "What these hooks do",
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "python3 ${CLAUDE_PLUGIN_ROOT}/hooks/script.py"
          }
        ]
      }
    ]
  }
}
```

## 📁 Standard Plugin Structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          # REQUIRED: Plugin metadata
├── skills/                   # Optional
│   └── my-skill/
│       ├── SKILL.md         # Required for each skill
│       ├── scripts/         # Optional helper scripts
│       └── templates/       # Optional templates
├── commands/                 # Optional
│   └── my-command.md
├── agents/                   # Optional
│   └── my-agent.md
├── hooks/                    # Optional
│   ├── hooks.json
│   └── script.py
├── .mcp.json                # Optional: MCP servers
└── README.md               # Recommended
```

## ⚙️ plugin.json Template

```json
{
  "name": "my-plugin",              // REQUIRED
  "description": "Brief description", // Recommended
  "version": "1.0.0",               // Recommended
  "author": {                       // Recommended
    "name": "Your Name",
    "email": "you@example.com"
  },
  "keywords": ["tag1", "tag2"],     // Optional
  "repository": {                   // Optional
    "type": "git",
    "url": "https://github.com/..."
  },
  "license": "MIT",                 // Optional
  "homepage": "https://..."         // Optional
}
```

## 🔧 Common Commands

```bash
# Plugin Management
/plugin                                  # Open plugin manager
/plugin marketplace add owner/repo      # Add marketplace
/plugin install plugin-name@marketplace # Install plugin
/plugin uninstall plugin-name          # Uninstall plugin

# Help and Info
/help                                   # Show all commands
/agents                                 # List available agents
/hooks                                  # Show registered hooks

# Git Workflow (if commit-commands installed)
/commit                                 # Create commit
/commit-push-pr                        # Commit + push + PR
/clean_gone                           # Clean stale branches
```

## 🚀 Installation Methods

### Method 1: Interactive (Easy)

```bash
claude
/plugin
# Browse and click "Install"
```

### Method 2: Command Line (Fast)

```bash
claude
/plugin marketplace add anthropics/claude-code-plugins
/plugin install plugin-name@claude-code-plugins
# Restart Claude Code
```

### Method 3: Team Config (Automatic)

```json
// .claude/settings.json (commit to git)
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
    "security-guidance": { "enabled": true }
  }
}
```

## 🎨 Skills vs Commands vs Agents

### When to Use Each

**Use Skill when:**
- ✅ Should activate automatically based on context
- ✅ User doesn't need to remember a command
- ✅ Provides contextual assistance
- ❌ Examples: API docs generator, changelog generator

**Use Command when:**
- ✅ User wants explicit control
- ✅ Specific workflow with clear entry point
- ✅ Should be discoverable in `/help`
- ❌ Examples: `/commit`, `/review-pr`, `/deploy`

**Use Agent when:**
- ✅ Complex multi-step analysis needed
- ✅ Separate context window beneficial
- ✅ Tool restrictions desired
- ❌ Examples: Code reviewer, architect, security auditor

## 🎯 Field Reference

### SKILL.md Frontmatter

```yaml
---
name: skill-name           # REQUIRED: lowercase-hyphens, 1-64 chars
description: Full desc...  # REQUIRED: max 1024 chars, CRITICAL for discovery
allowed-tools: Read, Grep  # Optional: restrict tools
---
```

**Critical:** `description` determines when skill activates. Include:
- What it does
- When to use it
- Trigger keywords
- Specific scenarios

### Agent .md Frontmatter

```yaml
---
name: agent-name           # REQUIRED: lowercase-hyphens
description: When to use   # REQUIRED: Include trigger scenarios
tools: Read, Grep, Bash(*) # Optional: restrict tools
model: sonnet              # Optional: haiku/sonnet/opus/inherit
color: green               # Optional: blue/red/yellow/purple/green
---
```

### Hook Events

| Event | When It Fires | Requires Matcher |
|-------|--------------|------------------|
| **PreToolUse** | Before tool execution | ✅ Yes |
| **PostToolUse** | After tool execution | ✅ Yes |
| **SessionStart** | Session begins | ❌ No |
| **SessionEnd** | Session ends | ❌ No |
| **PreCompact** | Before context compaction | ❌ No |
| **UserPromptSubmit** | User submits prompt | ❌ No |
| **Stop** | User interrupts | ❌ No |
| **SubagentStop** | Subagent interrupted | ❌ No |

## 🛠️ Tool Restrictions

### Common Patterns

```yaml
# Read-only analysis
tools: Read, Grep, Glob

# Git operations only
tools: Read, Bash(git:*)

# Testing
tools: Read, Bash(pytest:*), Bash(jest:*), Bash(npm test:*)

# Linting
tools: Read, Bash(eslint:*), Bash(pylint:*)

# Specific files only
tools: Edit, Write  # Then check file_path in hook

# Everything (default)
# tools: (omit field entirely)
```

## 🔐 Hook Exit Codes

| Exit Code | Meaning | Effect |
|-----------|---------|--------|
| **0** | Success | stdout shown, operation continues |
| **2** | Block | stderr sent to Claude, operation blocked |
| **Other** | Warning | stderr shown to user, operation continues |

### Hook Script Template

```python
#!/usr/bin/env python3
import sys
import json

try:
    # Read input
    data = json.loads(sys.stdin.read())

    # Validate
    if not is_valid(data):
        sys.stderr.write("Error: validation failed\n")
        sys.exit(2)  # Block operation

    # Success
    print("Validation passed")
    sys.exit(0)

except Exception as e:
    # Don't block on hook errors
    sys.stderr.write(f"Hook error: {e}\n")
    sys.exit(0)
```

## 🌍 Environment Variables

Available in hooks and scripts:

```bash
CLAUDE_PROJECT_DIR       # Project root directory
CLAUDE_PLUGIN_ROOT       # Plugin root (for plugin hooks)
CLAUDE_CODE_REMOTE       # "true" or "false"
CLAUDE_ENV_FILE          # SessionStart only: env persistence file
```

## 🐛 Troubleshooting Checklist

### Plugin not working?

- [ ] Restarted Claude Code after installing?
- [ ] Plugin file in correct location?
- [ ] plugin.json valid JSON?
- [ ] Using correct command syntax?

### Skill not activating?

- [ ] Description specific enough?
- [ ] Description includes trigger keywords?
- [ ] YAML frontmatter valid?
- [ ] Closing `---` present?
- [ ] Tried explicit trigger phrases?

### Agent not invoked?

- [ ] Description clear about when to use?
- [ ] Description includes scenarios?
- [ ] Agent file in `agents/` directory?
- [ ] Valid Markdown format?

### Hook not executing?

- [ ] hooks.json valid JSON?
- [ ] Script executable (`chmod +x`)?
- [ ] Matcher pattern correct?
- [ ] Script path uses `${CLAUDE_PLUGIN_ROOT}`?
- [ ] Exit codes correct (0 or 2)?

## 📚 Platform Compatibility

| Plugin | GitHub | GitLab | Bitbucket |
|--------|--------|--------|-----------|
| commit-commands | ✅ | ✅ | ✅ |
| feature-dev | ✅ | ✅ | ✅ |
| pr-review-toolkit | ✅ | ✅ | ✅ |
| security-guidance | ✅ | ✅ | ✅ |
| **code-review** | ✅ | ❌ | ❌ |

**Note:** `code-review` requires GitHub CLI (`gh`) and only works with GitHub.

## 🎓 Best Practices Quick List

### Skills
✅ Specific descriptions with trigger keywords
✅ Focus on one capability
✅ Include usage examples in description
✅ Keep SKILL.md focused, use separate files for details

### Commands
✅ Clear, actionable names
✅ Provide usage context at top
✅ Use `!` for dynamic context
✅ Limit tool access with `allowed-tools`

### Agents
✅ Single responsibility per agent
✅ Clear invocation criteria in description
✅ Appropriate tool restrictions
✅ Right model for task (haiku/sonnet/opus)

### Hooks
✅ Keep fast (<1 second)
✅ Fail safely (exit 0 on errors)
✅ Quote shell variables
✅ Validate all inputs
✅ Skip sensitive files

## 📖 Learn More

### Detailed Guides
- [Quick Plugin Installation](./QUICK_PLUGIN_INSTALLATION.md) - Complete installation guide
- [Skills Integration](./INTEGRATING-SKILLS-IN-PLUGINS.md) - Deep dive into skills
- [Hooks Development](./HOOKS-DEVELOPMENT-GUIDE.md) - Complete hooks guide
- [Agents Development](./AGENTS-DEVELOPMENT-GUIDE.md) - Complete agents guide
- [Platform Compatibility](./PLATFORM_COMPATIBILITY.md) - Platform-specific info

### Official Docs
- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code/overview)
- [Plugins Guide](https://code.claude.com/docs/en/plugins)
- [Skills Guide](https://code.claude.com/docs/en/skills)
- [Sub-Agents Guide](https://code.claude.com/docs/en/sub-agents)
- [Hooks Reference](https://code.claude.com/docs/en/hooks)

### Example Plugins
- [commit-commands](../plugins/commit-commands/) - Git workflow automation
- [security-guidance](../plugins/security-guidance/) - Security validation hooks
- [pr-review-toolkit](../plugins/pr-review-toolkit/) - Code review agents
- [doc-generator-with-skills](../plugins/doc-generator-with-skills/) - Skills example
- [plugin-developer-toolkit](../plugins/plugin-developer-toolkit/) - Meta-plugin

### Community
- [Claude Developers Discord](https://anthropic.com/discord)
- [Claude Cookbooks](https://github.com/anthropics/claude-cookbooks/tree/main/skills)

---

**Bookmark this page for quick reference!**

**Last Updated:** 2025-11-09
**Version:** 1.0.0
