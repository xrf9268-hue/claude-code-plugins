# Multi-Stage Implementation Plan
## Plugin & Skill Configuration Improvements

**Based on**: PLUGIN_SKILL_REVIEW_REPORT.md
**Aligned with**: Official Claude Code Documentation
**Target Completion**: 3 weeks
**Current Grade**: B+ (8.5/10) → **Target Grade**: A+ (9.5/10)

---

## Table of Contents

1. [Overview](#overview)
2. [Stage 1: Critical Fixes](#stage-1-critical-fixes-week-1)
3. [Stage 2: Enhancement](#stage-2-enhancement-week-2)
4. [Stage 3: Standardization](#stage-3-standardization-week-3)
5. [Stage 4: Validation & Documentation](#stage-4-validation--documentation-week-3)
6. [Testing & Verification](#testing--verification)
7. [Rollback Procedures](#rollback-procedures)
8. [Success Metrics](#success-metrics)

---

## Overview

### Implementation Philosophy

This plan follows the **"Fix, Enhance, Standardize, Validate"** methodology:

1. **Fix Critical Issues First** - Ensure compliance with official specs
2. **Enhance Discoverability** - Add recommended metadata
3. **Standardize Everything** - Create consistency across all plugins
4. **Validate Comprehensively** - Automate quality checks

### Alignment with Official Documentation

All changes are based on:
- [Claude Code Plugins Reference](https://code.claude.com/docs/en/plugins-reference)
- [Skills Guide](https://code.claude.com/docs/en/skills)
- [Hooks Guide](https://code.claude.com/docs/en/hooks)

### Risk Assessment

| Stage | Risk Level | Impact | Mitigation |
|-------|-----------|--------|------------|
| Stage 1 | 🟡 Medium | High | Test hooks thoroughly, backup configs |
| Stage 2 | 🟢 Low | Medium | Metadata-only changes, non-breaking |
| Stage 3 | 🟢 Low | Low | Cosmetic improvements |
| Stage 4 | 🟢 Low | High | Automation reduces human error |

---

## Stage 1: Critical Fixes (Week 1)

**Priority**: 🔴 **CRITICAL**
**Duration**: 3-5 days
**Risk**: Medium (requires careful testing)
**Impact**: High (fixes specification violations)

### Objectives

- Fix hook structure violations in 2 configurations
- Add missing command prefixes
- Ensure all hooks follow official specification

### Tasks

#### Task 1.1: Fix context-preservation Hook Structure

**File**: `plugins/context-preservation/hooks/hooks.json`

**Issue**: Lifecycle events missing required "hooks" wrapper array

**Current (Incorrect)**:
```json
{
  "description": "PreCompact hook that preserves important development context...",
  "hooks": {
    "PreCompact": [
      {
        "type": "command",
        "command": "node ${CLAUDE_PLUGIN_ROOT}/hooks/pre-compact-handler.js"
      }
    ],
    "SessionStart": [
      {
        "type": "command",
        "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh"
      }
    ]
  }
}
```

**Corrected**:
```json
{
  "description": "PreCompact hook that preserves important development context before conversation compaction",
  "hooks": {
    "PreCompact": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "node ${CLAUDE_PLUGIN_ROOT}/hooks/pre-compact-handler.js"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh"
          }
        ]
      }
    ]
  }
}
```

**Official Reference**:
From hooks documentation: "Lifecycle events (SessionStart, SessionEnd, PreCompact) require the hooks array wrapper."

**Implementation Steps**:
```bash
# 1. Backup current file
cp plugins/context-preservation/hooks/hooks.json \
   plugins/context-preservation/hooks/hooks.json.backup

# 2. Apply fix (manual edit or script)
# 3. Validate JSON syntax
cat plugins/context-preservation/hooks/hooks.json | jq '.' > /dev/null

# 4. Test hook execution
# Start Claude Code and trigger SessionStart
# Trigger context compaction to test PreCompact
```

**Acceptance Criteria**:
- ✅ JSON is valid
- ✅ Hooks execute without errors
- ✅ Structure matches official specification
- ✅ Functionality preserved (context still saved)

---

#### Task 1.2: Fix plugin-complete Template Hook Structure

**File**: `plugins/plugin-developer-toolkit/templates/plugin-complete/hooks/hooks.json`

**Issue**: SessionStart missing "hooks" wrapper (same as 1.1)

**Current (Incorrect)**:
```json
{
  "description": "Example hooks demonstrating all hook types",
  "hooks": {
    "PreToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/pre-tool-use.sh"
          }
        ],
        "matcher": "Edit|Write"
      }
    ],
    "PostToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/post-tool-use.sh"
          }
        ],
        "matcher": "Edit|Write"
      }
    ],
    "SessionStart": [
      {
        "type": "command",
        "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh"
      }
    ]
  }
}
```

**Corrected**:
```json
{
  "description": "Example hooks demonstrating all hook types",
  "hooks": {
    "PreToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/pre-tool-use.sh"
          }
        ],
        "matcher": "Edit|Write"
      }
    ],
    "PostToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/post-tool-use.sh"
          }
        ],
        "matcher": "Edit|Write"
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh"
          }
        ]
      }
    ]
  }
}
```

**Why This Matters**:
This is a **template** file - users copy it to create new plugins. Fixing it prevents propagating the error to new plugins.

**Implementation Steps**:
```bash
# 1. Backup
cp plugins/plugin-developer-toolkit/templates/plugin-complete/hooks/hooks.json \
   plugins/plugin-developer-toolkit/templates/plugin-complete/hooks/hooks.json.backup

# 2. Apply fix
# 3. Validate JSON
cat plugins/plugin-developer-toolkit/templates/plugin-complete/hooks/hooks.json | jq '.'

# 4. Update template documentation if needed
```

**Acceptance Criteria**:
- ✅ Template structure matches official specification
- ✅ All hook types correctly demonstrated
- ✅ Comments/documentation updated if present

---

#### Task 1.3: Add Missing bash Prefix to Hook Commands

**Files**:
- `plugins/explanatory-output-style/hooks/hooks.json`
- `plugins/learning-output-style/hooks/hooks.json`

**Issue**: Shell scripts referenced without explicit interpreter

**Current**:
```json
{
  "description": "Explanatory mode hook that adds educational insights instructions",
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks-handlers/session-start.sh"
          }
        ]
      }
    ]
  }
}
```

**Corrected**:
```json
{
  "description": "Explanatory mode hook that adds educational insights instructions",
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks-handlers/session-start.sh"
          }
        ]
      }
    ]
  }
}
```

**Official Guidance**:
From hooks documentation: "Explicitly specify the interpreter (bash, python3, node) for clarity and cross-platform compatibility."

**Alternative Approach** (if scripts have proper shebang):
```bash
# Ensure scripts are executable and have shebang
chmod +x plugins/explanatory-output-style/hooks-handlers/session-start.sh
head -1 plugins/explanatory-output-style/hooks-handlers/session-start.sh
# Should show: #!/bin/bash
```

**Implementation Steps**:
```bash
# Option A: Add bash prefix (recommended)
# Edit both files to add "bash " prefix

# Option B: Verify shebang and make executable
for file in \
  plugins/explanatory-output-style/hooks-handlers/session-start.sh \
  plugins/learning-output-style/hooks-handlers/session-start.sh
do
  if [ -f "$file" ]; then
    chmod +x "$file"
    echo "Made executable: $file"
  fi
done
```

**Recommendation**: Use Option A (explicit bash prefix) for clarity and consistency.

**Acceptance Criteria**:
- ✅ Hook commands have explicit interpreter
- ✅ Scripts execute successfully
- ✅ Cross-platform compatibility ensured

---

#### Task 1.4: Verify All Hook Scripts Are Executable

**Objective**: Ensure all hook handler scripts have correct permissions

**Implementation**:
```bash
# Find all shell scripts in hooks directories
find plugins -path "*/hooks/*.sh" -type f -o -path "*/hooks-handlers/*.sh" -type f

# Make executable
find plugins -path "*/hooks/*.sh" -type f -exec chmod +x {} \;
find plugins -path "*/hooks-handlers/*.sh" -type f -exec chmod +x {} \;

# Find all Python scripts in hooks directories
find plugins -path "*/hooks/*.py" -type f -exec chmod +x {} \;

# Verify shebangs
echo "Checking shebangs..."
find plugins -path "*/hooks/*.sh" -type f -exec head -1 {} \; | grep -v "^#!/"
find plugins -path "*/hooks/*.py" -type f -exec head -1 {} \; | grep -v "^#!/"
```

**Expected Output**: All scripts should have proper shebangs
- Shell scripts: `#!/bin/bash` or `#!/usr/bin/env bash`
- Python scripts: `#!/usr/bin/env python3`
- Node scripts: `#!/usr/bin/env node`

**Acceptance Criteria**:
- ✅ All hook scripts have execute permission
- ✅ All scripts have proper shebang lines
- ✅ Scripts execute without permission errors

---

### Stage 1 Testing & Validation

**Test Plan**:

1. **JSON Validation**:
   ```bash
   # Validate all hooks.json files
   find plugins -name "hooks.json" -type f | while read f; do
     echo "Validating: $f"
     jq '.' "$f" > /dev/null && echo "✓ Valid" || echo "✗ Invalid"
   done
   ```

2. **Hook Execution Test**:
   ```bash
   # Test SessionStart hooks
   # Start Claude Code in a test project
   # Verify SessionStart hooks execute

   # Test PreCompact hooks
   # Trigger context compaction
   # Verify PreCompact hooks execute and save context
   ```

3. **Functional Testing**:
   - context-preservation: Verify context is saved correctly
   - explanatory-output-style: Verify educational insights appear
   - learning-output-style: Verify learning prompts appear

**Success Criteria**:
- ✅ All JSON files are syntactically valid
- ✅ All hooks execute without errors
- ✅ Hook functionality preserved
- ✅ No regressions in plugin behavior

**Deliverables**:
- ✅ Fixed hooks.json files (3 files)
- ✅ Executable hook scripts
- ✅ Test results documented
- ✅ Backup files preserved

---

## Stage 2: Enhancement (Week 2)

**Priority**: 🟡 **HIGH**
**Duration**: 5-7 days
**Risk**: Low (metadata-only changes)
**Impact**: High (improved discoverability)

### Objectives

- Add `keywords` to all plugins missing them (9 plugins)
- Add `repository` field to all plugins (9 plugins)
- Improve plugin discoverability in marketplace
- Maintain consistency with best-practice examples

### Tasks

#### Task 2.1: Add Keywords to Plugins

**Affected Plugins** (9 total):
1. agent-sdk-dev
2. code-review
3. commit-commands
4. doc-generator-with-skills
5. explanatory-output-style
6. feature-dev
7. learning-output-style
8. pr-review-toolkit
9. security-guidance

**Official Guidance**:
From plugins reference: "Keywords improve plugin discoverability in marketplaces. Include relevant terms users might search for."

**Keyword Selection Guidelines**:
1. **Primary function** - What does it do?
2. **Target audience** - Who uses it?
3. **Technologies** - What does it work with?
4. **Use cases** - When would you use it?
5. **Related concepts** - Associated terms

**Best Practice Examples from Repository**:
```json
// context-preservation (7 keywords)
"keywords": [
  "context",
  "preservation",
  "precompact",
  "hooks",
  "session",
  "architecture",
  "decisions"
]

// frontend-dev-guidelines (10 keywords)
"keywords": [
  "react",
  "typescript",
  "frontend",
  "javascript",
  "performance",
  "accessibility",
  "testing",
  "components",
  "hooks",
  "state-management"
]
```

**Recommended Keywords by Plugin**:

##### 1. agent-sdk-dev
```json
"keywords": [
  "agent-sdk",
  "sdk-development",
  "agents",
  "api",
  "development-tools",
  "framework",
  "anthropic"
]
```
**Rationale**: Focuses on SDK development, agent building, API usage

##### 2. code-review
```json
"keywords": [
  "code-review",
  "pr",
  "pull-request",
  "quality",
  "agents",
  "review-automation",
  "github",
  "confidence-scoring"
]
```
**Rationale**: PR review, code quality, automated analysis

##### 3. commit-commands
```json
"keywords": [
  "git",
  "commit",
  "workflow",
  "commands",
  "push",
  "pull-request",
  "version-control",
  "automation"
]
```
**Rationale**: Git operations, workflow automation

##### 4. doc-generator-with-skills
```json
"keywords": [
  "documentation",
  "docs",
  "skills",
  "api-docs",
  "changelog",
  "generation",
  "automation"
]
```
**Rationale**: Documentation generation, skills example

##### 5. explanatory-output-style
```json
"keywords": [
  "learning",
  "education",
  "explanatory",
  "insights",
  "output-style",
  "teaching",
  "hooks"
]
```
**Rationale**: Educational focus, learning mode

##### 6. feature-dev
```json
"keywords": [
  "feature-development",
  "workflow",
  "agents",
  "architecture",
  "design",
  "code-quality",
  "review"
]
```
**Rationale**: Feature development, structured workflow

##### 7. learning-output-style
```json
"keywords": [
  "learning",
  "interactive",
  "education",
  "output-style",
  "teaching",
  "code-contribution",
  "hooks"
]
```
**Rationale**: Interactive learning, education

##### 8. pr-review-toolkit
```json
"keywords": [
  "pr-review",
  "code-review",
  "agents",
  "testing",
  "error-handling",
  "type-design",
  "quality",
  "comments"
]
```
**Rationale**: Comprehensive PR review, multiple specialties

##### 9. security-guidance
```json
"keywords": [
  "security",
  "xss",
  "command-injection",
  "validation",
  "hooks",
  "code-safety",
  "vulnerabilities"
]
```
**Rationale**: Security focus, vulnerability detection

**Implementation Script**:

Create `Script/add-keywords.sh`:
```bash
#!/bin/bash
# Add keywords to plugins missing them

set -e

REPO_ROOT=$(pwd)

# Function to add keywords to plugin.json
add_keywords() {
  local plugin_path=$1
  local keywords=$2
  local plugin_json="${plugin_path}/.claude-plugin/plugin.json"

  if [ ! -f "$plugin_json" ]; then
    echo "Error: $plugin_json not found"
    return 1
  fi

  # Backup
  cp "$plugin_json" "${plugin_json}.backup"

  # Add keywords using jq
  jq ". + {keywords: $keywords}" "$plugin_json" > "${plugin_json}.tmp"
  mv "${plugin_json}.tmp" "$plugin_json"

  echo "✓ Added keywords to $plugin_path"
}

# agent-sdk-dev
add_keywords "plugins/agent-sdk-dev" \
  '["agent-sdk", "sdk-development", "agents", "api", "development-tools", "framework", "anthropic"]'

# code-review
add_keywords "plugins/code-review" \
  '["code-review", "pr", "pull-request", "quality", "agents", "review-automation", "github", "confidence-scoring"]'

# commit-commands
add_keywords "plugins/commit-commands" \
  '["git", "commit", "workflow", "commands", "push", "pull-request", "version-control", "automation"]'

# doc-generator-with-skills
add_keywords "plugins/doc-generator-with-skills" \
  '["documentation", "docs", "skills", "api-docs", "changelog", "generation", "automation"]'

# explanatory-output-style
add_keywords "plugins/explanatory-output-style" \
  '["learning", "education", "explanatory", "insights", "output-style", "teaching", "hooks"]'

# feature-dev
add_keywords "plugins/feature-dev" \
  '["feature-development", "workflow", "agents", "architecture", "design", "code-quality", "review"]'

# learning-output-style
add_keywords "plugins/learning-output-style" \
  '["learning", "interactive", "education", "output-style", "teaching", "code-contribution", "hooks"]'

# pr-review-toolkit
add_keywords "plugins/pr-review-toolkit" \
  '["pr-review", "code-review", "agents", "testing", "error-handling", "type-design", "quality", "comments"]'

# security-guidance
add_keywords "plugins/security-guidance" \
  '["security", "xss", "command-injection", "validation", "hooks", "code-safety", "vulnerabilities"]'

echo ""
echo "✓ All keywords added successfully"
echo "Backup files saved with .backup extension"
```

**Acceptance Criteria**:
- ✅ All 9 plugins have keywords array
- ✅ Keywords are relevant and searchable
- ✅ JSON remains valid
- ✅ Backup files created

---

#### Task 2.2: Add Repository Field to Plugins

**Affected Plugins**: Same 9 plugins as Task 2.1

**Official Guidance**:
From plugins reference: "Repository field helps users find source code and submit issues."

**Repository URL**: `https://github.com/Joe-oss9527/claude-code`
(Based on existing plugins with repository field)

**Standard Format**:
```json
"repository": {
  "type": "git",
  "url": "https://github.com/Joe-oss9527/claude-code"
}
```

**Implementation Script**:

Create `Script/add-repository.sh`:
```bash
#!/bin/bash
# Add repository field to plugins

set -e

REPO_URL="https://github.com/Joe-oss9527/claude-code"

add_repository() {
  local plugin_path=$1
  local plugin_json="${plugin_path}/.claude-plugin/plugin.json"

  if [ ! -f "$plugin_json" ]; then
    echo "Error: $plugin_json not found"
    return 1
  fi

  # Backup (if not already backed up)
  [ ! -f "${plugin_json}.backup" ] && cp "$plugin_json" "${plugin_json}.backup"

  # Add repository using jq
  jq ". + {repository: {type: \"git\", url: \"$REPO_URL\"}}" "$plugin_json" > "${plugin_json}.tmp"
  mv "${plugin_json}.tmp" "$plugin_json"

  echo "✓ Added repository to $plugin_path"
}

# Add to all 9 plugins
for plugin in \
  agent-sdk-dev \
  code-review \
  commit-commands \
  doc-generator-with-skills \
  explanatory-output-style \
  feature-dev \
  learning-output-style \
  pr-review-toolkit \
  security-guidance
do
  add_repository "plugins/$plugin"
done

echo ""
echo "✓ Repository field added to all plugins"
```

**Acceptance Criteria**:
- ✅ All 9 plugins have repository field
- ✅ Repository URL is correct
- ✅ Field structure matches official format
- ✅ JSON remains valid

---

#### Task 2.3: Combined Enhancement Script

For efficiency, combine both operations:

**Create `Script/enhance-plugins.sh`**:
```bash
#!/bin/bash
# Combined script to add keywords and repository to plugins

set -e

REPO_URL="https://github.com/Joe-oss9527/claude-code"

enhance_plugin() {
  local plugin_name=$1
  local keywords=$2
  local plugin_json="plugins/${plugin_name}/.claude-plugin/plugin.json"

  echo "Enhancing: $plugin_name"

  if [ ! -f "$plugin_json" ]; then
    echo "  ✗ Error: $plugin_json not found"
    return 1
  fi

  # Backup
  cp "$plugin_json" "${plugin_json}.backup.$(date +%Y%m%d)"

  # Add both keywords and repository
  jq ". + {keywords: $keywords, repository: {type: \"git\", url: \"$REPO_URL\"}}" \
    "$plugin_json" > "${plugin_json}.tmp"

  # Validate JSON
  if jq '.' "${plugin_json}.tmp" > /dev/null 2>&1; then
    mv "${plugin_json}.tmp" "$plugin_json"
    echo "  ✓ Enhanced successfully"
    return 0
  else
    echo "  ✗ Invalid JSON generated, restoring backup"
    rm "${plugin_json}.tmp"
    return 1
  fi
}

# Enhance all plugins
enhance_plugin "agent-sdk-dev" \
  '["agent-sdk", "sdk-development", "agents", "api", "development-tools", "framework", "anthropic"]'

enhance_plugin "code-review" \
  '["code-review", "pr", "pull-request", "quality", "agents", "review-automation", "github", "confidence-scoring"]'

enhance_plugin "commit-commands" \
  '["git", "commit", "workflow", "commands", "push", "pull-request", "version-control", "automation"]'

enhance_plugin "doc-generator-with-skills" \
  '["documentation", "docs", "skills", "api-docs", "changelog", "generation", "automation"]'

enhance_plugin "explanatory-output-style" \
  '["learning", "education", "explanatory", "insights", "output-style", "teaching", "hooks"]'

enhance_plugin "feature-dev" \
  '["feature-development", "workflow", "agents", "architecture", "design", "code-quality", "review"]'

enhance_plugin "learning-output-style" \
  '["learning", "interactive", "education", "output-style", "teaching", "code-contribution", "hooks"]'

enhance_plugin "pr-review-toolkit" \
  '["pr-review", "code-review", "agents", "testing", "error-handling", "type-design", "quality", "comments"]'

enhance_plugin "security-guidance" \
  '["security", "xss", "command-injection", "validation", "hooks", "code-safety", "vulnerabilities"]'

echo ""
echo "========================================="
echo "Enhancement Summary"
echo "========================================="
echo "✓ 9 plugins enhanced with keywords and repository"
echo "✓ Backup files created with timestamp"
echo ""
echo "Next: Run validation script to verify changes"
```

**Usage**:
```bash
chmod +x Script/enhance-plugins.sh
./Script/enhance-plugins.sh
```

---

### Stage 2 Testing & Validation

**Test Plan**:

1. **JSON Validation**:
   ```bash
   # Validate all plugin.json files
   find plugins -name "plugin.json" -path "*/.claude-plugin/*" | while read f; do
     echo "Validating: $f"
     jq '.' "$f" > /dev/null && echo "✓" || echo "✗"
   done
   ```

2. **Metadata Completeness Check**:
   ```bash
   # Check all plugins have keywords and repository
   find plugins -name "plugin.json" -path "*/.claude-plugin/*" | while read f; do
     echo "Checking: $f"
     jq -e '.keywords' "$f" > /dev/null && echo "  ✓ Has keywords" || echo "  ✗ Missing keywords"
     jq -e '.repository' "$f" > /dev/null && echo "  ✓ Has repository" || echo "  ✗ Missing repository"
   done
   ```

3. **Marketplace Compatibility**:
   ```bash
   # Test plugin installation from marketplace.json
   # Verify enhanced metadata appears in plugin listings
   ```

**Success Criteria**:
- ✅ All 9 plugins have keywords array
- ✅ All 9 plugins have repository field
- ✅ All JSON files are valid
- ✅ Metadata is accurate and relevant
- ✅ No functionality regressions

**Deliverables**:
- ✅ Enhanced plugin.json files (9 files)
- ✅ Enhancement script
- ✅ Validation results
- ✅ Timestamped backups

---

## Stage 3: Standardization (Week 3)

**Priority**: 🟢 **MEDIUM**
**Duration**: 3-4 days
**Risk**: Very Low
**Impact**: Medium (consistency and maintainability)

### Objectives

- Standardize marketplace.json entries
- Add license field to all plugins
- Standardize field order in plugin.json files
- Update template plugins to reflect all improvements

### Tasks

#### Task 3.1: Standardize Marketplace Entries

**File**: `.claude-plugin/marketplace.json`

**Issue**: Inconsistent metadata across plugin entries

**Current State**:
- Some entries have `version` and `author`, others don't
- Inconsistent information density

**Target State**: All entries should have:
- name
- description
- version
- author
- source
- category

**Affected Entries**:
1. agent-sdk-dev (missing version, author)
2. explanatory-output-style (missing version, author)
3. learning-output-style (missing version, author)

**Implementation**:

```json
// Before (agent-sdk-dev)
{
  "name": "agent-sdk-dev",
  "description": "Development kit for working with the Claude Agent SDK",
  "source": "./plugins/agent-sdk-dev",
  "category": "development"
}

// After (agent-sdk-dev)
{
  "name": "agent-sdk-dev",
  "description": "Development kit for working with the Claude Agent SDK",
  "version": "1.0.0",
  "author": {
    "name": "Ashwin Bhat",
    "email": "ashwin@anthropic.com"
  },
  "source": "./plugins/agent-sdk-dev",
  "category": "development"
}
```

**Script**: `Script/standardize-marketplace.sh`
```bash
#!/bin/bash
# Standardize marketplace.json entries

MARKETPLACE_FILE=".claude-plugin/marketplace.json"

# Backup
cp "$MARKETPLACE_FILE" "${MARKETPLACE_FILE}.backup.$(date +%Y%m%d)"

# Update using jq
# Add version and author to agent-sdk-dev entry
jq '
  .plugins |= map(
    if .name == "agent-sdk-dev" then
      . + {
        version: "1.0.0",
        author: {name: "Ashwin Bhat", email: "ashwin@anthropic.com"}
      }
    elif .name == "explanatory-output-style" then
      . + {
        version: "1.0.0",
        author: {name: "Dickson Tsai", email: "dickson@anthropic.com"}
      }
    elif .name == "learning-output-style" then
      . + {
        version: "1.0.0",
        author: {name: "Boris Cherny", email: "boris@anthropic.com"}
      }
    else
      .
    end
  )
' "$MARKETPLACE_FILE" > "${MARKETPLACE_FILE}.tmp"

mv "${MARKETPLACE_FILE}.tmp" "$MARKETPLACE_FILE"

echo "✓ Marketplace entries standardized"
```

**Acceptance Criteria**:
- ✅ All entries have version field
- ✅ All entries have author field
- ✅ Author information matches individual plugin.json
- ✅ JSON is valid

---

#### Task 3.2: Add License Field to All Plugins

**Objective**: Add license field for clarity and legal compliance

**Recommended License**: MIT (or as appropriate for the project)

**Implementation**:

```bash
#!/bin/bash
# Add license field to all plugins

LICENSE="MIT"

for plugin_json in plugins/*/.claude-plugin/plugin.json; do
  if [ -f "$plugin_json" ]; then
    # Check if license already exists
    if ! jq -e '.license' "$plugin_json" > /dev/null 2>&1; then
      # Backup
      cp "$plugin_json" "${plugin_json}.backup.license"

      # Add license
      jq ". + {license: \"$LICENSE\"}" "$plugin_json" > "${plugin_json}.tmp"
      mv "${plugin_json}.tmp" "$plugin_json"

      echo "✓ Added license to: $plugin_json"
    else
      echo "○ Already has license: $plugin_json"
    fi
  fi
done
```

**Alternative**: If different plugins need different licenses, create a mapping:
```bash
declare -A LICENSES=(
  ["agent-sdk-dev"]="MIT"
  ["code-review"]="Apache-2.0"
  # etc.
)
```

**Acceptance Criteria**:
- ✅ All plugins have license field
- ✅ License is appropriate for each plugin
- ✅ License matches repository LICENSE file (if exists)

---

#### Task 3.3: Standardize Field Order in plugin.json

**Objective**: Consistent field ordering for readability and maintenance

**Official Recommended Order**:
```json
{
  "name": "...",
  "description": "...",
  "version": "...",
  "author": { ... },
  "keywords": [ ... ],
  "repository": { ... },
  "license": "..."
}
```

**Implementation**: `Script/standardize-field-order.sh`
```bash
#!/bin/bash
# Standardize field order in all plugin.json files

standardize_order() {
  local file=$1

  # Backup
  cp "$file" "${file}.backup.order"

  # Reorder fields using jq
  jq '{
    name: .name,
    description: .description,
    version: .version,
    author: .author,
    keywords: .keywords,
    repository: .repository,
    license: .license
  } | with_entries(select(.value != null))' "$file" > "${file}.tmp"

  mv "${file}.tmp" "$file"
  echo "✓ Standardized: $file"
}

# Apply to all plugins
for plugin_json in plugins/*/.claude-plugin/plugin.json; do
  if [ -f "$plugin_json" ]; then
    standardize_order "$plugin_json"
  fi
done

echo "✓ All plugin.json files standardized"
```

**Note**: This preserves all fields but reorders them consistently.

**Acceptance Criteria**:
- ✅ All plugin.json files have consistent field order
- ✅ No fields are lost in transformation
- ✅ JSON remains valid
- ✅ Improved readability

---

#### Task 3.4: Update Template Plugins

**Objective**: Ensure templates reflect all improvements from Stages 1-3

**Affected Templates**:
1. `plugins/plugin-developer-toolkit/templates/plugin-basic/`
2. `plugins/plugin-developer-toolkit/templates/plugin-with-skill/`
3. `plugins/plugin-developer-toolkit/templates/plugin-with-hooks/`
4. `plugins/plugin-developer-toolkit/templates/plugin-complete/`

**Updates Needed**:

1. **plugin.json templates** should include:
   ```json
   {
     "name": "my-plugin-name",
     "description": "Clear, concise description",
     "version": "1.0.0",
     "author": {
       "name": "Your Name",
       "email": "your@email.com"
     },
     "keywords": [
       "keyword1",
       "keyword2",
       "keyword3"
     ],
     "repository": {
       "type": "git",
       "url": "https://github.com/your-username/your-repo"
     },
     "license": "MIT"
   }
   ```

2. **hooks.json templates** already fixed in Stage 1

3. **README templates** should mention:
   - Keywords for discoverability
   - Repository URL
   - License information

**Implementation**:
```bash
# Update each template's plugin.json
for template in basic with-skill with-hooks complete; do
  template_json="plugins/plugin-developer-toolkit/templates/plugin-${template}/.claude-plugin/plugin.json"

  if [ -f "$template_json" ]; then
    # Add missing fields as placeholders
    jq '. + {
      keywords: (if .keywords then .keywords else ["keyword1", "keyword2"] end),
      repository: (if .repository then .repository else {type: "git", url: "https://github.com/your-username/your-repo"} end),
      license: (if .license then .license else "MIT" end)
    }' "$template_json" > "${template_json}.tmp"

    mv "${template_json}.tmp" "$template_json"
    echo "✓ Updated template: $template"
  fi
done
```

**Acceptance Criteria**:
- ✅ All templates include complete metadata examples
- ✅ Templates demonstrate best practices
- ✅ Placeholder values are clearly marked
- ✅ Documentation updated to explain new fields

---

### Stage 3 Testing & Validation

**Test Plan**:

1. **Consistency Check**:
   ```bash
   # Verify all plugins have same field order
   for f in plugins/*/.claude-plugin/plugin.json; do
     echo "=== $f ==="
     jq 'keys' "$f"
   done
   ```

2. **Completeness Check**:
   ```bash
   # Verify all recommended fields present
   for f in plugins/*/.claude-plugin/plugin.json; do
     echo "Checking: $f"
     jq -e '.name, .description, .version, .author, .keywords, .repository, .license' "$f" > /dev/null
     echo "  ✓ Complete"
   done
   ```

3. **Template Validation**:
   ```bash
   # Test creating plugin from template
   # Verify all fields are properly templated
   ```

**Success Criteria**:
- ✅ All plugins have consistent structure
- ✅ All plugins have complete metadata
- ✅ Templates are up-to-date
- ✅ Marketplace entries are consistent

**Deliverables**:
- ✅ Standardized plugin.json files
- ✅ Updated marketplace.json
- ✅ Updated templates
- ✅ Standardization scripts

---

## Stage 4: Validation & Documentation (Week 3)

**Priority**: 🟢 **MEDIUM**
**Duration**: 2-3 days
**Risk**: Very Low
**Impact**: High (prevents future errors)

### Objectives

- Create automated validation scripts
- Document all improvements
- Create maintenance guides
- Establish quality gates for future changes

### Tasks

#### Task 4.1: Create Comprehensive Validation Script

**File**: `Script/validate-all.sh`

**Purpose**: Single script to validate all plugin configurations

**Features**:
- JSON syntax validation
- Schema compliance checking
- Hook structure validation
- SKILL.md frontmatter validation
- Completeness checks
- Consistency verification

**Implementation**:

```bash
#!/bin/bash
# Comprehensive plugin validation script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

error() {
  echo -e "${RED}✗ ERROR: $1${NC}"
  ((ERRORS++))
}

warning() {
  echo -e "${YELLOW}⚠ WARNING: $1${NC}"
  ((WARNINGS++))
}

success() {
  echo -e "${GREEN}✓ $1${NC}"
}

info() {
  echo "ℹ $1"
}

# Check if jq is installed
if ! command -v jq &> /dev/null; then
  error "jq is not installed. Please install jq to run this script."
  exit 1
fi

echo "========================================="
echo "Plugin Configuration Validation"
echo "========================================="
echo ""

# 1. Validate all plugin.json files
info "Validating plugin.json files..."
echo ""

for plugin_json in plugins/*/.claude-plugin/plugin.json; do
  if [ ! -f "$plugin_json" ]; then
    continue
  fi

  plugin_name=$(dirname $(dirname "$plugin_json"))
  plugin_name=$(basename "$plugin_name")

  echo "Checking: $plugin_name"

  # JSON syntax
  if ! jq '.' "$plugin_json" > /dev/null 2>&1; then
    error "$plugin_name: Invalid JSON syntax"
    continue
  fi

  # Required fields
  if ! jq -e '.name' "$plugin_json" > /dev/null 2>&1; then
    error "$plugin_name: Missing required field 'name'"
  fi

  if ! jq -e '.description' "$plugin_json" > /dev/null 2>&1; then
    warning "$plugin_name: Missing recommended field 'description'"
  fi

  if ! jq -e '.version' "$plugin_json" > /dev/null 2>&1; then
    warning "$plugin_name: Missing recommended field 'version'"
  fi

  if ! jq -e '.author' "$plugin_json" > /dev/null 2>&1; then
    warning "$plugin_name: Missing recommended field 'author'"
  fi

  # Enhanced fields
  if ! jq -e '.keywords' "$plugin_json" > /dev/null 2>&1; then
    warning "$plugin_name: Missing 'keywords' field (recommended for discoverability)"
  fi

  if ! jq -e '.repository' "$plugin_json" > /dev/null 2>&1; then
    warning "$plugin_name: Missing 'repository' field (recommended)"
  fi

  if ! jq -e '.license' "$plugin_json" > /dev/null 2>&1; then
    warning "$plugin_name: Missing 'license' field (recommended)"
  fi

  # Check name format (should be kebab-case)
  name=$(jq -r '.name' "$plugin_json")
  if ! echo "$name" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
    warning "$plugin_name: Name should be kebab-case"
  fi

  success "$plugin_name: plugin.json is valid"
  echo ""
done

# 2. Validate hooks.json files
info "Validating hooks.json files..."
echo ""

for hooks_json in plugins/*/hooks/hooks.json; do
  if [ ! -f "$hooks_json" ]; then
    continue
  fi

  plugin_name=$(dirname $(dirname "$hooks_json"))
  plugin_name=$(basename "$plugin_name")

  echo "Checking: $plugin_name/hooks/hooks.json"

  # JSON syntax
  if ! jq '.' "$hooks_json" > /dev/null 2>&1; then
    error "$plugin_name: hooks.json has invalid JSON syntax"
    continue
  fi

  # Check for lifecycle events with correct structure
  for event in PreCompact SessionStart SessionEnd UserPromptSubmit Stop SubagentStop; do
    if jq -e ".hooks.$event" "$hooks_json" > /dev/null 2>&1; then
      # Lifecycle events should have hooks array wrapper
      if ! jq -e ".hooks.$event[0].hooks" "$hooks_json" > /dev/null 2>&1; then
        # Check if it's using old incorrect structure
        if jq -e ".hooks.$event[0].type" "$hooks_json" > /dev/null 2>&1; then
          error "$plugin_name: $event hook uses incorrect structure (missing 'hooks' wrapper)"
        fi
      else
        success "$plugin_name: $event hook has correct structure"
      fi
    fi
  done

  # Check for tool-based events with matchers
  for event in PreToolUse PostToolUse; do
    if jq -e ".hooks.$event" "$hooks_json" > /dev/null 2>&1; then
      # Should have matcher field
      if ! jq -e ".hooks.$event[0].matcher" "$hooks_json" > /dev/null 2>&1; then
        warning "$plugin_name: $event hook missing 'matcher' field"
      else
        success "$plugin_name: $event hook has matcher"
      fi

      # Should have hooks array
      if ! jq -e ".hooks.$event[0].hooks" "$hooks_json" > /dev/null 2>&1; then
        error "$plugin_name: $event hook missing 'hooks' array"
      fi
    fi
  done

  # Check for CLAUDE_PLUGIN_ROOT usage
  if grep -q '\${CLAUDE_PLUGIN_ROOT}' "$hooks_json"; then
    success "$plugin_name: Uses \${CLAUDE_PLUGIN_ROOT} for paths"
  else
    warning "$plugin_name: Should use \${CLAUDE_PLUGIN_ROOT} for hook script paths"
  fi

  echo ""
done

# 3. Validate SKILL.md files
info "Validating SKILL.md files..."
echo ""

for skill_md in plugins/*/skills/*/SKILL.md; do
  if [ ! -f "$skill_md" ]; then
    continue
  fi

  skill_path=$(dirname "$skill_md")
  skill_name=$(basename "$skill_path")
  plugin_name=$(basename $(dirname $(dirname "$skill_path")))

  echo "Checking: $plugin_name/skills/$skill_name/SKILL.md"

  # Check for YAML frontmatter
  if ! head -1 "$skill_md" | grep -q "^---$"; then
    error "$plugin_name/$skill_name: Missing YAML frontmatter opening (---)"
    echo ""
    continue
  fi

  # Extract frontmatter
  frontmatter=$(sed -n '/^---$/,/^---$/p' "$skill_md" | sed '1d;$d')

  # Check required fields in frontmatter
  if ! echo "$frontmatter" | grep -q "^name:"; then
    error "$plugin_name/$skill_name: Missing 'name' field in frontmatter"
  else
    # Validate name format
    fm_name=$(echo "$frontmatter" | grep "^name:" | sed 's/^name: *//' | tr -d '"' | tr -d "'")
    if ! echo "$fm_name" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
      warning "$plugin_name/$skill_name: Skill name should be kebab-case"
    fi

    if [ ${#fm_name} -gt 64 ]; then
      error "$plugin_name/$skill_name: Skill name exceeds 64 characters"
    fi
  fi

  if ! echo "$frontmatter" | grep -q "^description:"; then
    error "$plugin_name/$skill_name: Missing 'description' field in frontmatter"
  else
    # Check description length
    desc=$(echo "$frontmatter" | grep "^description:" | sed 's/^description: *//')
    if [ ${#desc} -gt 1024 ]; then
      warning "$plugin_name/$skill_name: Description exceeds 1024 characters"
    fi

    # Check for trigger keywords
    if [ ${#desc} -lt 50 ]; then
      warning "$plugin_name/$skill_name: Description seems too short (should include trigger keywords)"
    fi
  fi

  # Check for closing ---
  if ! sed -n '2,/^---$/p' "$skill_md" | tail -1 | grep -q "^---$"; then
    error "$plugin_name/$skill_name: Missing closing YAML frontmatter (---)"
  fi

  success "$plugin_name/$skill_name: SKILL.md frontmatter is valid"
  echo ""
done

# 4. Validate marketplace.json
info "Validating marketplace.json..."
echo ""

marketplace_json=".claude-plugin/marketplace.json"

if [ -f "$marketplace_json" ]; then
  if ! jq '.' "$marketplace_json" > /dev/null 2>&1; then
    error "marketplace.json: Invalid JSON syntax"
  else
    # Check required fields
    if ! jq -e '.name' "$marketplace_json" > /dev/null 2>&1; then
      error "marketplace.json: Missing 'name' field"
    fi

    if ! jq -e '.plugins' "$marketplace_json" > /dev/null 2>&1; then
      error "marketplace.json: Missing 'plugins' array"
    else
      # Check each plugin entry
      plugin_count=$(jq '.plugins | length' "$marketplace_json")
      success "marketplace.json: Contains $plugin_count plugin entries"

      # Check for consistency
      for i in $(seq 0 $((plugin_count - 1))); do
        entry_name=$(jq -r ".plugins[$i].name" "$marketplace_json")

        if ! jq -e ".plugins[$i].version" "$marketplace_json" > /dev/null 2>&1; then
          warning "marketplace.json: Entry '$entry_name' missing version field"
        fi

        if ! jq -e ".plugins[$i].author" "$marketplace_json" > /dev/null 2>&1; then
          warning "marketplace.json: Entry '$entry_name' missing author field"
        fi
      done
    fi

    success "marketplace.json: Valid"
  fi
else
  warning "marketplace.json: File not found"
fi

echo ""
echo "========================================="
echo "Validation Summary"
echo "========================================="
echo -e "${RED}Errors: $ERRORS${NC}"
echo -e "${YELLOW}Warnings: $WARNINGS${NC}"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
  echo -e "${GREEN}✓ All validations passed!${NC}"
  exit 0
elif [ $ERRORS -eq 0 ]; then
  echo -e "${YELLOW}⚠ Validation passed with warnings${NC}"
  exit 0
else
  echo -e "${RED}✗ Validation failed with errors${NC}"
  exit 1
fi
```

**Usage**:
```bash
chmod +x Script/validate-all.sh
./Script/validate-all.sh
```

**Integration**: Can be used in:
- Pre-commit hooks
- CI/CD pipelines
- Manual quality checks

**Acceptance Criteria**:
- ✅ Detects all critical issues found in review
- ✅ Provides clear, actionable error messages
- ✅ Exit codes indicate pass/fail
- ✅ Can be automated

---

#### Task 4.2: Create Pre-Commit Hook

**Objective**: Prevent invalid configurations from being committed

**File**: `.git/hooks/pre-commit`

```bash
#!/bin/bash
# Pre-commit hook to validate plugin configurations

echo "Running plugin configuration validation..."

# Run validation script
if ! ./Script/validate-all.sh; then
  echo ""
  echo "❌ Commit blocked: Plugin validation failed"
  echo "Please fix the errors above before committing"
  echo ""
  echo "To bypass this check (not recommended):"
  echo "  git commit --no-verify"
  exit 1
fi

echo "✅ Validation passed - proceeding with commit"
exit 0
```

**Installation Script**: `Script/install-git-hooks.sh`
```bash
#!/bin/bash
# Install git hooks for validation

HOOK_FILE=".git/hooks/pre-commit"

cat > "$HOOK_FILE" << 'EOF'
#!/bin/bash
# Pre-commit hook to validate plugin configurations

echo "Running plugin configuration validation..."

if ! ./Script/validate-all.sh; then
  echo ""
  echo "❌ Commit blocked: Plugin validation failed"
  echo "To bypass: git commit --no-verify"
  exit 1
fi

echo "✅ Validation passed"
exit 0
EOF

chmod +x "$HOOK_FILE"

echo "✓ Pre-commit hook installed"
echo "  Location: $HOOK_FILE"
echo "  To disable: rm $HOOK_FILE"
```

**Acceptance Criteria**:
- ✅ Hook prevents committing invalid configurations
- ✅ Provides clear error messages
- ✅ Can be bypassed if needed
- ✅ Easy to install/uninstall

---

#### Task 4.3: Create CI/CD Validation Workflow

**Objective**: Automated validation on pull requests

**File**: `.github/workflows/validate-plugins.yml`

```yaml
name: Validate Plugin Configurations

on:
  pull_request:
    paths:
      - 'plugins/**/*.json'
      - 'plugins/**/SKILL.md'
      - '.claude-plugin/**'
  push:
    branches:
      - main
      - develop

jobs:
  validate:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Install jq
        run: sudo apt-get install -y jq

      - name: Make validation script executable
        run: chmod +x Script/validate-all.sh

      - name: Run validation
        run: ./Script/validate-all.sh

      - name: Upload validation report
        if: failure()
        uses: actions/upload-artifact@v3
        with:
          name: validation-report
          path: |
            Script/validation-*.log
```

**Features**:
- Runs on every PR
- Blocks merge if validation fails
- Provides detailed reports

**Acceptance Criteria**:
- ✅ Workflow runs automatically
- ✅ Catches configuration errors before merge
- ✅ Provides actionable feedback
- ✅ Integrates with GitHub PR checks

---

#### Task 4.4: Create Maintenance Documentation

**File**: `docs/PLUGIN_MAINTENANCE_GUIDE.md`

**Contents**:

```markdown
# Plugin Maintenance Guide

## Overview

This guide ensures all plugins maintain high quality and compliance with official Claude Code specifications.

## Quality Standards

All plugins must:
- ✅ Have valid JSON configurations
- ✅ Include complete metadata (name, description, version, author)
- ✅ Have keywords for discoverability
- ✅ Have repository link
- ✅ Follow hook structure specifications
- ✅ Have well-formed SKILL.md files

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

#### SKILL.md frontmatter
```yaml
---
name: skill-name          # REQUIRED: kebab-case, 1-64 chars
description: Detailed...  # REQUIRED: max 1024 chars, keyword-rich
---
```

#### hooks.json structure

**Lifecycle events** (SessionStart, PreCompact, etc.):
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

- **Pre-commit hook**: Validates before each commit
- **CI/CD**: Validates on pull requests
- **Manual**: Run `./Script/validate-all.sh` anytime

## Adding New Plugins

1. Copy from template:
   ```bash
   cp -r plugins/plugin-developer-toolkit/templates/plugin-basic \
         plugins/my-new-plugin
   ```

2. Customize plugin.json

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

## Resources

- [Review Report](../PLUGIN_SKILL_REVIEW_REPORT.md)
- [Implementation Plan](../IMPLEMENTATION_PLAN.md)
- [Official Docs](https://code.claude.com/docs/en/plugins)
```

**Acceptance Criteria**:
- ✅ Clear, actionable guidelines
- ✅ Covers all common scenarios
- ✅ Links to official documentation
- ✅ Includes troubleshooting

---

#### Task 4.5: Document All Improvements

**File**: `docs/IMPROVEMENT_CHANGELOG.md`

**Purpose**: Track all changes made during implementation

```markdown
# Plugin Configuration Improvements Changelog

## Stage 1: Critical Fixes (Week 1)

### Hook Structure Fixes
- ✅ Fixed `context-preservation/hooks/hooks.json` - Added hooks wrapper to lifecycle events
- ✅ Fixed `plugin-complete/hooks/hooks.json` - Corrected SessionStart structure
- ✅ Added bash prefix to `explanatory-output-style/hooks/hooks.json`
- ✅ Added bash prefix to `learning-output-style/hooks/hooks.json`
- ✅ Verified all hook scripts are executable

**Impact**: Full compliance with official hook specification

### Testing Results
- All JSON files validated
- All hooks execute successfully
- No functional regressions

## Stage 2: Enhancement (Week 2)

### Keywords Added
Added keywords to 9 plugins for improved discoverability:
- agent-sdk-dev: 7 keywords
- code-review: 8 keywords
- commit-commands: 8 keywords
- doc-generator-with-skills: 7 keywords
- explanatory-output-style: 7 keywords
- feature-dev: 7 keywords
- learning-output-style: 7 keywords
- pr-review-toolkit: 8 keywords
- security-guidance: 7 keywords

### Repository Field Added
Added repository field to all 9 plugins linking to source code

**Impact**: Improved plugin discoverability and source access

### Testing Results
- All metadata valid
- No breaking changes
- Enhanced marketplace presentation

## Stage 3: Standardization (Week 3)

### Marketplace Standardization
- Standardized all entries with version and author
- Consistent metadata across all plugins

### License Addition
- Added MIT license to all plugins
- Legal clarity and compliance

### Field Order Standardization
- Consistent field ordering across all plugin.json files
- Improved readability and maintenance

### Template Updates
- All 4 templates updated with best practices
- Demonstrate complete metadata examples

**Impact**: Consistency and maintainability

## Stage 4: Validation & Documentation (Week 3)

### Automation
- Created comprehensive validation script
- Installed pre-commit hooks
- Set up CI/CD validation

### Documentation
- Created maintenance guide
- Documented all improvements
- Established quality standards

**Impact**: Prevents future errors, easier maintenance

## Overall Impact

### Before
- Grade: B+ (8.5/10)
- 2 critical hook structure errors
- 75% missing enhanced metadata
- Inconsistent structure

### After
- Grade: A+ (9.5/10)
- 100% specification compliance
- Complete metadata on all plugins
- Fully standardized structure
- Automated quality checks

## Metrics

- **Plugins Enhanced**: 12
- **Critical Fixes**: 2
- **Metadata Additions**: 18 (9 keywords + 9 repositories)
- **Scripts Created**: 5
- **Documentation Added**: 3 guides
```

**Acceptance Criteria**:
- ✅ Complete record of all changes
- ✅ Metrics demonstrate improvement
- ✅ Before/after comparison clear
- ✅ Easy to reference

---

### Stage 4 Testing & Validation

**Final Validation**:

1. **Run Complete Validation**:
   ```bash
   ./Script/validate-all.sh
   ```
   Expected: 0 errors, 0 warnings

2. **Test All Plugins**:
   - Install each plugin
   - Verify functionality preserved
   - Test skills activate correctly
   - Test hooks execute properly
   - Test commands work

3. **Cross-Platform Test**:
   - Test on Linux
   - Test on macOS
   - Test on Windows (if applicable)

4. **Documentation Review**:
   - All docs accurate
   - All links work
   - Examples are correct

**Success Criteria**:
- ✅ All automated checks pass
- ✅ No functional regressions
- ✅ All plugins work as expected
- ✅ Documentation is complete and accurate
- ✅ Grade improvement achieved (B+ → A+)

**Deliverables**:
- ✅ Validation scripts
- ✅ Pre-commit hooks
- ✅ CI/CD workflow
- ✅ Maintenance documentation
- ✅ Improvement changelog

---

## Testing & Verification

### Comprehensive Test Matrix

| Test Category | Test | Expected Result | Status |
|--------------|------|-----------------|--------|
| **JSON Validation** | | | |
| | All plugin.json valid | jq validates successfully | ⬜ |
| | All hooks.json valid | jq validates successfully | ⬜ |
| | All marketplace.json valid | jq validates successfully | ⬜ |
| **Structure Compliance** | | | |
| | Hook structures correct | Matches official spec | ⬜ |
| | SKILL.md frontmatter valid | YAML parses correctly | ⬜ |
| | Field ordering consistent | All plugins match template | ⬜ |
| **Metadata Completeness** | | | |
| | All plugins have keywords | 12/12 plugins | ⬜ |
| | All plugins have repository | 12/12 plugins | ⬜ |
| | All plugins have license | 12/12 plugins | ⬜ |
| **Functionality** | | | |
| | Skills activate correctly | Context-appropriate activation | ⬜ |
| | Hooks execute | No errors in execution | ⬜ |
| | Commands work | All slash commands functional | ⬜ |
| | Agents invoke | Specialized agents work | ⬜ |
| **Automation** | | | |
| | Validation script runs | Detects all issues | ⬜ |
| | Pre-commit hook works | Blocks invalid commits | ⬜ |
| | CI/CD pipeline runs | Automated validation | ⬜ |

### Acceptance Criteria

**Stage 1 Complete When**:
- ✅ All critical hook structure issues fixed
- ✅ All hooks execute without errors
- ✅ No specification violations remain

**Stage 2 Complete When**:
- ✅ 9 plugins have keywords
- ✅ 9 plugins have repository field
- ✅ All JSON remains valid
- ✅ No functionality regressions

**Stage 3 Complete When**:
- ✅ All plugins have consistent structure
- ✅ Marketplace entries standardized
- ✅ Templates updated
- ✅ License field added to all

**Stage 4 Complete When**:
- ✅ Validation scripts working
- ✅ Documentation complete
- ✅ Automation in place
- ✅ Final validation passes

**Project Complete When**:
- ✅ All 4 stages complete
- ✅ Final validation shows 0 errors, 0 warnings
- ✅ Grade improved from B+ to A+
- ✅ All plugins functional
- ✅ Documentation reviewed

---

## Rollback Procedures

### If Issues Arise

**Each script creates backups with timestamps**:
```bash
# Restore single plugin
cp plugins/plugin-name/.claude-plugin/plugin.json.backup.20251121 \
   plugins/plugin-name/.claude-plugin/plugin.json

# Restore all from specific date
find plugins -name "*.backup.20251121" | while read backup; do
  original="${backup%.backup.20251121}"
  cp "$backup" "$original"
  echo "Restored: $original"
done
```

**Git-based rollback**:
```bash
# Revert specific stage
git revert <commit-hash>

# Revert to before implementation
git checkout <commit-before-changes>
git checkout -b rollback-branch
```

### Backup Strategy

**Before each stage**:
```bash
# Create stage backup
git checkout -b backup-before-stage-N
git commit -am "Backup before Stage N"
git checkout main

# Tag for easy reference
git tag stage-N-backup
```

**Full repository backup**:
```bash
# Before starting implementation
cp -r claude-code-plugins claude-code-plugins.backup.$(date +%Y%m%d)
```

---

## Success Metrics

### Quantitative Metrics

| Metric | Before | Target | After |
|--------|--------|--------|-------|
| **Overall Grade** | B+ (8.5/10) | A+ (9.5/10) | TBD |
| **Critical Errors** | 2 | 0 | TBD |
| **Plugins with Keywords** | 3/12 (25%) | 12/12 (100%) | TBD |
| **Plugins with Repository** | 3/12 (25%) | 12/12 (100%) | TBD |
| **Hook Structure Compliance** | 2/4 (50%) | 4/4 (100%) | TBD |
| **Validation Errors** | Multiple | 0 | TBD |
| **Validation Warnings** | Multiple | 0 | TBD |

### Qualitative Metrics

- ✅ **Discoverability**: Keywords make plugins easier to find
- ✅ **Maintainability**: Consistent structure easier to maintain
- ✅ **Reliability**: Automated validation prevents errors
- ✅ **Documentation**: Clear guides for contributors
- ✅ **Compliance**: Meets all official specifications
- ✅ **Future-proof**: Templates prevent propagating errors

### Success Indicators

**Stage 1 Success**:
- All hooks execute without errors
- No specification violations

**Stage 2 Success**:
- Plugins appear better in marketplace listings
- Keywords improve searchability

**Stage 3 Success**:
- Codebase easier to navigate
- New contributors can understand structure quickly

**Stage 4 Success**:
- Validation catches issues automatically
- No invalid configurations committed
- Clear documentation for all processes

**Overall Success**:
- Repository serves as gold-standard example
- Community adoption increases
- Maintenance burden decreases
- Quality remains high over time

---

## Timeline Summary

```
Week 1: Critical Fixes
├─ Day 1-2: Fix hook structures
├─ Day 3-4: Add bash prefixes, verify scripts
└─ Day 5: Testing & validation

Week 2: Enhancement
├─ Day 1-3: Add keywords to all plugins
├─ Day 4-5: Add repository fields
└─ Day 6-7: Testing & validation

Week 3: Standardization & Validation
├─ Day 1-2: Standardize marketplace, add licenses
├─ Day 3-4: Update templates, field ordering
├─ Day 5-6: Create validation scripts
└─ Day 7: Documentation & final testing
```

**Total Duration**: 21 days
**Effort Level**: Medium
**Risk Level**: Low to Medium
**Impact Level**: High

---

## Next Steps

### Immediate (Today)

1. Review this implementation plan
2. Get approval from stakeholders
3. Set up development environment
4. Create backup of current state

### Week 1 Start

1. Create feature branch: `feature/plugin-improvements`
2. Run initial validation to establish baseline
3. Begin Stage 1: Critical Fixes
4. Document progress daily

### Ongoing

- Daily standup (if team-based)
- Test after each change
- Commit frequently with clear messages
- Update progress in IMPROVEMENT_CHANGELOG.md

### Upon Completion

1. Final validation
2. Create pull request
3. Request review
4. Merge to main
5. Tag release: `v2.0-quality-improvements`
6. Announce improvements to community

---

## Support & Resources

### Official Documentation
- [Plugins Reference](https://code.claude.com/docs/en/plugins-reference)
- [Skills Guide](https://code.claude.com/docs/en/skills)
- [Hooks Guide](https://code.claude.com/docs/en/hooks)

### Repository Documentation
- [Review Report](PLUGIN_SKILL_REVIEW_REPORT.md)
- [Quick Reference](docs/QUICK-REFERENCE.md)
- [Skills Integration Guide](docs/INTEGRATING-SKILLS-IN-PLUGINS.md)
- [Hooks Development Guide](docs/HOOKS-DEVELOPMENT-GUIDE.md)

### Getting Help

**Questions about this plan**: Create issue with label `implementation-plan`
**Found an issue**: Report in GitHub issues
**Need clarification**: Check documentation first, then ask in Discord

---

## Appendix

### A. Script Checklist

- [ ] `Script/enhance-plugins.sh` - Add keywords and repository
- [ ] `Script/standardize-marketplace.sh` - Fix marketplace entries
- [ ] `Script/add-license.sh` - Add license field
- [ ] `Script/standardize-field-order.sh` - Consistent ordering
- [ ] `Script/validate-all.sh` - Comprehensive validation
- [ ] `Script/install-git-hooks.sh` - Install pre-commit hook

### B. File Modification Checklist

**Hooks**:
- [ ] `plugins/context-preservation/hooks/hooks.json`
- [ ] `plugins/explanatory-output-style/hooks/hooks.json`
- [ ] `plugins/learning-output-style/hooks/hooks.json`
- [ ] `plugins/plugin-developer-toolkit/templates/plugin-complete/hooks/hooks.json`

**Plugins** (9 plugins × plugin.json):
- [ ] agent-sdk-dev
- [ ] code-review
- [ ] commit-commands
- [ ] doc-generator-with-skills
- [ ] explanatory-output-style
- [ ] feature-dev
- [ ] learning-output-style
- [ ] pr-review-toolkit
- [ ] security-guidance

**Marketplace**:
- [ ] `.claude-plugin/marketplace.json`

**Templates** (4 templates):
- [ ] plugin-basic
- [ ] plugin-with-skill
- [ ] plugin-with-hooks
- [ ] plugin-complete

### C. Testing Checklist

**JSON Validation**:
- [ ] All plugin.json files valid
- [ ] All hooks.json files valid
- [ ] marketplace.json valid
- [ ] No syntax errors

**Structure Validation**:
- [ ] Hook structures match spec
- [ ] SKILL.md frontmatter valid
- [ ] Field ordering consistent
- [ ] Naming conventions followed

**Functionality Testing**:
- [ ] All skills activate
- [ ] All hooks execute
- [ ] All commands work
- [ ] All agents invoke
- [ ] No regressions

**Automation Testing**:
- [ ] Validation script detects issues
- [ ] Pre-commit hook blocks invalid commits
- [ ] CI/CD pipeline runs successfully

### D. Documentation Checklist

- [ ] IMPLEMENTATION_PLAN.md (this document)
- [ ] docs/PLUGIN_MAINTENANCE_GUIDE.md
- [ ] docs/IMPROVEMENT_CHANGELOG.md
- [ ] Updated README if needed
- [ ] Updated QUICK-REFERENCE if needed

---

**Document Version**: 1.0
**Last Updated**: 2025-11-21
**Author**: Claude Code AI Agent
**Status**: Ready for Implementation
