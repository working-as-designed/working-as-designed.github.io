#!/bin/bash
# filepath: .lefthook/pre-commit/validate_node_requirements.sh

echo "🔍 Checking if node_modules matches package-lock.json..."

npm install --package-lock-only > /dev/null 2>&1

if ! npm ci --dry-run > /dev/null 2>&1; then
  echo "❌ node_modules is not in sync with package-lock.json. Run 'npm ci' or 'npm install'."
  exit 1
else
  echo "✅ node_modules is in sync with package-lock.json."
fi
