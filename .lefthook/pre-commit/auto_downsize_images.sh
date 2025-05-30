#!/bin/bash
# filepath: .lefthook/pre-commit/auto_downsize_images.sh

echo "🖼️  Checking and downsizing large images for mobile-friendliness..."

max_width=600
max_size=1048576 # 1MB in bytes

for file in $(git diff --cached --name-only | grep -Ei '\.(jpe?g|png|webp)$'); do
    if ! identify "$file" > /dev/null 2>&1; then
        echo "⚠️  Skipping $file (not a recognized image file)"
        continue
    fi

    width=$(identify -format "%w" "$file")
    size=$(stat -c %s "$file")

    # Downsize if width > max_width
    if [ "$width" -gt "$max_width" ]; then
        echo "🔧 $file is $width px wide. Resizing to $max_width px..."
        mogrify -resize "${max_width}x" "$file"
        git add "$file"
    fi

    # Compress if file size > max_size (optional, for JPEG/PNG)
    size=$(stat -c %s "$file") # get new size after resize
    if [ "$size" -gt "$max_size" ]; then
        echo "🔧 $file is $(($size / 1024)) KB. Compressing..."
        mogrify -strip -quality 85 "$file"
        git add "$file"
    fi
done

echo "✅ Image downsizing complete."