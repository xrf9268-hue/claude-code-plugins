#!/bin/bash
# Plugin debugging and functionality test script
# Based on: https://code.claude.com/docs/en/plugins-reference#debugging-and-development-tools

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0
WARNINGS=0
PASSED=0

error() {
  echo -e "${RED}✗ ERROR: $1${NC}" >&2
  ((ERRORS++)) || true
}

warning() {
  echo -e "${YELLOW}⚠ WARNING: $1${NC}"
  ((WARNINGS++)) || true
}

success() {
  echo -e "${GREEN}✓ $1${NC}"
  ((PASSED++)) || true
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

section "Plugin Debugging & Functionality Tests"
echo "Testing all plugins for common issues..."
echo "Based on: https://code.claude.com/docs/en/plugins-reference"
echo ""

# Test 1: plugin.json syntax validation
section "1. Plugin Manifest Validation (plugin.json syntax)"

for plugin_json in plugins/*/.claude-plugin/plugin.json; do
  if [ ! -f "$plugin_json" ]; then
    continue
  fi

  plugin_name=$(basename $(dirname $(dirname "$plugin_json")))
  echo "Testing: $plugin_name"

  # Validate JSON syntax
  if jq empty "$plugin_json" 2>/dev/null; then
    success "$plugin_name: Valid plugin.json syntax"
  else
    error "$plugin_name: Invalid JSON in plugin.json - plugin will fail to load"
  fi
done

# Test 2: Command directory structure
section "2. Command Registration Check (directory structure)"

for plugin_dir in plugins/*/; do
  plugin_name=$(basename "$plugin_dir")

  # Check if plugin has commands directory
  if [ -d "${plugin_dir}commands" ]; then
    # Verify it's at root level, not in .claude-plugin
    if [ -d "${plugin_dir}.claude-plugin/commands" ]; then
      error "$plugin_name: Commands directory in wrong location (.claude-plugin/commands). Should be at plugin root."
    else
      success "$plugin_name: Commands directory correctly located at plugin root"

      # Count commands
      cmd_count=$(find "${plugin_dir}commands" -name "*.md" 2>/dev/null | wc -l)
      if [ "$cmd_count" -gt 0 ]; then
        info "$plugin_name: Found $cmd_count command(s)"
      fi
    fi
  fi
done

# Test 3: Hook script permissions
section "3. Hook Script Execution Check (permissions)"

for script in $(find plugins -path "*/hooks/*.sh" -o -path "*/hooks-handlers/*.sh" -o -path "*/hooks/*.py" 2>/dev/null); do
  script_name=$(basename "$script")
  plugin_name=$(echo "$script" | cut -d'/' -f2)

  if [ -x "$script" ]; then
    success "$plugin_name/$script_name: Executable"
  else
    error "$plugin_name/$script_name: Not executable - hook will fail to run. Fix with: chmod +x $script"
  fi

  # Check for shebang
  if [ -f "$script" ]; then
    first_line=$(head -1 "$script")
    if [[ "$first_line" == \#!* ]]; then
      success "$plugin_name/$script_name: Has shebang ($first_line)"
    else
      warning "$plugin_name/$script_name: Missing shebang line"
    fi
  fi
done

# Test 4: CLAUDE_PLUGIN_ROOT usage
section "4. Path Resolution Check (CLAUDE_PLUGIN_ROOT usage)"

for config_file in $(find plugins -name "hooks.json" -o -name "plugin.json" 2>/dev/null); do
  plugin_name=$(echo "$config_file" | cut -d'/' -f2)
  file_name=$(basename "$config_file")

  # Check for CLAUDE_PLUGIN_ROOT usage in paths
  if grep -q "CLAUDE_PLUGIN_ROOT" "$config_file" 2>/dev/null; then
    success "$plugin_name/$file_name: Uses \${CLAUDE_PLUGIN_ROOT} for paths"
  else
    # Only warn if file contains command/script paths
    if grep -qE "(command|script|path).*:" "$config_file" 2>/dev/null; then
      warning "$plugin_name/$file_name: May need \${CLAUDE_PLUGIN_ROOT} for portability"
    fi
  fi

  # Check for absolute paths (common mistake)
  if grep -qE '(command|script|path).*:.*"/(home|usr|opt|var)' "$config_file" 2>/dev/null; then
    error "$plugin_name/$file_name: Contains absolute paths - will fail on different systems"
  fi
done

# Test 5: Relative path validation
section "5. Relative Path Validation"

for json_file in $(find plugins -name "*.json" 2>/dev/null); do
  plugin_name=$(echo "$json_file" | cut -d'/' -f2)
  file_name=$(basename "$json_file")

  # Check for paths that should be relative
  if grep -qE '"(source|path)":\s*"[^$]' "$json_file" 2>/dev/null; then
    # Extract paths and check if they're relative
    paths=$(grep -oE '"(source|path)":\s*"[^"]*"' "$json_file" | grep -v '\${' | cut -d'"' -f4)
    for path in $paths; do
      if [[ "$path" == /* ]] && [[ "$path" != *'${'* ]]; then
        error "$plugin_name/$file_name: Absolute path '$path' should be relative or use \${CLAUDE_PLUGIN_ROOT}"
      elif [[ "$path" == ./* ]] || [[ "$path" == *'${'* ]]; then
        success "$plugin_name/$file_name: Path '$path' is correctly formatted"
      fi
    done
  fi
done

# Test 6: Skills frontmatter validation
section "6. Skills SKILL.md Frontmatter Check"

for skill_md in plugins/*/skills/*/SKILL.md; do
  if [ ! -f "$skill_md" ]; then
    continue
  fi

  plugin_name=$(echo "$skill_md" | cut -d'/' -f2)
  skill_name=$(basename $(dirname "$skill_md"))

  # Check YAML frontmatter
  if head -1 "$skill_md" | grep -q "^---$"; then
    success "$plugin_name/$skill_name: Has YAML frontmatter"

    # Extract and validate
    frontmatter=$(sed -n '/^---$/,/^---$/p' "$skill_md" | sed '1d;$d')

    if echo "$frontmatter" | grep -q "^name:"; then
      success "$plugin_name/$skill_name: Has name field"
    else
      error "$plugin_name/$skill_name: Missing required 'name' field in frontmatter"
    fi

    if echo "$frontmatter" | grep -q "^description:"; then
      success "$plugin_name/$skill_name: Has description field"
    else
      error "$plugin_name/$skill_name: Missing required 'description' field in frontmatter"
    fi
  else
    error "$plugin_name/$skill_name: Missing YAML frontmatter (must start with ---)"
  fi
done

# Test 7: Agent files check
section "7. Agent Configuration Check"

for agent_md in plugins/*/agents/*.md; do
  if [ ! -f "$agent_md" ]; then
    continue
  fi

  plugin_name=$(echo "$agent_md" | cut -d'/' -f2)
  agent_name=$(basename "$agent_md" .md)

  # Basic validation
  if [ -s "$agent_md" ]; then
    success "$plugin_name/$agent_name: Agent file exists and has content"

    # Check for key agent sections
    if grep -q "^#" "$agent_md"; then
      success "$plugin_name/$agent_name: Has markdown headers"
    else
      warning "$plugin_name/$agent_name: No markdown headers found"
    fi
  else
    error "$plugin_name/$agent_name: Agent file is empty"
  fi
done

# Test 8: MCP Server configuration check
section "8. MCP Server Configuration Check"

for plugin_json in plugins/*/.claude-plugin/plugin.json; do
  if [ ! -f "$plugin_json" ]; then
    continue
  fi

  plugin_name=$(basename $(dirname $(dirname "$plugin_json")))

  # Check if plugin configures MCP servers
  if jq -e '.mcpServers' "$plugin_json" >/dev/null 2>&1; then
    info "$plugin_name: Configures MCP servers"

    # Validate MCP server paths use CLAUDE_PLUGIN_ROOT
    mcp_config=$(jq -r '.mcpServers' "$plugin_json")
    if echo "$mcp_config" | grep -q "CLAUDE_PLUGIN_ROOT"; then
      success "$plugin_name: MCP paths use \${CLAUDE_PLUGIN_ROOT}"
    else
      if echo "$mcp_config" | grep -qE '/(home|usr|opt)'; then
        error "$plugin_name: MCP server uses absolute paths - should use \${CLAUDE_PLUGIN_ROOT}"
      fi
    fi
  fi
done

# Test 9: Check for common file structure issues
section "9. Plugin Structure Validation"

for plugin_dir in plugins/*/; do
  plugin_name=$(basename "$plugin_dir")

  # Skip non-plugin directories
  if [ ! -d "${plugin_dir}.claude-plugin" ]; then
    continue
  fi

  # Check for plugin.json
  if [ -f "${plugin_dir}.claude-plugin/plugin.json" ]; then
    success "$plugin_name: Has plugin.json manifest"
  else
    error "$plugin_name: Missing required plugin.json manifest"
  fi

  # Check for README
  if [ -f "${plugin_dir}README.md" ]; then
    success "$plugin_name: Has README.md documentation"
  else
    warning "$plugin_name: Missing README.md (recommended)"
  fi

  # Identify plugin type
  has_commands=$([ -d "${plugin_dir}commands" ] && echo "yes" || echo "no")
  has_agents=$([ -d "${plugin_dir}agents" ] && echo "yes" || echo "no")
  has_skills=$([ -d "${plugin_dir}skills" ] && echo "yes" || echo "no")
  has_hooks=$([ -d "${plugin_dir}hooks" ] && echo "yes" || echo "no")

  components=""
  [ "$has_commands" = "yes" ] && components="${components}commands "
  [ "$has_agents" = "yes" ] && components="${components}agents "
  [ "$has_skills" = "yes" ] && components="${components}skills "
  [ "$has_hooks" = "yes" ] && components="${components}hooks "

  if [ -n "$components" ]; then
    info "$plugin_name: Contains $components"
  else
    warning "$plugin_name: No commands, agents, skills, or hooks found"
  fi
done

# Test 10: Security check for common issues
section "10. Security & Best Practices Check"

for script in $(find plugins -type f \( -name "*.sh" -o -name "*.py" -o -name "*.js" \) 2>/dev/null); do
  plugin_name=$(echo "$script" | cut -d'/' -f2)
  script_name=$(basename "$script")

  # Check for eval usage (security risk)
  if grep -q "eval " "$script" 2>/dev/null; then
    warning "$plugin_name/$script_name: Uses 'eval' - potential security risk"
  fi

  # Check for hardcoded credentials
  if grep -qiE "(password|api[_-]?key|secret|token)\s*=\s*['\"][^'\"]+['\"]" "$script" 2>/dev/null; then
    error "$plugin_name/$script_name: May contain hardcoded credentials"
  fi
done

# Summary
section "Test Summary"

total_tests=$((PASSED + WARNINGS + ERRORS))

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Passed: $PASSED${NC}"
echo -e "${YELLOW}⚠ Warnings: $WARNINGS${NC}"
echo -e "${RED}✗ Errors: $ERRORS${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
  echo -e "${GREEN}✓✓✓ All plugins pass debugging checks!${NC}"
  echo ""
  echo "Plugins are ready for use. To test plugin loading in Claude Code:"
  echo "  claude --debug"
  echo ""
  exit 0
elif [ $ERRORS -eq 0 ]; then
  echo -e "${YELLOW}⚠ Plugins pass with warnings${NC}"
  echo ""
  echo "Consider addressing warnings for best practices."
  echo "To test plugin loading: claude --debug"
  echo ""
  exit 0
else
  echo -e "${RED}✗ Critical issues found${NC}"
  echo ""
  echo "Fix errors above before using plugins."
  echo "Common fixes:"
  echo "  - chmod +x <script>    # Make scripts executable"
  echo "  - Use \${CLAUDE_PLUGIN_ROOT} in paths"
  echo "  - Fix JSON syntax errors"
  echo ""
  echo "After fixes, test with: claude --debug"
  echo ""
  exit 1
fi
