#!/bin/bash
# filepath: .lefthook/pre-commit/validate_exif_clean.sh

echo "🧹 Stripping EXIF metadata from staged images..."

# Find staged image files (jpg, jpeg, png, tiff)
for file in $(git diff --cached --name-only | grep -Ei '\.(hei(c|f)|jpe?g|mp4|mov|pdf|png|raw|tiff?|webp)$'); do
    exiftool -all= -overwrite-original "$file"
    # Re-add the cleaned file to the commit
    git add "$file"
    echo "✅ Cleaned EXIF from $file"
done

echo "✅ All staged images have been scrubbed of EXIF metadata."