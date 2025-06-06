#!/bin/bash

#####################
# Tag page automation
#####################

echo "🔁 Generating tag pages..."
python3 ./scripts/generate_tag_pages.py

if [ $? -ne 0 ]; then
  echo "❌ Tag generation failed. Commit aborted."
  exit 1
fi

# Auto-add new tag files to the commit
git add tags/*.html

echo "✅ Tag pages updated and staged."
