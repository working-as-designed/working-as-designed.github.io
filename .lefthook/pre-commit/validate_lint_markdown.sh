#!/bin/bash

echo "🔎 Linting staged Markdown files..."

# Use local install if available, fallback to global
if [ -f ./node_modules/.bin/markdownlint ]; then
  LINTER=./node_modules/.bin/markdownlint
else
  LINTER=markdownlint
fi

# Find staged Markdown files
staged_md_files=$(git diff --cached --name-only --diff-filter=ACM | grep '\.md$' || true)

if [ -z "$staged_md_files" ]; then
  echo "✅ No staged Markdown files to lint."
  exit 0
fi

# Run markdownlint (replace with your linter if different)
if $LINTER $staged_md_files; then
  echo "✅ All staged Markdown files passed linting."
  exit 0
else
  echo "❌ Markdown linting failed. Please fix the issues above."
  exit 1
fi