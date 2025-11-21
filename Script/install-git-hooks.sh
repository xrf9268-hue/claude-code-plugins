#!/bin/bash
# Install git hooks for plugin configuration validation

set -e

HOOK_FILE=".git/hooks/pre-commit"

echo "Installing pre-commit hook for plugin validation..."

# Create the pre-commit hook
cat > "$HOOK_FILE" << 'EOF'
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
EOF

# Make the hook executable
chmod +x "$HOOK_FILE"

echo ""
echo "✓ Pre-commit hook installed at: $HOOK_FILE"
echo ""
echo "The hook will automatically validate plugin configurations before each commit."
echo "To disable: rm $HOOK_FILE"
echo "To bypass on a specific commit: git commit --no-verify"
