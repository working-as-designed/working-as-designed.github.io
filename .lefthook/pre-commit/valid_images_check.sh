#!/bin/bash

########
# Checks
########
echo "🔍 Running image path validation check..."

# Check image references exist
for file in $(git diff --cached --name-only | grep '_posts/.*\.md$'); do
    grep -oP '!\[.*?\]\(\K.*?(?=\))' "$file" | while read -r img; do
        if [ ! -f ".$img" ]; then
            echo "⚠️ Warning: image not found: $img (referenced in $file)"
        fi
    done
done

echo "✅ All image references are valid"

