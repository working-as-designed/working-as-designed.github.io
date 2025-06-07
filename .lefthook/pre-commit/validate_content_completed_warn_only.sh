#!/bin/bash
# filepath: .lefthook/pre-commit/validate_content_completed_warn_only.sh

echo "🔍 Checking for incomplete content markers in staged posts..."

# List of signifiers (case-insensitive)
SIGNIFIERS="TODO|FIXME|STUB|BOILERPLATE|WIP|TBD|PLACEHOLDER|XXX|HACK|PENDING"

# Find staged Markdown files in _posts/
staged_posts=$(git diff --cached --name-only --diff-filter=ACM | grep -i '^_posts/.*\.md$' || true)

if [ -z "$staged_posts" ]; then
  echo "✅ No staged post files to check."
  exit 0
fi

found=0

for file in $staged_posts; do
  # Search for signifiers, case-insensitive
  if grep -Ein "$SIGNIFIERS" "$file"; then
    echo "⚠️  Warning: Incomplete content marker found in $file"
    found=1
  fi
done

if [ "$found" -eq 0 ]; then
  echo "✅ No incomplete content markers found in staged posts."
else
  echo "⚠️  Warning: Please review incomplete content markers before committing."
fi

# Always allow the commit to proceed
exit 0