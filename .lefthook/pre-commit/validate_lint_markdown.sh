#!/bin/bash
# filepath: .lefthook/pre-commit/validate_lint_markdown.sh

echo "📝 Running markdownlint on Markdown files..."

# Use local install if available, fallback to global
if [ -f ./node_modules/.bin/markdownlint ]; then
  LINTER=./node_modules/.bin/markdownlint
else
  LINTER=markdownlint
fi

# Lint all Markdown files except dependencies and _site
find . -type f -name "*.md" -not -path "./node_modules/*" -not -path "./venv/*" -not -path "./_site/*" | xargs "$LINTER"
status=$?
if [ $status -ne 0 ]; then
  echo "❌ markdownlint found issues. Please fix them before committing."
  exit 1
else
  echo "✅ All Markdown files pass linting."
fi
