#!/bin/bash

########
# Checks
########
echo "🔍 Running image path validation check..."

# Initialize a list to store validated images
validated_images=()

# Check image references exist
for file in $(git diff --cached --name-only | grep '_posts/.*\.md$'); do
    while IFS= read -r line; do
        # Extract line number and image path
        line_number=$(echo "$line" | cut -d: -f1)
        img=$(echo "$line" | cut -d: -f2-)

        if [ -f ".$img" ]; then
            echo "👍 Image validated: $img (line $line_number in $file)"
            validated_images+=("$img")
        else
            echo "🚨 Warning: percieved image not found: $img (line $line_number in $file)"
        fi
    done < <(grep -n -oP '!\[.*?\]\(\K.*?(?=\))' "$file")
done

echo "✅ Image path validation check complete."
