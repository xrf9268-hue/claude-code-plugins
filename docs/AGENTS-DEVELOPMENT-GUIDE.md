# Claude Code Agents Development Guide

Complete guide to developing agents (sub-agents) for Claude Code plugins. Agents are specialized AI assistants with defined capabilities that Claude can invoke to handle complex, multi-step tasks.

## Table of Contents

- [What are Agents?](#what-are-agents)
- [When to Use Agents](#when-to-use-agents)
- [Agent Structure](#agent-structure)
- [Creating Your First Agent](#creating-your-first-agent)
- [YAML Frontmatter Reference](#yaml-frontmatter-reference)
- [Writing Effective Descriptions](#writing-effective-descriptions)
- [System Prompts](#system-prompts)
- [Tool Access Control](#tool-access-control)
- [Model Selection](#model-selection)
- [Best Practices](#best-practices)
- [Real-World Examples](#real-world-examples)
- [Testing and Debugging](#testing-and-debugging)
- [Troubleshooting](#troubleshooting)

## What are Agents?

Agents (also called sub-agents) are specialized AI assistants that run in independent context windows with defined capabilities. They're perfect for:

- **Complex analysis tasks** - Deep code review, architecture analysis
- **Multi-step workflows** - Feature development, debugging investigations
- **Specialized expertise** - Security audits, performance optimization
- **Focused execution** - With limited tool access for safety

### Key Characteristics

- 🎯 **Specialized**: Each agent has a single, well-defined purpose
- 🔒 **Isolated**: Runs in separate context window
- 🛠️ **Tool-limited**: Can restrict access to specific tools
- 🤖 **Model-specific**: Can specify which Claude model to use
- 📋 **Explicit invocation**: Claude decides when to use based on description

## When to Use Agents

### Use Agents When You Need:

✅ **Deep, focused analysis**
- Code review with specific criteria
- Architecture evaluation
- Performance profiling
- Security audits

✅ **Multi-step workflows**
- Feature development phases
- Systematic debugging
- Comprehensive testing

✅ **Specialized expertise**
- Domain-specific knowledge
- Particular coding standards
- Platform-specific guidance

✅ **Tool restrictions**
- Read-only analysis
- Limited scope operations
- Security-sensitive tasks

### Don't Use Agents For:

❌ **Simple one-off tasks** - Use regular Claude or commands
❌ **Context-aware auto-activation** - Use Skills instead
❌ **User-invoked workflows** - Use Slash Commands instead

### Agents vs Other Components

| Feature | Agents | Skills | Commands |
|---------|--------|--------|----------|
| **Invocation** | Claude decides | Auto-activated | User types `/command` |
| **Context** | Separate window | Shared context | Shared context |
| **Best for** | Complex analysis | Contextual help | Explicit workflows |
| **Tool control** | Can restrict | Can restrict | Usually unrestricted |
| **Example** | Code reviewer | API docs generator | `/commit` |

## Agent Structure

### File Location

Agents live in the `agents/` directory of your plugin:

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json
├── agents/
│   ├── code-reviewer.md
│   ├── architect.md
│   └── security-auditor.md
├── commands/
└── skills/
```

### File Format

Each agent is a Markdown file with YAML frontmatter:

```markdown
---
name: agent-name
description: Clear description of what this agent does and when to use it
tools: Read, Grep, Glob  # Optional: restrict tools
model: opus              # Optional: specify model
color: green             # Optional: UI color
---

# Agent System Prompt

Detailed instructions for the agent...

## Capabilities

What this agent can do...

## Examples

<example>
...
</example>
```

## Creating Your First Agent

### Step 1: Plan Your Agent

Answer these questions:

1. **What is the agent's purpose?** (One sentence)
2. **When should it be invoked?** (Specific scenarios)
3. **What tools does it need?** (Minimal necessary set)
4. **Which model fits best?** (Haiku/Sonnet/Opus)

### Step 2: Create Agent File

```bash
mkdir -p my-plugin/agents
touch my-plugin/agents/code-reviewer.md
```

### Step 3: Add Frontmatter

```markdown
---
name: code-reviewer
description: Use this agent to review code for bugs, style violations, and adherence to project guidelines. Invoke after writing code, before commits, or when code quality needs verification.
tools: Read, Grep, Glob, Bash(git diff:*), Bash(git status:*)
model: opus
color: green
---
```

### Step 4: Write System Prompt

```markdown
You are an expert code reviewer specializing in [your domain].

## Your Responsibilities

1. **Bug Detection**: Identify logic errors, null handling issues, race conditions
2. **Style Compliance**: Check adherence to project style guide (CLAUDE.md)
3. **Best Practices**: Verify code follows established patterns
4. **Security**: Flag potential vulnerabilities

## Review Scope

By default, review unstaged changes from `git diff`. User may specify different scope.

## Output Format

Provide findings in this format:

### Critical Issues (Must Fix)
- [file.js:42] Description and fix suggestion

### Important Issues (Should Fix)
- [file.js:108] Description and fix suggestion

### Suggestions (Consider)
- [file.js:201] Description and rationale

If no issues found, confirm code meets standards.

## Examples

<example>
User: "Review my changes before I commit"
Agent: [Runs git diff, analyzes changes, provides structured feedback]
</example>
```

### Step 5: Test Your Agent

Start Claude Code and trigger the agent:

```
You: "Can you review the code I just wrote?"
Claude: [Should invoke your code-reviewer agent]
```

## YAML Frontmatter Reference

### Required Fields

**name** (required)
```yaml
name: agent-name  # Lowercase, hyphens, unique identifier
```

**description** (required)
```yaml
description: What this agent does and when to invoke it. Be specific about use cases and trigger scenarios.
```

### Optional Fields

**tools**
```yaml
# Restrict to specific tools
tools: Read, Grep, Glob

# Allow specific bash commands
tools: Read, Bash(git:*)

# Allow all tools (default if omitted)
# tools: (omitted or empty)
```

**model**
```yaml
# Specify model
model: sonnet   # Fast, balanced
model: opus     # Most capable
model: haiku    # Fastest, cost-effective

# Inherit from parent (default)
model: inherit
```

**color**
```yaml
# UI color for agent in interface
color: green
color: blue
color: red
color: yellow
color: purple
```

### Example Frontmatter

```yaml
---
name: security-auditor
description: Use this agent to perform comprehensive security audits of code changes. Invoke when reviewing PRs, before releases, or when security is a concern. Checks for OWASP Top 10 vulnerabilities, insecure dependencies, and unsafe patterns.
tools: Read, Grep, Glob, Bash(git:*), Bash(npm audit:*), Bash(pip check:*)
model: opus
color: red
---
```

## Writing Effective Descriptions

The description is **critical** - it determines when Claude invokes your agent.

### Description Best Practices

✅ **Be specific about purpose:**
```yaml
# ❌ Vague
description: Helps with code

# ✅ Specific
description: Reviews TypeScript code for type safety issues, null handling bugs, and async/await anti-patterns
```

✅ **Include trigger scenarios:**
```yaml
description: Use this agent to review code for bugs and style violations. Invoke after writing code, before commits, or when the user asks for code review.
```

✅ **Mention specific keywords:**
```yaml
description: Analyze React components for performance issues including unnecessary re-renders, missing memoization, and expensive computations. Use when user asks about React performance, optimization, or rendering issues.
```

✅ **Provide usage examples:**
```yaml
description: |
  Use this agent when you need to review code for adherence to project guidelines.

  Examples:
  - "Review my recent changes"
  - "Check if this code follows our standards"
  - "Analyze this PR for quality issues"
```

### Description Structure

```yaml
description: |
  [What it does] [Domain/technology] [Specific focus areas].

  [When to invoke]:
  - [Trigger scenario 1]
  - [Trigger scenario 2]

  [Additional context or constraints]
```

## System Prompts

### Anatomy of a Good System Prompt

```markdown
# Role Definition
You are [role] specializing in [domain/expertise].

## Your Responsibilities

1. **Primary Responsibility**: Clear, specific task
2. **Secondary Responsibility**: Supporting tasks
3. **Out of Scope**: What NOT to do

## Input/Scope

Describe what input the agent receives and default scope.

## Methodology

Step-by-step approach:

1. **Step 1**: What to do first
2. **Step 2**: Next action
3. **Step 3**: Final output

## Output Format

Specific format requirements with examples.

## Examples

<example>
Context: [When this happens]
User: "[User request]"
Agent: [Expected behavior/output]
</example>

## Constraints

- Constraint 1
- Constraint 2
```

### Example: Code Reviewer System Prompt

```markdown
You are an expert code reviewer with deep knowledge of modern software development practices.

## Your Responsibilities

**Primary**: Identify bugs, security issues, and style violations
**Secondary**: Suggest improvements and best practices
**Out of Scope**: Refactoring entire codebases (focus on recent changes)

## Review Scope

By default, review unstaged changes from `git diff`. The user may specify:
- Specific files to review
- Particular aspects to focus on
- Different git ranges

## Review Methodology

1. **Scan Changes**: Read all modified files
2. **Categorize Issues**:
   - Critical (breaks functionality, security holes)
   - Important (style violations, code smells)
   - Suggestions (optimizations, improvements)
3. **Assign Confidence**: Rate each issue 0-100 (only report ≥80)
4. **Provide Solutions**: Include specific fix suggestions

## Output Format

### Critical Issues (Confidence ≥90)
- **[file.py:42]** Null pointer dereference
  - **Problem**: Variable can be None
  - **Fix**: Add null check or use Optional type
  - **Confidence**: 95

### Important Issues (Confidence 80-89)
- **[file.py:108]** Long method (87 lines)
  - **Problem**: Violates single responsibility
  - **Fix**: Split into smaller functions
  - **Confidence**: 85

If no issues ≥80 confidence, state: "Code review complete. No high-confidence issues found."

## Examples

<example>
Context: User just implemented authentication feature
User: "Review my auth implementation"
Agent:
1. Runs `git diff` to see changes
2. Analyzes for security issues (password handling, token storage)
3. Checks for null handling, error cases
4. Provides structured feedback with confidence scores
</example>

## Focus Areas

- **Security**: SQL injection, XSS, auth flaws
- **Bugs**: Null handling, race conditions, logic errors
- **Style**: Per CLAUDE.md or language standards
- **Performance**: O(n²) algorithms, unnecessary work
```

## Tool Access Control

### Why Restrict Tools?

Restricting tools improves:
- **Security**: Prevent accidental modifications
- **Focus**: Agent stays on task
- **Performance**: Faster decisions with fewer options
- **Safety**: Read-only analysis can't break things

### How to Restrict Tools

**Unrestricted (default):**
```yaml
---
name: my-agent
description: ...
# tools field omitted = all tools available
---
```

**Specific tools only:**
```yaml
---
name: code-analyzer
description: Read-only code analysis
tools: Read, Grep, Glob
---
```

**Allow bash commands with patterns:**
```yaml
---
name: git-analyzer
description: Git repository analysis
tools: Read, Bash(git:*)
---
```

**Multiple restrictions:**
```yaml
---
name: test-analyzer
description: Test coverage analysis
tools: Read, Grep, Glob, Bash(git diff:*), Bash(pytest:*), Bash(jest:*)
---
```

### Common Tool Combinations

**Read-only analysis:**
```yaml
tools: Read, Grep, Glob
```

**Git operations:**
```yaml
tools: Read, Bash(git:*)
```

**Testing:**
```yaml
tools: Read, Bash(pytest:*), Bash(npm test:*), Bash(jest:*)
```

**Linting:**
```yaml
tools: Read, Bash(eslint:*), Bash(pylint:*), Bash(rubocop:*)
```

## Model Selection

### Available Models

| Model | Speed | Capability | Cost | Best For |
|-------|-------|------------|------|----------|
| **haiku** | Fastest | Good | Lowest | Simple analysis, quick reviews |
| **sonnet** | Fast | Great | Medium | Most tasks, balanced performance |
| **opus** | Slower | Best | Highest | Complex analysis, critical decisions |

### Choosing the Right Model

**Use Haiku when:**
- Simple pattern matching
- Quick sanity checks
- Format validation
- Straightforward analysis

**Use Sonnet when (default):**
- Standard code review
- General analysis
- Most development tasks
- Balanced speed/quality needs

**Use Opus when:**
- Complex architecture decisions
- Security audits
- Subtle bug detection
- Critical quality checks

### Examples

**Fast formatter checker:**
```yaml
---
name: format-checker
description: Quick code formatting validation
tools: Read, Bash(prettier:*), Bash(black:*)
model: haiku
---
```

**Balanced code reviewer:**
```yaml
---
name: code-reviewer
description: Standard code quality review
tools: Read, Grep, Bash(git:*)
model: sonnet  # or omit for default
---
```

**Deep security auditor:**
```yaml
---
name: security-auditor
description: Comprehensive security analysis
tools: Read, Grep, Bash(npm audit:*), Bash(git:*)
model: opus
---
```

## Best Practices

### Design Principles

✅ **Single Responsibility**
```yaml
# ✅ Good: Focused on one thing
name: test-coverage-analyzer
description: Analyzes test coverage gaps

# ❌ Bad: Does too many things
name: code-quality-checker
description: Reviews code, tests, docs, security, performance...
```

✅ **Clear Invocation Criteria**
```yaml
# ✅ Good: Specific trigger conditions
description: Use after implementing new features to verify test coverage. Invoke when user asks about tests, coverage, or testing gaps.

# ❌ Bad: Vague triggers
description: Helps with testing
```

✅ **Appropriate Tool Restrictions**
```yaml
# ✅ Good: Read-only for analysis
name: code-analyzer
tools: Read, Grep, Glob

# ❌ Bad: Full access when not needed
name: code-analyzer
# tools omitted = all tools available
```

✅ **Right Model for Task**
```yaml
# ✅ Good: Haiku for simple checks
name: format-validator
model: haiku

# ❌ Bad: Opus for simple tasks
name: format-validator
model: opus  # Unnecessary, slower, expensive
```

### Content Structure

✅ **Clear sections:**
```markdown
# Role Definition
## Responsibilities
## Methodology
## Output Format
## Examples
## Constraints
```

✅ **Concrete examples:**
```markdown
<example>
Context: Specific situation
User: "Exact user request"
Agent: Expected behavior with details
</example>
```

✅ **Explicit constraints:**
```markdown
## Constraints
- Only review files changed in last commit
- Confidence threshold ≥80 for reporting
- Maximum 10 issues per review
```

### Documentation

✅ **Document in README:**
```markdown
## Agents

### code-reviewer
Reviews code for bugs, style, and best practices.

**When to use:** After writing code, before commits
**Invocation:** "Review my changes"
**Tools:** Read, Grep, Bash(git)
**Model:** Opus
```

✅ **Include usage examples:**
```markdown
### Example Usage

You: "I just implemented user authentication"
Claude: [Invokes code-reviewer agent]
Agent: [Analyzes auth code, provides feedback]
```

## Real-World Examples

### Example 1: Code Reviewer (from pr-review-toolkit)

**File:** `agents/code-reviewer.md`

```markdown
---
name: code-reviewer
description: Use this agent when you need to review code for adherence to project guidelines, style guides, and best practices. This agent should be used proactively after writing or modifying code, especially before committing changes or creating pull requests.
model: opus
color: green
---

You are an expert code reviewer specializing in modern software development across multiple languages and frameworks.

## Review Scope

By default, review unstaged changes from `git diff`. The user may specify different files or scope to review.

## Core Review Responsibilities

**Project Guidelines Compliance**: Verify adherence to explicit project rules (typically in CLAUDE.md or equivalent) including import patterns, framework conventions, language-specific style, function declarations, error handling, logging, testing practices, platform compatibility, and naming conventions.

**Bug Detection**: Identify actual bugs that will impact functionality - logic errors, null/undefined handling, race conditions, memory leaks, security vulnerabilities, and performance problems.

**Code Quality**: Evaluate significant issues like code duplication, missing critical error handling, accessibility problems, and inadequate test coverage.

## Issue Confidence Scoring

Rate each issue from 0-100:

- **0-25**: Likely false positive or pre-existing issue
- **26-50**: Minor nitpick not explicitly in CLAUDE.md
- **51-75**: Valid but low-impact issue
- **76-90**: Important issue requiring attention
- **91-100**: Critical bug or explicit CLAUDE.md violation

**Only report issues with confidence ≥ 80**

## Output Format

Start by listing what you're reviewing. For each high-confidence issue provide:

- Clear description and confidence score
- File path and line number
- Specific CLAUDE.md rule or bug explanation
- Concrete fix suggestion

Group issues by severity (Critical: 90-100, Important: 80-89).

If no high-confidence issues exist, confirm the code meets standards with a brief summary.
```

### Example 2: Architecture Designer

**File:** `agents/code-architect.md`

```markdown
---
name: code-architect
description: Use this agent to design feature architectures and implementation blueprints. Invoke when planning new features, refactoring large sections, or needing structured implementation plans.
tools: Read, Grep, Glob, Bash(git:*)
model: opus
color: blue
---

You are a senior software architect specializing in system design and implementation planning.

## Your Role

Design clear, implementable architectures for new features by:
1. Analyzing existing codebase patterns
2. Identifying integration points
3. Proposing file/module structure
4. Defining interfaces and contracts
5. Outlining implementation phases

## Methodology

### 1. Understand Existing Architecture
- Scan relevant directories
- Identify similar features
- Note established patterns
- Find integration points

### 2. Design Proposal
- Module/file structure
- Key interfaces and types
- Data flow diagrams (Mermaid)
- Integration points

### 3. Implementation Phases
Break down into clear phases:
- Phase 1: Core data structures
- Phase 2: Business logic
- Phase 3: Integration
- Phase 4: Testing

### 4. Risk Assessment
- Technical risks
- Migration concerns
- Performance implications
- Breaking changes

## Output Format

```markdown
# Architecture: [Feature Name]

## Current State Analysis
[Key findings from codebase scan]

## Proposed Architecture

### File Structure
\`\`\`
src/
├── features/
│   └── new-feature/
│       ├── types.ts
│       ├── service.ts
│       └── index.ts
\`\`\`

### Key Interfaces
[TypeScript/interface definitions]

### Data Flow
[Mermaid diagram]

## Implementation Phases

### Phase 1: Foundation
- [ ] Create types
- [ ] Setup service
[...]

## Risks and Mitigation
- **Risk**: [Description]
  - **Mitigation**: [Strategy]
```

<example>
User: "I need to add real-time notifications to the app"
Agent:
1. Scans existing notification/event systems
2. Analyzes WebSocket/SSE usage
3. Designs notification architecture
4. Proposes phased implementation
5. Identifies risks (connection handling, scaling)
</example>
```

### Example 3: Test Analyzer

**File:** `agents/test-analyzer.md`

```markdown
---
name: test-analyzer
description: Analyzes test coverage and identifies critical testing gaps. Use when evaluating test quality, before releases, or when user asks about test coverage or testing completeness.
tools: Read, Grep, Glob, Bash(git:*), Bash(pytest:*), Bash(jest:*), Bash(npm test:*)
model: sonnet
color: yellow
---

You are a QA expert specializing in test coverage analysis and quality assurance.

## Your Mission

Identify critical gaps in test coverage, focusing on:
- Untested edge cases
- Missing error condition tests
- Insufficient integration tests
- Behavioral coverage (not just line coverage)

## Analysis Methodology

1. **Scan Tests**: Read all test files
2. **Analyze Coverage**: Run coverage tools if available
3. **Identify Gaps**: Find untested scenarios
4. **Prioritize**: Rate gaps by criticality (1-10)
5. **Recommend**: Suggest specific tests to add

## Gap Priority Rating

**10 - Critical**: Must add tests
- Authentication/authorization logic
- Payment processing
- Data loss scenarios
- Security-sensitive code

**7-9 - High**: Should add tests
- Error handling paths
- Edge cases (empty arrays, null values)
- Integration points

**4-6 - Medium**: Nice to have
- Happy path variations
- UI interactions
- Non-critical helpers

**1-3 - Low**: Optional
- Trivial getters/setters
- Well-covered utility functions
- Logging code

## Output Format

```markdown
# Test Coverage Analysis

## Summary
- Tests found: X files
- Lines covered: Y%
- Critical gaps: Z

## Critical Gaps (Priority 9-10)

### Gap: Authentication token expiration not tested
- **File**: auth.service.ts:42
- **Missing scenarios**:
  - Token expires mid-request
  - Refresh token fails
  - Multiple concurrent requests
- **Priority**: 10
- **Suggested test**:
  \`\`\`typescript
  it('should handle token expiration during request', async () => {
    // Test implementation
  });
  \`\`\`

[More gaps...]

## Recommendations
1. Add tests for all priority 9-10 gaps
2. Consider integration tests for auth flow
3. Add E2E test for critical user journey
```
```

## Testing and Debugging

### Test Agent Invocation

**Method 1: Direct mention**
```
You: "Use the code-reviewer agent to check my changes"
```

**Method 2: Natural trigger**
```
You: "Can you review this code for issues?"
Claude: [Should invoke code-reviewer based on description]
```

### Verify Agent Behavior

1. **Check invocation** - Did Claude use the agent?
2. **Review scope** - Is agent working on right files?
3. **Validate output** - Does output match expected format?
4. **Tool usage** - Is agent using allowed tools only?

### Common Issues

**Agent not invoked:**
- ✅ Make description more specific
- ✅ Add explicit trigger keywords
- ✅ Include usage examples in description
- ✅ Verify agent file is valid Markdown

**Agent uses wrong tools:**
- ✅ Check `tools` field spelling
- ✅ Verify tool names match exactly
- ✅ Test with minimal tool set first

**Agent output not helpful:**
- ✅ Improve system prompt clarity
- ✅ Add more specific examples
- ✅ Define output format explicitly
- ✅ Add constraints section

### Debugging Tips

**Add logging (in system prompt):**
```markdown
Before starting, output:
"DEBUG: Agent [name] invoked with scope: [scope]"
```

**Test incrementally:**
1. Start with minimal system prompt
2. Add one section at a time
3. Test after each addition
4. Verify each section works

**Use examples heavily:**
```markdown
<example>
Scenario: [Specific situation]
Input: [Exact input]
Expected output: [Detailed expected behavior]
</example>
```

## Troubleshooting

### Agent Not Found

**Problem:** Claude says agent doesn't exist

**Solutions:**
1. ✅ Check file is in `agents/` directory
2. ✅ Verify file is in plugin that's installed
3. ✅ Restart Claude Code after adding agent
4. ✅ Check plugin.json includes agents directory (if specified)

### Wrong Agent Invoked

**Problem:** Claude invokes different agent than expected

**Solutions:**
1. ✅ Make descriptions more distinct
2. ✅ Add specific keywords to each description
3. ✅ Explicitly name agent in request
4. ✅ Check for overlapping trigger conditions

### Agent Exceeds Context

**Problem:** Agent runs out of context window

**Solutions:**
1. ✅ Narrow scope in system prompt
2. ✅ Restrict tools to prevent excessive reading
3. ✅ Add file/line limits to instructions
4. ✅ Use smaller model (haiku) if possible

### Agent Too Slow

**Problem:** Agent takes too long to respond

**Solutions:**
1. ✅ Use faster model (sonnet or haiku)
2. ✅ Reduce scope in system prompt
3. ✅ Limit files to analyze
4. ✅ Optimize tool usage patterns

## Best Practices Summary

### Design
✅ **One purpose per agent** - Don't create mega-agents
✅ **Specific descriptions** - Include trigger keywords and scenarios
✅ **Clear system prompts** - Step-by-step methodology
✅ **Concrete examples** - Show expected behavior

### Implementation
✅ **Restrict tools appropriately** - Minimal necessary set
✅ **Choose right model** - Balance speed/capability/cost
✅ **Structure output** - Consistent, parseable format
✅ **Handle edge cases** - Empty results, errors, scope issues

### Documentation
✅ **Document in README** - List agents with usage
✅ **Include examples** - Show how to invoke
✅ **Explain when to use** - Clear use cases
✅ **Note limitations** - What agent can't do

### Testing
✅ **Test invocation** - Verify trigger conditions work
✅ **Test output** - Verify format and quality
✅ **Test edge cases** - Empty input, errors, large scope
✅ **Test tool restrictions** - Verify tools properly limited

## Additional Resources

### Official Documentation
- [Sub-Agents Guide](https://code.claude.com/docs/en/sub-agents)
- [Plugins Documentation](https://code.claude.com/docs/en/plugins)
- [Plugins Reference](https://code.claude.com/docs/en/plugins-reference)

### Example Plugins with Agents
- [pr-review-toolkit](../plugins/pr-review-toolkit/) - 6 specialized review agents
- [feature-dev](../plugins/feature-dev/) - Code explorer, architect, reviewer
- [agent-sdk-dev](../plugins/agent-sdk-dev/) - SDK verification agents

### Related Guides
- [Skills Development](./INTEGRATING-SKILLS-IN-PLUGINS.md)
- [Hooks Development](./HOOKS-DEVELOPMENT-GUIDE.md)
- [Plugin Installation](./QUICK_PLUGIN_INSTALLATION.md)

---

**Questions or feedback?** Join the [Claude Developers Discord](https://anthropic.com/discord) to connect with other agent developers.

**Last Updated:** 2025-11-09
**Version:** 1.0.0
