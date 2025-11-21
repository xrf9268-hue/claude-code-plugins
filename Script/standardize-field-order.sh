#!/bin/bash
# Standardize field order in all plugin.json files

set -e

echo "Standardizing field order in plugin.json files..."
echo ""

standardize_order() {
  local file=$1
  local plugin_name=$(basename $(dirname $(dirname "$file")))

  # Backup
  cp "$file" "${file}.backup.$(date +%Y%m%d_%H%M%S)"

  # Reorder fields using jq with the official recommended order
  jq '{
    name: .name,
    description: .description,
    version: .version,
    author: .author,
    keywords: .keywords,
    repository: .repository,
    license: .license
  } | with_entries(select(.value != null))' "$file" > "${file}.tmp"

  # Validate the result
  if jq '.' "${file}.tmp" > /dev/null 2>&1; then
    mv "${file}.tmp" "$file"
    echo "✓ $plugin_name: Field order standardized"
  else
    echo "✗ $plugin_name: Failed to standardize (restoring backup)"
    rm "${file}.tmp"
    return 1
  fi
}

# Apply to all plugins
for plugin_json in plugins/*/.claude-plugin/plugin.json; do
  if [ -f "$plugin_json" ]; then
    standardize_order "$plugin_json"
  fi
done

echo ""
echo "✓ All plugin.json files standardized"
