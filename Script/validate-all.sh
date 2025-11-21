#!/bin/bash
# Comprehensive plugin validation script
# Validates all plugin configurations against official Claude Code specifications

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

error() {
  echo -e "${RED}✗ ERROR: $1${NC}" >&2
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
  echo -e "${BLUE}ℹ $1${NC}"
}

section() {
  echo ""
  echo "========================================="
  echo "$1"
  echo "========================================="
  echo ""
}

# Check if jq is installed
if ! command -v jq &> /dev/null; then
  error "jq is not installed. Please install jq to run this script."
  echo "  Ubuntu/Debian: sudo apt-get install jq"
  echo "  macOS: brew install jq"
  echo "  Windows: Download from https://stedolan.github.io/jq/"
  exit 1
fi

section "Plugin Configuration Validation"
echo "Validating against official Claude Code specifications"
echo "Documentation: https://code.claude.com/docs/en/plugins"
echo ""

# 1. Validate all plugin.json files
section "1. Validating plugin.json files"

plugin_count=0
for plugin_json in plugins/*/.claude-plugin/plugin.json; do
  if [ ! -f "$plugin_json" ]; then
    continue
  fi

  ((plugin_count++))
  plugin_name=$(dirname $(dirname "$plugin_json"))
  plugin_name=$(basename "$plugin_name")

  echo "Checking: $plugin_name"

  # JSON syntax
  if ! jq '.' "$plugin_json" > /dev/null 2>&1; then
    error "$plugin_name: Invalid JSON syntax"
    echo ""
    continue
  fi

  # Required fields
  if ! jq -e '.name' "$plugin_json" > /dev/null 2>&1; then
    error "$plugin_name: Missing required field 'name'"
  else
    # Validate name format (kebab-case)
    name=$(jq -r '.name' "$plugin_json")
    if ! echo "$name" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
      warning "$plugin_name: Name should be kebab-case (lowercase with hyphens)"
    fi
  fi

  if ! jq -e '.description' "$plugin_json" > /dev/null 2>&1; then
    warning "$plugin_name: Missing recommended field 'description'"
  fi

  if ! jq -e '.version' "$plugin_json" > /dev/null 2>&1; then
    warning "$plugin_name: Missing recommended field 'version'"
  else
    # Check semver format
    version=$(jq -r '.version' "$plugin_json")
    if ! echo "$version" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+'; then
      warning "$plugin_name: Version should follow semantic versioning (e.g., 1.0.0)"
    fi
  fi

  if ! jq -e '.author' "$plugin_json" > /dev/null 2>&1; then
    warning "$plugin_name: Missing recommended field 'author'"
  else
    # Check author structure
    if ! jq -e '.author.name' "$plugin_json" > /dev/null 2>&1; then
      warning "$plugin_name: Author object should have 'name' field"
    fi
    if ! jq -e '.author.email' "$plugin_json" > /dev/null 2>&1; then
      warning "$plugin_name: Author object should have 'email' field"
    fi
  fi

  # Enhanced fields (recommended for discoverability)
  if ! jq -e '.keywords' "$plugin_json" > /dev/null 2>&1; then
    warning "$plugin_name: Missing 'keywords' array (recommended for discoverability)"
  else
    # Check if keywords is an array with elements
    keyword_count=$(jq '.keywords | length' "$plugin_json" 2>/dev/null || echo "0")
    if [ "$keyword_count" -eq 0 ]; then
      warning "$plugin_name: 'keywords' array is empty"
    fi
  fi

  if ! jq -e '.repository' "$plugin_json" > /dev/null 2>&1; then
    warning "$plugin_name: Missing 'repository' field (recommended)"
  else
    # Check repository structure
    if ! jq -e '.repository.type' "$plugin_json" > /dev/null 2>&1; then
      warning "$plugin_name: Repository should have 'type' field (e.g., 'git')"
    fi
    if ! jq -e '.repository.url' "$plugin_json" > /dev/null 2>&1; then
      warning "$plugin_name: Repository should have 'url' field"
    fi
  fi

  if ! jq -e '.license' "$plugin_json" > /dev/null 2>&1; then
    warning "$plugin_name: Missing 'license' field (recommended)"
  fi

  success "$plugin_name: plugin.json validated"
  echo ""
done

info "Validated $plugin_count plugin.json files"

# 2. Validate hooks.json files
section "2. Validating hooks.json files"

hooks_count=0
for hooks_json in plugins/*/hooks/hooks.json; do
  if [ ! -f "$hooks_json" ]; then
    continue
  fi

  ((hooks_count++))
  plugin_name=$(dirname $(dirname "$hooks_json"))
  plugin_name=$(basename "$plugin_name")

  echo "Checking: $plugin_name/hooks/hooks.json"

  # JSON syntax
  if ! jq '.' "$hooks_json" > /dev/null 2>&1; then
    error "$plugin_name: hooks.json has invalid JSON syntax"
    echo ""
    continue
  fi

  # Check for description field
  if ! jq -e '.description' "$hooks_json" > /dev/null 2>&1; then
    warning "$plugin_name: hooks.json should have a 'description' field"
  fi

  # Check for hooks object
  if ! jq -e '.hooks' "$hooks_json" > /dev/null 2>&1; then
    error "$plugin_name: hooks.json missing 'hooks' object"
    echo ""
    continue
  fi

  # Validate lifecycle events structure (SessionStart, PreCompact, etc.)
  lifecycle_events=("PreCompact" "SessionStart" "SessionEnd" "UserPromptSubmit" "Stop" "SubagentStop")
  for event in "${lifecycle_events[@]}"; do
    if jq -e ".hooks.$event" "$hooks_json" > /dev/null 2>&1; then
      # Lifecycle events should have hooks array wrapper
      if ! jq -e ".hooks.$event[0].hooks" "$hooks_json" > /dev/null 2>&1; then
        # Check if it's using the old incorrect structure
        if jq -e ".hooks.$event[0].type" "$hooks_json" > /dev/null 2>&1; then
          error "$plugin_name: $event hook uses incorrect structure (missing 'hooks' wrapper array)"
          echo "         Expected: \"$event\": [{\"hooks\": [{\"type\": \"command\", ...}]}]"
          echo "         Found: Direct type field without hooks wrapper"
        else
          warning "$plugin_name: $event hook has unusual structure"
        fi
      else
        success "$plugin_name: $event hook has correct structure"
      fi
    fi
  done

  # Validate tool-based events (PreToolUse, PostToolUse)
  tool_events=("PreToolUse" "PostToolUse" "PermissionRequest" "Notification")
  for event in "${tool_events[@]}"; do
    if jq -e ".hooks.$event" "$hooks_json" > /dev/null 2>&1; then
      # Should have hooks array
      if ! jq -e ".hooks.$event[0].hooks" "$hooks_json" > /dev/null 2>&1; then
        error "$plugin_name: $event hook missing 'hooks' array"
      fi

      # Should have matcher field
      if ! jq -e ".hooks.$event[0].matcher" "$hooks_json" > /dev/null 2>&1; then
        warning "$plugin_name: $event hook missing 'matcher' field (should specify which tools trigger this hook)"
      else
        matcher=$(jq -r ".hooks.$event[0].matcher" "$hooks_json")
        success "$plugin_name: $event hook has matcher: $matcher"
      fi
    fi
  done

  # Check for CLAUDE_PLUGIN_ROOT usage in commands
  if grep -q '\${CLAUDE_PLUGIN_ROOT}' "$hooks_json"; then
    success "$plugin_name: Uses \${CLAUDE_PLUGIN_ROOT} for hook paths"
  elif grep -q 'CLAUDE_PLUGIN_ROOT' "$hooks_json"; then
    warning "$plugin_name: Found CLAUDE_PLUGIN_ROOT but not in \${...} format"
  else
    warning "$plugin_name: Consider using \${CLAUDE_PLUGIN_ROOT} for portable hook paths"
  fi

  # Check that commands have explicit interpreter
  commands=$(jq -r '.. | .command? | select(. != null)' "$hooks_json" 2>/dev/null)
  if [ -n "$commands" ]; then
    while IFS= read -r cmd; do
      if [[ ! "$cmd" =~ ^(bash|sh|python3?|node|ruby|perl) ]]; then
        # Check if it starts with ${CLAUDE_PLUGIN_ROOT}
        if [[ ! "$cmd" =~ ^\$\{CLAUDE_PLUGIN_ROOT\} ]]; then
          warning "$plugin_name: Command should start with explicit interpreter or \${CLAUDE_PLUGIN_ROOT}"
        fi
      fi
    done <<< "$commands"
  fi

  echo ""
done

info "Validated $hooks_count hooks.json files"

# 3. Validate SKILL.md files
section "3. Validating SKILL.md files"

skill_count=0
for skill_md in plugins/*/skills/*/SKILL.md; do
  if [ ! -f "$skill_md" ]; then
    continue
  fi

  ((skill_count++))
  skill_path=$(dirname "$skill_md")
  skill_name=$(basename "$skill_path")
  plugin_name=$(basename $(dirname $(dirname "$skill_path")))

  echo "Checking: $plugin_name/skills/$skill_name/SKILL.md"

  # Check for YAML frontmatter opening
  if ! head -1 "$skill_md" | grep -q "^---$"; then
    error "$plugin_name/$skill_name: Missing YAML frontmatter opening (---)"
    echo ""
    continue
  fi

  # Extract frontmatter (between first and second ---)
  frontmatter=$(sed -n '/^---$/,/^---$/p' "$skill_md" | sed '1d;$d')

  if [ -z "$frontmatter" ]; then
    error "$plugin_name/$skill_name: Empty or malformed YAML frontmatter"
    echo ""
    continue
  fi

  # Check required fields in frontmatter
  if ! echo "$frontmatter" | grep -q "^name:"; then
    error "$plugin_name/$skill_name: Missing required 'name' field in frontmatter"
  else
    # Validate name format
    fm_name=$(echo "$frontmatter" | grep "^name:" | sed 's/^name: *//' | tr -d '"' | tr -d "'")
    if [ -z "$fm_name" ]; then
      error "$plugin_name/$skill_name: 'name' field is empty"
    elif ! echo "$fm_name" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
      warning "$plugin_name/$skill_name: Skill name should be kebab-case (found: '$fm_name')"
    elif [ ${#fm_name} -gt 64 ]; then
      error "$plugin_name/$skill_name: Skill name exceeds 64 characters (${#fm_name} chars)"
    else
      success "$plugin_name/$skill_name: Valid skill name: $fm_name"
    fi
  fi

  if ! echo "$frontmatter" | grep -q "^description:"; then
    error "$plugin_name/$skill_name: Missing required 'description' field in frontmatter"
  else
    # Check description
    desc=$(echo "$frontmatter" | sed -n '/^description:/,/^[a-z-]*:/p' | sed '1s/^description: *//;$d' | tr '\n' ' ')
    if [ -z "$desc" ]; then
      error "$plugin_name/$skill_name: 'description' field is empty"
    elif [ ${#desc} -gt 1024 ]; then
      warning "$plugin_name/$skill_name: Description exceeds 1024 characters (${#desc} chars)"
    elif [ ${#desc} -lt 50 ]; then
      warning "$plugin_name/$skill_name: Description seems short (${#desc} chars). Should include trigger keywords and use cases."
    else
      success "$plugin_name/$skill_name: Good description length (${#desc} chars)"
    fi
  fi

  # Check for closing ---
  closing_count=$(grep -c "^---$" "$skill_md" || echo "0")
  if [ "$closing_count" -lt 2 ]; then
    error "$plugin_name/$skill_name: Missing closing YAML frontmatter (---)"
  fi

  # Optional: Check for allowed-tools field
  if echo "$frontmatter" | grep -q "^allowed-tools:"; then
    success "$plugin_name/$skill_name: Has allowed-tools restriction"
  fi

  success "$plugin_name/$skill_name: SKILL.md validated"
  echo ""
done

info "Validated $skill_count SKILL.md files"

# 4. Validate marketplace.json
section "4. Validating marketplace.json"

marketplace_json=".claude-plugin/marketplace.json"

if [ ! -f "$marketplace_json" ]; then
  warning "marketplace.json not found at $marketplace_json"
else
  echo "Checking: marketplace.json"

  if ! jq '.' "$marketplace_json" > /dev/null 2>&1; then
    error "marketplace.json: Invalid JSON syntax"
  else
    # Check required fields
    if ! jq -e '.name' "$marketplace_json" > /dev/null 2>&1; then
      error "marketplace.json: Missing required 'name' field"
    fi

    if ! jq -e '.plugins' "$marketplace_json" > /dev/null 2>&1; then
      error "marketplace.json: Missing required 'plugins' array"
    else
      # Check each plugin entry
      entry_count=$(jq '.plugins | length' "$marketplace_json")
      success "marketplace.json: Contains $entry_count plugin entries"

      # Check for consistency in entries
      inconsistent=0
      for i in $(seq 0 $((entry_count - 1))); do
        entry_name=$(jq -r ".plugins[$i].name" "$marketplace_json")

        # Check for version
        if ! jq -e ".plugins[$i].version" "$marketplace_json" > /dev/null 2>&1; then
          warning "marketplace.json: Entry '$entry_name' missing 'version' field"
          ((inconsistent++))
        fi

        # Check for author
        if ! jq -e ".plugins[$i].author" "$marketplace_json" > /dev/null 2>&1; then
          warning "marketplace.json: Entry '$entry_name' missing 'author' field"
          ((inconsistent++))
        fi

        # Check for source
        if ! jq -e ".plugins[$i].source" "$marketplace_json" > /dev/null 2>&1; then
          error "marketplace.json: Entry '$entry_name' missing required 'source' field"
        fi

        # Check for category
        if ! jq -e ".plugins[$i].category" "$marketplace_json" > /dev/null 2>&1; then
          warning "marketplace.json: Entry '$entry_name' missing 'category' field"
        fi
      done

      if [ $inconsistent -gt 0 ]; then
        warning "marketplace.json: $inconsistent entries have incomplete metadata"
      else
        success "marketplace.json: All entries have consistent metadata"
      fi
    fi

    success "marketplace.json: Validated"
  fi
  echo ""
fi

# 5. Check for executable hook scripts
section "5. Checking hook script permissions"

script_count=0
non_executable=0

for script in $(find plugins -path "*/hooks/*.sh" -o -path "*/hooks/*.py" -o -path "*/hooks-handlers/*.sh" 2>/dev/null); do
  if [ -f "$script" ]; then
    ((script_count++))
    if [ ! -x "$script" ]; then
      warning "Script not executable: $script"
      ((non_executable++))
    fi

    # Check for shebang
    first_line=$(head -1 "$script")
    if [[ ! "$first_line" =~ ^#!/ ]]; then
      warning "Missing shebang: $script"
    fi
  fi
done

if [ $script_count -eq 0 ]; then
  info "No hook scripts found"
elif [ $non_executable -eq 0 ]; then
  success "All $script_count hook scripts are executable"
else
  warning "$non_executable out of $script_count hook scripts are not executable"
  echo "    Run: chmod +x <script-path> to fix"
fi

# Final Summary
section "Validation Summary"

echo "Configuration Overview:"
echo "  • Plugins validated: $plugin_count"
echo "  • Hooks configs validated: $hooks_count"
echo "  • Skills validated: $skill_count"
echo "  • Hook scripts checked: $script_count"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}✓ All validations passed! Perfect score!${NC}"
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo "Your plugin configurations are fully compliant with"
  echo "official Claude Code specifications."
  echo ""
  exit 0
elif [ $ERRORS -eq 0 ]; then
  echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${YELLOW}⚠ Validation passed with $WARNINGS warnings${NC}"
  echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo "Consider addressing warnings for best practices compliance."
  echo ""
  exit 0
else
  echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${RED}✗ Validation failed${NC}"
  echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${RED}Errors: $ERRORS${NC}"
  echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
  echo ""
  echo "Please fix the errors above before proceeding."
  echo "See IMPLEMENTATION_PLAN.md for guidance."
  echo ""
  exit 1
fi
