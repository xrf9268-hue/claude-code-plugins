# Integrating Skills in Claude Code Plugins

This guide explains how to integrate **Skills** into Claude Code plugins, enabling model-invoked capabilities that Claude automatically discovers and uses based on conversation context.

## Table of Contents

- [What are Skills?](#what-are-skills)
- [Skills vs Slash Commands](#skills-vs-slash-commands)
- [When to Use Skills in Plugins](#when-to-use-skills-in-plugins)
- [Plugin Structure with Skills](#plugin-structure-with-skills)
- [Creating Your First Skill](#creating-your-first-skill)
- [SKILL.md Anatomy](#skillmd-anatomy)
- [Best Practices](#best-practices)
- [Advanced Features](#advanced-features)
- [Testing and Debugging](#testing-and-debugging)
- [Examples](#examples)

## What are Skills?

Skills are modular capabilities that extend Claude's functionality. Unlike slash commands that users explicitly invoke, **skills are model-invoked** — Claude automatically discovers and activates them based on conversation context.

**Key characteristics**:
- 🤖 **Automatic activation**: Claude decides when to use them
- 📝 **Context-based**: Triggered by relevant keywords and conversation flow
- 🔄 **Composable**: Multiple skills can work together
- 📦 **Portable**: Easily shared via plugins

## Skills vs Slash Commands

| Aspect | Skills | Slash Commands |
|--------|--------|----------------|
| **Invocation** | Automatic (model-invoked) | Manual (user-invoked) |
| **Trigger** | Context and keywords | Explicit `/command` |
| **File location** | `skills/skill-name/SKILL.md` | `commands/command-name.md` |
| **Discovery** | Based on description | Listed in `/help` |
| **Best for** | Contextual capabilities | Specific workflows |
| **Example** | API docs generator | `/commit` command |

**Example comparison**:

```bash
# Slash Command (explicit)
User: "/generate-docs"
Claude: [Executes command]

# Skill (contextual)
User: "Can you document our API endpoints?"
Claude: [Automatically activates api-docs-generator skill]
```

## When to Use Skills in Plugins

Use skills when you want to:

✅ **Provide contextual assistance** - Automatically help users based on what they're discussing
✅ **Reduce command memorization** - Users don't need to remember specific command names
✅ **Enable discovery** - Users naturally describe what they need
✅ **Compose capabilities** - Multiple skills can activate in one conversation

Use slash commands when you want to:

✅ **Provide explicit workflows** - User wants precise control
✅ **Group complex operations** - Multi-step processes with clear entry points
✅ **Offer discoverable actions** - Users can browse available commands

**Best practice**: Many plugins include **both** skills and commands for flexibility.

## Plugin Structure with Skills

### Basic Plugin with Skills

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json              # Plugin metadata
├── skills/                       # Skills directory
│   ├── skill-one/
│   │   ├── SKILL.md             # Required skill definition
│   │   ├── scripts/             # Optional helper scripts
│   │   │   └── helper.py
│   │   └── templates/           # Optional templates
│   │       └── output.template
│   └── skill-two/
│       └── SKILL.md
├── commands/                     # Optional slash commands
│   └── explicit-command.md
└── README.md                    # Plugin documentation
```

### plugin.json Example

```json
{
  "name": "my-plugin",
  "description": "Plugin with integrated skills",
  "version": "1.0.0",
  "author": {
    "name": "Your Name",
    "email": "you@example.com"
  }
}
```

## Creating Your First Skill

### Step 1: Create Directory Structure

```bash
mkdir -p my-plugin/skills/my-skill
```

### Step 2: Create SKILL.md

```bash
touch my-plugin/skills/my-skill/SKILL.md
```

### Step 3: Add Content

```markdown
---
name: my-skill
description: Brief description of what the skill does and when to use it. Include specific keywords that should trigger activation.
---

# My Skill

This skill does X when the user wants to Y.

## When to Use This Skill

Activate when the user:
- Says "do X"
- Asks to "accomplish Y"
- Needs to "perform Z"

## Instructions

1. First, do this
2. Then, do that
3. Finally, complete the task

## Output Format

Provide results in this format:
[Details about expected output]
```

### Step 4: Test

Start a conversation mentioning the keywords from your description:

```
User: "Can you help me do X?"
Claude: [Should activate my-skill automatically]
```

## SKILL.md Anatomy

### Required YAML Frontmatter

```yaml
---
name: skill-name                  # Lowercase, hyphens, 1-64 chars
description: Detailed description # Up to 1024 chars, CRITICAL for discovery
---
```

### Critical: The Description Field

The `description` is **the most important part** of your skill. Claude uses it to decide when to activate the skill.

❌ **Bad description** (too vague):
```yaml
description: Helps with code
```

✅ **Good description** (specific, keyword-rich):
```yaml
description: Generate unit tests for Python, JavaScript, and TypeScript code. Use when user asks to create tests, write test cases, add test coverage, or generate test suites.
```

**Description best practices**:
1. Start with what the skill does
2. List specific trigger phrases
3. Include relevant keywords
4. Mention concrete use cases
5. Be specific about file types, languages, or domains

### Skill Content Structure

```markdown
---
name: my-skill
description: [Critical for discovery]
---

# Skill Title

Brief overview of what this skill does.

## When to Use This Skill

Explicit list of trigger conditions:
- User asks to "X"
- User wants to "Y"
- User needs "Z"

## Capabilities

What this skill can do:
- Capability 1
- Capability 2
- Capability 3

## Instructions

Step-by-step workflow:

1. **Analyze**: First, do this
2. **Process**: Then, do that
3. **Output**: Finally, deliver results

## Expected Output Format

[Provide examples or templates]

## Best Practices

- Practice 1
- Practice 2
- Practice 3

## Common Pitfalls

- Avoid X
- Be careful with Y
- Remember to Z
```

## Best Practices

### 1. Write Specific Descriptions

Include concrete trigger terms:

```yaml
# ❌ Vague
description: Documentation helper

# ✅ Specific
description: Generate API documentation including endpoints, parameters, request/response examples, and error codes. Use when user asks to document APIs, create OpenAPI specs, or generate endpoint documentation.
```

### 2. Keep Skills Focused

One skill, one purpose:

```
✅ Good: api-docs-generator
✅ Good: changelog-generator
❌ Too broad: docs-generator (does everything)
```

### 3. Provide Clear Instructions

Be specific about workflow:

```markdown
## Instructions

1. **Scan**: Read all files in the specified directory
2. **Parse**: Extract API endpoints using regex patterns
3. **Analyze**: Identify parameters, request/response types
4. **Format**: Generate markdown following this template:
   [Include template]
5. **Validate**: Check for common errors
6. **Output**: Write to docs/API.md
```

### 4. Include Examples

Show expected inputs and outputs:

```markdown
## Example

### Input
User: "Document the /users endpoint"

### Expected Output
# Users API

## GET /users
...
```

### 5. Reference Supporting Files

Use relative paths:

```markdown
Use the template at `./templates/api-doc.template`.
Run validation with `./scripts/validate-schema.py`.
```

### 6. Document Limitations

Be clear about what the skill can't do:

```markdown
## Limitations

- Only supports REST APIs (not GraphQL)
- Requires TypeScript JSDoc comments
- Does not generate client SDKs
```

## Advanced Features

### Optional Tool Restrictions

Limit which tools Claude can use when the skill is active:

```yaml
---
name: read-only-analyzer
description: Analyze code without modifications
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
---
```

**Use cases**:
- Read-only analysis
- Security-sensitive operations
- Audit workflows

### Multi-File Skills

Include supporting files:

```
complex-skill/
├── SKILL.md                    # Main instructions
├── scripts/
│   ├── preprocessor.py         # Helper script
│   └── validator.js            # Validation logic
├── templates/
│   ├── output.template         # Output template
│   └── config.example          # Config example
└── reference/
    └── api-spec.md            # Reference documentation
```

Reference them in SKILL.md:

```markdown
## Preprocessing

Run `./scripts/preprocessor.py` on the input files first.

## Validation

After generation, validate output using `./scripts/validator.js`.

## Templates

Use `./templates/output.template` as the base structure.
```

### Composable Skills

Design skills to work together:

```yaml
# skill-a/SKILL.md
---
name: api-parser
description: Parse API code to extract endpoints and schemas
---

# skill-b/SKILL.md
---
name: openapi-generator
description: Generate OpenAPI specs from parsed API data
---
```

User: "Generate OpenAPI docs for the API"
Claude: [Activates both api-parser then openapi-generator]

## Testing and Debugging

### Testing Skill Activation

1. **Write test prompts** that should trigger the skill:
```
✅ Should trigger: "Generate API documentation"
✅ Should trigger: "Document the endpoints"
❌ Should not trigger: "Show me the code"
```

2. **Verify activation** by observing Claude's behavior:
   - Does it follow the skill's instructions?
   - Does it use the expected workflow?
   - Does output match the format?

### Debugging Common Issues

#### Skill Not Activating

**Problem**: Claude doesn't use the skill when expected

**Solutions**:
- ✅ Add more specific keywords to description
- ✅ Include trigger phrases from test prompts
- ✅ Check YAML frontmatter syntax
- ✅ Verify closing `---` delimiter exists

#### Skill Activating Too Often

**Problem**: Skill activates in wrong contexts

**Solutions**:
- ✅ Make description more specific
- ✅ Add limiting qualifiers ("only for Python", "when user explicitly asks")
- ✅ Narrow the scope of trigger terms

#### Instructions Not Followed

**Problem**: Claude activates skill but doesn't follow instructions

**Solutions**:
- ✅ Make instructions more explicit and step-by-step
- ✅ Add examples of expected behavior
- ✅ Include common pitfalls to avoid
- ✅ Provide output format templates

### Validation Checklist

Before publishing your plugin:

- [ ] YAML frontmatter is valid
- [ ] `name` is lowercase, hyphenated, 1-64 chars
- [ ] `description` is specific and keyword-rich (≤1024 chars)
- [ ] Closing `---` delimiter exists
- [ ] Instructions are clear and step-by-step
- [ ] Examples are included
- [ ] Trigger conditions are documented
- [ ] Supporting files are referenced with relative paths
- [ ] Tested with multiple relevant prompts
- [ ] README documents the skills

## Examples

### Example 1: Code Analysis Skill

```markdown
---
name: code-complexity-analyzer
description: Analyze code complexity metrics including cyclomatic complexity, maintainability index, and code smells. Use when user asks to analyze code quality, check complexity, identify code smells, or review maintainability.
allowed-tools:
  - Read
  - Grep
  - Glob
---

# Code Complexity Analyzer

Analyzes code complexity and quality metrics.

## When to Use This Skill

Activate when the user asks to:
- "Analyze code complexity"
- "Check code quality"
- "Find code smells"
- "Review maintainability"
- "Measure cyclomatic complexity"

## Analysis Steps

1. **Identify files**: Use Glob to find relevant source files
2. **Read code**: Read each file's contents
3. **Calculate metrics**:
   - Cyclomatic complexity (branches + 1)
   - Function length
   - Nesting depth
   - Code duplication
4. **Identify patterns**:
   - Long methods (>50 lines)
   - Deep nesting (>4 levels)
   - High complexity (>10)
   - Duplicate code blocks
5. **Generate report**: Output findings in markdown

## Output Format

```markdown
# Code Complexity Report

## Summary
- Files analyzed: X
- Average complexity: Y
- Issues found: Z

## High Complexity Functions

### `functionName` in file.py:123
- Complexity: 15
- Lines: 87
- Recommendation: Split into smaller functions

## Code Smells

- [file.py:45] Long method (73 lines)
- [file.py:102] Deep nesting (5 levels)
```

## Metrics Reference

- **Low complexity**: 1-10 (good)
- **Medium complexity**: 11-20 (moderate risk)
- **High complexity**: 21+ (needs refactoring)
```

### Example 2: Test Generator Skill

```markdown
---
name: test-generator
description: Generate unit tests for Python, JavaScript, TypeScript, and Go code. Use when user asks to create tests, write test cases, add test coverage, generate test suites, or write unit tests.
---

# Test Generator Skill

Automatically generates comprehensive unit tests for code.

## Supported Languages

- Python (pytest, unittest)
- JavaScript (Jest, Mocha)
- TypeScript (Jest, Vitest)
- Go (testing package)

## When to Use This Skill

Activate when the user:
- Asks to "generate tests"
- Wants to "create test cases"
- Requests "test coverage"
- Says "write unit tests"

## Test Generation Workflow

1. **Analyze target code**:
   - Read the source file
   - Identify functions/methods
   - Understand parameters and return types
   - Note edge cases

2. **Determine test framework**:
   - Python: pytest (default) or unittest
   - JavaScript/TypeScript: Jest (default)
   - Go: built-in testing package

3. **Generate test cases**:
   - Happy path (expected behavior)
   - Edge cases (boundary conditions)
   - Error cases (invalid inputs)
   - Integration points (if applicable)

4. **Structure tests**:
   - Use descriptive test names
   - Follow AAA pattern (Arrange, Act, Assert)
   - Include setup/teardown if needed
   - Add docstrings/comments

5. **Write test file**:
   - Follow naming convention (`test_*.py`, `*.test.ts`, etc.)
   - Place in appropriate directory
   - Include necessary imports

## Test Structure Template

### Python (pytest)
```python
import pytest
from module import function_to_test

def test_function_happy_path():
    """Test normal operation."""
    # Arrange
    input_data = ...

    # Act
    result = function_to_test(input_data)

    # Assert
    assert result == expected_value

def test_function_edge_case():
    """Test boundary condition."""
    ...

def test_function_error_handling():
    """Test error case."""
    with pytest.raises(ValueError):
        function_to_test(invalid_input)
```

## Best Practices

- Cover all public functions/methods
- Test one behavior per test
- Use meaningful test names
- Include edge cases and errors
- Mock external dependencies
- Aim for >80% code coverage
```

### Example 3: Documentation Updater Skill

```markdown
---
name: docs-updater
description: Update documentation files when code changes are detected. Use when user makes code changes and documentation exists, or when user asks to update docs, sync documentation, or refresh API docs.
---

# Documentation Updater Skill

Automatically updates documentation when code changes.

## When to Use This Skill

Activate when:
- User modifies code that has corresponding documentation
- User asks to "update the docs"
- User requests "sync documentation"
- Code changes affect public APIs

## Update Workflow

1. **Detect changes**:
   - Identify modified files
   - Scan for public APIs, functions, classes
   - Note signature changes

2. **Find documentation**:
   - Look for `README.md`
   - Check `docs/` directory
   - Find API reference files
   - Locate inline documentation

3. **Analyze impact**:
   - What changed?
   - Are function signatures different?
   - Are new features added?
   - Is anything removed?

4. **Update documentation**:
   - Modify affected sections
   - Update code examples
   - Refresh API signatures
   - Add new sections if needed
   - Remove obsolete content

5. **Verify accuracy**:
   - Check all references are valid
   - Ensure examples work
   - Validate links
   - Confirm version numbers

## Documentation Types

### API Documentation
- Update endpoint descriptions
- Refresh request/response examples
- Update parameter tables
- Modify status codes

### README Files
- Update installation instructions
- Refresh usage examples
- Update feature lists
- Modify configuration details

### Inline Documentation
- Update function docstrings
- Refresh parameter descriptions
- Update return value docs
- Modify examples

## Change Detection

```bash
# Identify recent changes
git diff --name-only HEAD~1

# Look for documentation files
find . -name "*.md" -o -name "*.rst"
```

## Prompts for Confirmation

Before making major documentation changes:
1. Show what will be updated
2. Ask user to confirm
3. Explain reasoning for changes
```

## Conclusion

Skills are a powerful way to extend Claude Code plugins with contextual, automatic assistance. By following this guide, you can create effective skills that:

- ✅ Activate automatically when relevant
- ✅ Provide clear, actionable instructions
- ✅ Integrate seamlessly with plugins
- ✅ Enhance user productivity

### Next Steps

1. Review the [doc-generator-with-skills example](../plugins/doc-generator-with-skills/)
2. Create your first skill following this guide
3. Test with various prompts to refine the description
4. Share your plugin with the community

### Additional Resources

- [Skills Documentation](https://code.claude.com/docs/en/skills)
- [Plugins Documentation](https://code.claude.com/docs/en/plugins)
- [Claude Cookbooks - Skills](https://github.com/anthropics/claude-cookbooks/tree/main/skills)
- [Example Plugin](../plugins/doc-generator-with-skills/)

---

**Questions or feedback?** Join the [Claude Developers Discord](https://anthropic.com/discord) to connect with other plugin developers.
