# Documentation Generator Plugin with Skills

This plugin demonstrates how to integrate **Skills** into Claude Code plugins. It provides automated documentation generation capabilities through model-invoked skills.

## What This Plugin Demonstrates

This is an example plugin showing:
- ✅ How to structure skills within a plugin
- ✅ How to write effective SKILL.md files
- ✅ How skills are automatically discovered and invoked by Claude
- ✅ How to package multiple skills in one plugin

## Included Skills

### 1. API Documentation Generator

**Skill ID**: `api-docs-generator`

**Purpose**: Automatically generates comprehensive API documentation from source code.

**Triggers when**:
- User asks to "generate API documentation"
- User wants to "document endpoints"
- User requests "OpenAPI spec creation"
- User needs API reference documentation

**Capabilities**:
- Analyzes code to identify API endpoints
- Generates formatted markdown documentation
- Creates OpenAPI/Swagger specifications
- Documents request/response formats with examples

### 2. Changelog Generator

**Skill ID**: `changelog-generator`

**Purpose**: Creates and maintains CHANGELOG.md files following Keep a Changelog format.

**Triggers when**:
- User asks to "generate changelog"
- User wants to "update release notes"
- User requests "version change documentation"
- User needs to "create change history"

**Capabilities**:
- Parses git commit history
- Categorizes changes by type (Added, Fixed, Changed, etc.)
- Follows Keep a Changelog and Semantic Versioning standards
- Updates existing or creates new CHANGELOG.md files

## Plugin Structure

```
doc-generator-with-skills/
├── .claude-plugin/
│   └── plugin.json              # Plugin metadata
├── skills/                       # Skills directory
│   ├── api-docs-generator/
│   │   └── SKILL.md             # API documentation skill
│   └── changelog-generator/
│       └── SKILL.md             # Changelog generation skill
└── README.md                    # This file
```

## How Skills Work in Plugins

### Key Differences: Skills vs Commands

| Feature | Skills | Slash Commands |
|---------|--------|----------------|
| Invocation | Model-invoked (automatic) | User-invoked (explicit) |
| Discovery | Context-based | Manual (`/command`) |
| File | `SKILL.md` | `.md` in `commands/` |
| Location | `skills/` directory | `commands/` directory |

### Skills Are Model-Invoked

Unlike slash commands (like `/commit` or `/review`), skills are **automatically discovered and used by Claude** based on the conversation context:

1. **User makes request**: "Can you document our API endpoints?"
2. **Claude recognizes context**: Matches request to skill description
3. **Skill activates**: `api-docs-generator` skill loads automatically
4. **Claude follows instructions**: Uses skill's guidelines to complete task

### Creating Effective Skills

Each `SKILL.md` file must have:

```yaml
---
name: skill-name
description: Clear description of what the skill does and when to use it
---
```

**Critical**: The `description` field determines when Claude activates the skill. Include:
- What the skill does
- Specific keywords and use cases
- When it should be triggered

## Installation

### For Plugin Users

1. Install this plugin via Claude Code:
```bash
/plugin install doc-generator-with-skills
```

2. Skills activate automatically when relevant - no additional setup needed!

### For Plugin Developers

To integrate skills into your own plugins:

1. **Create skills directory**:
```bash
mkdir -p your-plugin/skills/your-skill-name
```

2. **Create SKILL.md**:
```bash
touch your-plugin/skills/your-skill-name/SKILL.md
```

3. **Add frontmatter and content**:
```yaml
---
name: your-skill-name
description: What your skill does and when to use it
---

# Your Skill Documentation
[Instructions for Claude when this skill is active]
```

4. **(Optional) Add supporting files**:
```
your-skill-name/
├── SKILL.md
├── scripts/
│   └── helper.py
└── templates/
    └── template.md
```

## Example Usage

### Automatic Activation

**User**: "Can you generate API documentation for the endpoints in src/api/?"

**Claude**: *Automatically activates `api-docs-generator` skill and follows its guidelines to analyze code and generate comprehensive API documentation*

**User**: "Update the CHANGELOG for version 2.0.0"

**Claude**: *Automatically activates `changelog-generator` skill, parses git history, and updates CHANGELOG.md*

### No Explicit Command Needed

Notice the user doesn't type `/generate-api-docs` or `/changelog`. Claude recognizes the intent from the natural language request and activates the appropriate skill.

## Best Practices for Skill Development

### 1. Write Specific Descriptions

❌ **Bad**: "Helps with documentation"
✅ **Good**: "Generate comprehensive API documentation from code. Use when user asks to create API docs, document endpoints, generate OpenAPI specs, or create API reference documentation."

### 2. Include Clear Triggers

List specific phrases and keywords that should activate the skill:
- "Generate API documentation"
- "Document the endpoints"
- "Create changelog"

### 3. Provide Detailed Instructions

The SKILL.md content should include:
- Clear capabilities
- Step-by-step workflows
- Output format examples
- Best practices
- Common pitfalls to avoid

### 4. Keep Skills Focused

Each skill should do one thing well. For multiple capabilities, create multiple skills:
- ✅ `api-docs-generator` + `changelog-generator`
- ❌ One mega `documentation-generator` skill

### 5. Reference Supporting Files

If your skill includes scripts or templates:
```markdown
Use the template in `./templates/api-template.md` as a starting point.
Run `./scripts/validate-openapi.py` to verify the generated spec.
```

## Advanced: Optional Tool Restrictions

Restrict which tools Claude can use when a skill is active (useful for read-only operations):

```yaml
---
name: code-analyzer
description: Analyze code without modifying files
allowed-tools:
  - Read
  - Grep
  - Glob
---
```

This prevents the skill from accidentally modifying files during analysis.

## Learn More

- [Skills Documentation](https://code.claude.com/docs/en/skills)
- [Plugins Documentation](https://code.claude.com/docs/en/plugins)
- [Claude Cookbooks - Skills](https://github.com/anthropics/claude-cookbooks/tree/main/skills)

## Contributing

This plugin is a reference example. To create your own plugin with skills:

1. Fork this structure
2. Customize the skills for your use case
3. Update plugin.json metadata
4. Share with your team or publish to a marketplace

## License

This example plugin is provided as a reference for the Claude Code community.
