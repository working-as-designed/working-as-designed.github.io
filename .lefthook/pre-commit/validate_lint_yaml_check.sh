#!/bin/bash
# .lefthook/pre-commit/yaml_lint.sh

echo "🔍 Linting all YAML files..."

# Find all .yml and .yaml files, excluding node_modules and _site
find . \
  -type f \( -iname "*.yml" -o -iname "*.yaml" \) \
  -not -path "./node_modules/*" \
  -not -path "./_site/*" \
  -not -path "./venv/*" \
  -print0 | xargs -0 yamllint