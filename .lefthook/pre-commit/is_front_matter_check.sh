#!/bin/bash

########
# Checks
########
echo "🔍 Running front matter checks..."

# Check YAML front matter in all Markdown posts
for file in $(git diff --cached --name-only | grep '_posts/.*\.md$'); do
    if ! grep -q "^---" "$file"; then
        echo "❌ Missing front matter in $file"
        exit 1
    fi
done

echo "✅ Front Matter looks good"
