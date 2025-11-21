#!/bin/bash
# Add license field to all plugins

set -e

LICENSE="MIT"

echo "Adding license field to all plugins..."
echo ""

for plugin_json in plugins/*/.claude-plugin/plugin.json; do
  if [ ! -f "$plugin_json" ]; then
    continue
  fi

  plugin_name=$(dirname $(dirname "$plugin_json"))
  plugin_name=$(basename "$plugin_name")

  # Check if license already exists
  if jq -e '.license' "$plugin_json" > /dev/null 2>&1; then
    echo "✓ $plugin_name: Already has license field"
  else
    # Backup
    cp "$plugin_json" "${plugin_json}.backup.$(date +%Y%m%d)"

    # Add license
    jq ". + {license: \"$LICENSE\"}" "$plugin_json" > "${plugin_json}.tmp"
    mv "${plugin_json}.tmp" "$plugin_json"

    echo "✓ $plugin_name: Added license field"
  fi
done

echo ""
echo "✓ License field added to all plugins"
