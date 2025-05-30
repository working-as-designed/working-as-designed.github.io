#!/bin/bash
# .lefthook/pre-commit/validate_hyperlinks_check.sh

echo "🔗 Checking for broken links in Markdown files..."

output=$(lychee --no-progress --max-concurrency 4 --accept 408,504 "_posts/**/*.md" README.md)
status=$?

# Count errors that are NOT timeouts
non_timeout_errors=$(echo "$output" | grep -E '\[ERROR\]|\[404\]|\[410\]' | wc -l)

if [ $non_timeout_errors -gt 0 ]; then
  echo "$output"
  echo "❌ Broken links found (excluding timeouts). Please fix them before committing."
  exit 1
else
  echo "$output" | grep -v '\[TIMEOUT\]'
  echo "✅ All links are valid (ignoring timeouts)."
fi