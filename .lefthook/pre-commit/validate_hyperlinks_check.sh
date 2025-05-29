#!/bin/bash
# .lefthook/pre-commit/validate_hyperlink_check.sh

echo "🔗 Checking for broken links in Markdown files..."
lychee --no-progress --exclude-mail --max-concurrency 4 "_posts/**/*.md" README.md
status=$?
if [ $status -ne 0 ]; then
  echo "❌ Broken links found. Please fix them before committing."
  exit 1
else
  echo "✅ All links are valid."
fi