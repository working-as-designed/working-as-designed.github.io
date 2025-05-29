#!/bin/bash
# filepath: .lefthook/pre-commit/validate_spelling_warn_only.sh

echo "🔍 Running codespell for possible misspellings..."

# Run codespell on staged Markdown files in _posts/
files=$(git diff --cached --name-only | grep '_posts/.*\.md$')
if [ -z "$files" ]; then
    echo "✅ No Markdown files to check."
    exit 0
fi

# Run codespell and capture output
output=$(codespell $files)

if [ -n "$output" ]; then
    echo "⚠️  Possible misspellings found:"
    echo "$output"
    echo "⚠️  (These are warnings only. Commit will proceed.)"
else
    echo "✅ No misspellings found."
fi

# Always exit 0 to allow the commit
exit 0