#!/bin/bash

echo "🛠 Building site before push..."

bundle exec jekyll build --future > /dev/null

if [ $? -ne 0 ]; then
    echo "❌ Jekyll build failed. Push aborted."
    exit 1
else
    echo "✅ Jekyll build successful. Proceeding with push."
fi
