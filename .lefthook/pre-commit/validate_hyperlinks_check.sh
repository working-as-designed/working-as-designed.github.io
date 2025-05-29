#!/bin/bash
# .lefthook/pre-commit/validate_hyperlinks_check.sh

echo "🔗 Checking for broken links in Markdown files..."
lychee --no-progress --max-concurrency 4 "_posts/**/*.md" README.md
status=$?
if [ $status -ne 0 ]; then
  echo "❌ Broken links found. Please fix them before committing."
  exit 1
else
  echo "✅ All links are valid."
fi
