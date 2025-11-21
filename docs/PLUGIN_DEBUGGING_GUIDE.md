# Plugin Debugging Guide

## Overview

This guide explains how to debug and test Claude Code plugins using official tools and our custom debugging scripts.

**Based on**: [Official Debugging Documentation](https://code.claude.com/docs/en/plugins-reference#debugging-and-development-tools)

## Quick Start

### 1. Run Automated Tests

```bash
# Comprehensive debugging tests
./Script/debug-plugins.sh

# Validation tests (JSON, hooks, skills)
./Script/validate-all.sh
```

### 2. Test Plugin Loading

```bash
# See plugin loading details
claude --debug
```

This shows:
- Plugin loading status
- Manifest validation errors
- Command/agent/hook registration
- MCP server initialization

## Common Issues & Solutions

### 1. Plugin Loading Failures

**Symptom**: Plugin doesn't appear or fails to load
**Cause**: Invalid `plugin.json` syntax
**Solution**:
```bash
# Validate JSON syntax
jq '.' plugins/your-plugin/.claude-plugin/plugin.json

# Run our validation
./Script/validate-all.sh
```

### 2. Command Registration Issues

**Symptom**: Commands don't appear in Claude
**Cause**: Commands directory in wrong location
**Solution**:
- ✅ Correct: `plugins/your-plugin/commands/`
- ❌ Wrong: `plugins/your-plugin/.claude-plugin/commands/`

Commands must be at plugin root, not inside `.claude-plugin/`

### 3. Hook Execution Problems

**Symptom**: Hooks don't trigger
**Cause**: Scripts lack executable permissions
**Solution**:
```bash
# Make scripts executable
chmod +x plugins/your-plugin/hooks/*.sh
chmod +x plugins/your-plugin/hooks/*.py

# Verify permissions
ls -la plugins/your-plugin/hooks/
```

### 4. Path Resolution Errors

**Symptom**: Plugin works locally but fails elsewhere
**Cause**: Absolute paths instead of `${CLAUDE_PLUGIN_ROOT}`
**Solution**:
```json
// ❌ Wrong - absolute path
"command": "/home/user/plugins/my-plugin/script.sh"

// ✅ Correct - uses CLAUDE_PLUGIN_ROOT
"command": "bash ${CLAUDE_PLUGIN_ROOT}/script.sh"
```

### 5. Missing Shebang Lines

**Symptom**: Scripts fail with "permission denied" or "cannot execute"
**Cause**: Missing shebang line
**Solution**:
```bash
# Add shebang to shell scripts
#!/bin/bash

# Add shebang to Python scripts
#!/usr/bin/env python3

# Add shebang to Node scripts
#!/usr/bin/env node
```

## Debugging Tools

### Official Tool: `claude --debug`

The primary debugging command provided by Claude Code:

```bash
claude --debug
```

**Shows**:
- Plugin discovery and loading
- Manifest validation
- Command registration
- Agent registration
- Hook registration
- MCP server initialization
- Error messages and stack traces

**Usage**:
```bash
# Start Claude with debugging
claude --debug

# In a project with plugins
cd your-project
claude --debug
```

### Custom Tool: `debug-plugins.sh`

Our comprehensive debugging script that checks for all common issues:

```bash
./Script/debug-plugins.sh
```

**Tests**:
1. ✅ Plugin manifest (plugin.json) validation
2. ✅ Command directory structure
3. ✅ Hook script permissions and shebangs
4. ✅ CLAUDE_PLUGIN_ROOT usage
5. ✅ Relative vs absolute paths
6. ✅ Skills YAML frontmatter
7. ✅ Agent file validation
8. ✅ MCP server configuration
9. ✅ Plugin structure completeness
10. ✅ Security best practices

**Exit Codes**:
- `0` - All tests passed
- `1` - Critical errors found

### Validation Tool: `validate-all.sh`

JSON and configuration validation:

```bash
./Script/validate-all.sh
```

**Validates**:
- JSON syntax in all config files
- Hook structure compliance
- SKILL.md frontmatter
- Marketplace configuration
- Metadata completeness

## Testing Workflow

### Before Committing

```bash
# 1. Run validation
./Script/validate-all.sh

# 2. Run debugging tests
./Script/debug-plugins.sh

# 3. Fix any errors

# 4. Test plugin loading
claude --debug
```

### During Development

```bash
# Quick validation
jq '.' plugins/your-plugin/.claude-plugin/plugin.json

# Check specific plugin
grep -r "CLAUDE_PLUGIN_ROOT" plugins/your-plugin/

# Test script permissions
ls -la plugins/your-plugin/hooks/
```

### CI/CD Integration

The GitHub Actions workflow automatically runs:
- JSON validation
- Configuration validation
- Security checks

On every pull request.

## Plugin Structure Checklist

### Required Files

- [ ] `.claude-plugin/plugin.json` - Plugin manifest
- [ ] `README.md` - Documentation

### Plugin Manifest (plugin.json)

```json
{
  "name": "plugin-name",           // Required: kebab-case
  "description": "Clear desc",     // Required
  "version": "1.0.0",              // Required: semver
  "author": {                      // Required
    "name": "Your Name",
    "email": "your@email.com"
  },
  "keywords": [...],               // Recommended
  "repository": {...},             // Recommended
  "license": "MIT"                 // Recommended
}
```

### Commands (Optional)

```
plugins/your-plugin/commands/
├── command1.md
└── command2.md
```

**Important**: Commands directory must be at plugin root!

### Agents (Optional)

```
plugins/your-plugin/agents/
├── agent1.md
└── agent2.md
```

Agents should have markdown headers and clear instructions.

### Skills (Optional)

```
plugins/your-plugin/skills/
└── skill-name/
    └── SKILL.md
```

**SKILL.md format**:
```markdown
---
name: skill-name
description: Clear description with trigger keywords
---

# Skill content here
```

### Hooks (Optional)

```
plugins/your-plugin/hooks/
├── hooks.json
└── script.sh
```

**Requirements**:
- Scripts must be executable (`chmod +x`)
- Scripts must have shebang (`#!/bin/bash`)
- Use `${CLAUDE_PLUGIN_ROOT}` in paths

## Troubleshooting Guide

### Plugin Not Loading

1. Check `claude --debug` output
2. Validate JSON: `jq '.' plugin.json`
3. Check file structure
4. Verify plugin.json location

### Commands Not Appearing

1. Verify commands directory location (must be at root)
2. Check command file format (.md files)
3. Run `claude --debug` to see registration

### Hooks Not Executing

1. Check script permissions: `ls -la hooks/`
2. Make executable: `chmod +x hooks/*.sh`
3. Verify shebang line exists
4. Test script independently: `./hooks/script.sh`
5. Check hooks.json structure

### Skills Not Activating

1. Validate YAML frontmatter
2. Check name field (kebab-case, 1-64 chars)
3. Ensure description is detailed (50+ chars)
4. Include trigger keywords in description

### Path Errors

1. Use `${CLAUDE_PLUGIN_ROOT}` for all plugin paths
2. Use relative paths (start with `./`)
3. Never use absolute paths (`/home/...`)
4. Test on different systems

## Best Practices

### 1. Always Use CLAUDE_PLUGIN_ROOT

```bash
# ✅ Correct
bash ${CLAUDE_PLUGIN_ROOT}/hooks/script.sh
node ${CLAUDE_PLUGIN_ROOT}/src/index.js
python3 ${CLAUDE_PLUGIN_ROOT}/scripts/tool.py

# ❌ Wrong
bash /absolute/path/to/script.sh
./script.sh  # relative to CWD, not plugin
```

### 2. Make Scripts Executable

```bash
# Make all scripts executable
find plugins/your-plugin -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} \;
```

### 3. Test Before Committing

```bash
# Run all checks
./Script/validate-all.sh && ./Script/debug-plugins.sh && echo "✓ Ready to commit"
```

### 4. Use Pre-Commit Hooks

```bash
# Install automatic validation
./Script/install-git-hooks.sh
```

### 5. Document Everything

- Add README.md to every plugin
- Document all commands
- Explain agent capabilities
- Describe skill triggers

## Examples

### Debugging a Hook Issue

```bash
# 1. Check if hook is registered
claude --debug | grep -A5 "hooks"

# 2. Verify hook structure
cat plugins/my-plugin/hooks/hooks.json | jq '.'

# 3. Check script permissions
ls -la plugins/my-plugin/hooks/

# 4. Make executable if needed
chmod +x plugins/my-plugin/hooks/script.sh

# 5. Test script independently
plugins/my-plugin/hooks/script.sh

# 6. Verify CLAUDE_PLUGIN_ROOT usage
grep CLAUDE_PLUGIN_ROOT plugins/my-plugin/hooks/hooks.json
```

### Debugging a Command Issue

```bash
# 1. Check command directory location
ls -la plugins/my-plugin/ | grep commands

# 2. Verify command file
cat plugins/my-plugin/commands/my-command.md

# 3. Check registration
claude --debug | grep -A5 "commands"
```

### Debugging a Skill Issue

```bash
# 1. Validate frontmatter
head -10 plugins/my-plugin/skills/my-skill/SKILL.md

# 2. Check YAML syntax
./Script/validate-all.sh | grep my-skill

# 3. Verify description length
./Script/debug-plugins.sh | grep my-skill
```

## Resources

- [Official Debugging Docs](https://code.claude.com/docs/en/plugins-reference#debugging-and-development-tools)
- [Plugin Maintenance Guide](./PLUGIN_MAINTENANCE_GUIDE.md)
- [Implementation Plan](../IMPLEMENTATION_PLAN.md)
- [Quick Reference](./QUICK-REFERENCE.md)

## Getting Help

If you're still having issues:

1. Run `./Script/debug-plugins.sh` and save output
2. Run `./Script/validate-all.sh` and save output
3. Run `claude --debug` and save output
4. Create an issue with all three outputs
5. Include your plugin structure (`tree plugins/your-plugin`)
