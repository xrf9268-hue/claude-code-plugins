#!/bin/bash
# SessionStart hook - Check for preserved context from previous sessions
#
# Exit codes:
#   0 = Success, hook completed normally (non-blocking)

CONTEXT_DIR=".claude/session-context"
SUMMARY_FILE="$CONTEXT_DIR/summary.json"

# Check if jq is installed
if ! command -v jq &> /dev/null; then
  # jq not found - exit gracefully without blocking
  cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Context Preservation: Active (jq not installed, install with 'brew install jq' or 'apt-get install jq')"
  }
}
EOF
  exit 0
fi

# Check if we have preserved context
if [ -f "$SUMMARY_FILE" ]; then
  # Count total preserved items
  TOTAL_COUNT=$(jq '[.sessions[].contextCount] | add' "$SUMMARY_FILE" 2>/dev/null || echo 0)
  SESSION_COUNT=$(jq '.sessions | length' "$SUMMARY_FILE" 2>/dev/null || echo 0)

  if [ "$TOTAL_COUNT" -gt 0 ]; then
    MESSAGE="📚 Context Preservation: Found $TOTAL_COUNT preserved items from $SESSION_COUNT session(s). Use 'show preserved context' to view."
  else
    MESSAGE="Context Preservation: Active (no previous contexts found)"
  fi
else
  MESSAGE="Context Preservation: Active"
fi

# Output to Claude
cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "$MESSAGE"
  }
}
EOF

exit 0
