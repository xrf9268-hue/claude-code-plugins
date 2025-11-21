# Plugin Maintenance Guide

## Overview

This guide ensures all plugins maintain high quality and compliance with official Claude Code specifications.

## Quality Standards

All plugins must:
- ✅ Have valid JSON configurations
- ✅ Include complete metadata (name, description, version, author)
- ✅ Have keywords for discoverability
- ✅ Have repository link
- ✅ Have license field
- ✅ Follow hook structure specifications
- ✅ Have well-formed SKILL.md files (if applicable)

## Before Adding/Modifying Plugins

### 1. Run Validation

```bash
./Script/validate-all.sh
```

Fix any errors or warnings before committing.

### 2. Follow Official Specifications

- **Plugins**: https://code.claude.com/docs/en/plugins-reference
- **Skills**: https://code.claude.com/docs/en/skills
- **Hooks**: https://code.claude.com/docs/en/hooks

### 3. Use Templates

Start from existing templates in `plugins/plugin-developer-toolkit/templates/`

### 4. Required Fields

#### plugin.json

```json
{
  "name": "plugin-name",           // REQUIRED: kebab-case
  "description": "Clear desc",     // REQUIRED
  "version": "1.0.0",              // REQUIRED: semver
  "author": {                      // REQUIRED
    "name": "Your Name",
    "email": "your@email.com"
  },
  "keywords": [...],               // RECOMMENDED
  "repository": {...},             // RECOMMENDED
  "license": "MIT"                 // RECOMMENDED
}
```

**Field Order**: Always use this order: name, description, version, author, keywords, repository, license

#### SKILL.md frontmatter

```yaml
---
name: skill-name          # REQUIRED: kebab-case, 1-64 chars
description: Detailed...  # REQUIRED: max 1024 chars, keyword-rich
---
```

#### hooks.json structure

**Lifecycle events** (SessionStart, PreCompact, SessionEnd, etc.):
```json
"SessionStart": [
  {
    "hooks": [              // ← REQUIRED wrapper
      {
        "type": "command",
        "command": "bash ${CLAUDE_PLUGIN_ROOT}/script.sh"
      }
    ]
  }
]
```

**Tool-based events** (PreToolUse, PostToolUse):
```json
"PreToolUse": [
  {
    "hooks": [              // ← REQUIRED wrapper
      {
        "type": "command",
        "command": "..."
      }
    ],
    "matcher": "Edit|Write"  // ← REQUIRED matcher
  }
]
```

## Common Issues

### Issue: "Missing hooks wrapper"
**Fix**: Wrap hook definitions in "hooks" array for lifecycle events

### Issue: "Invalid skill name"
**Fix**: Use kebab-case, 1-64 characters

### Issue: "Hook script not executable"
**Fix**: `chmod +x plugins/*/hooks/*.sh`

### Issue: "Missing keywords"
**Fix**: Add relevant keywords array to plugin.json

## Automated Checks

- **Pre-commit hook**: Install with `./Script/install-git-hooks.sh`
- **Manual**: Run `./Script/validate-all.sh` anytime

## Adding New Plugins

1. Copy from template:
   ```bash
   cp -r plugins/plugin-developer-toolkit/templates/plugin-basic \
         plugins/my-new-plugin
   ```

2. Customize plugin.json:
   - Update name (kebab-case)
   - Write clear description
   - Add relevant keywords (5-10)
   - Update repository URL
   - Set appropriate license

3. Add functionality (skills/agents/commands/hooks)

4. Validate:
   ```bash
   ./Script/validate-all.sh
   ```

5. Add to marketplace.json (if applicable)

6. Commit and push

## Versioning

Follow semantic versioning:
- **Major (1.0.0)**: Breaking changes
- **Minor (0.1.0)**: New features, backward compatible
- **Patch (0.0.1)**: Bug fixes

## Scripts Reference

- **validate-all.sh**: Comprehensive validation of all configurations
- **add-license.sh**: Add MIT license to all plugins
- **standardize-field-order.sh**: Standardize field order in plugin.json files
- **install-git-hooks.sh**: Install pre-commit validation hook

## Resources

- [Review Report](../PLUGIN_SKILL_REVIEW_REPORT.md)
- [Implementation Plan](../IMPLEMENTATION_PLAN.md)
- [Quick Reference](./QUICK-REFERENCE.md)
- [Official Claude Code Docs](https://code.claude.com/docs/en/plugins)

## Troubleshooting

### Validation Fails

1. Read the error message carefully
2. Check the official specification
3. Look at working examples in other plugins
4. Run validation again after fixes

### JSON Syntax Errors

Use `jq` to validate and format:
```bash
jq '.' plugins/your-plugin/.claude-plugin/plugin.json
```

### Hook Execution Errors

1. Verify script has shebang (#!/bin/bash)
2. Ensure script is executable
3. Test script independently
4. Check ${CLAUDE_PLUGIN_ROOT} usage

## Best Practices

1. **Keywords**: Choose 5-10 relevant, searchable terms
2. **Descriptions**: Be clear and concise (100-200 chars)
3. **Testing**: Test plugins before committing
4. **Documentation**: Update README when adding features
5. **Consistency**: Follow existing patterns in the codebase
