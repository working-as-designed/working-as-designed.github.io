#!/usr/bin/env python3
import os
import sys
import datetime
import re

def slugify(title):
    # Convert to lowercase, remove non-word characters, and replace spaces with dashes
    return re.sub(r'[^a-z0-9]+', '-', title.lower()).strip('-')

def create_post(title):
    today = datetime.date.today()
    year = today.strftime("%Y")
    month = today.strftime("%m")
    day = today.strftime("%d")

    slug = slugify(title)
    filename = f"{year}-{month}-{day}-{slug}.md"
    post_path = os.path.join("_posts", filename)
    asset_path = os.path.join("assets", "images", year, month, slug)

    # Make directories if needed
    os.makedirs(asset_path, exist_ok=True)

    # Markdown front matter template
    content = f"""---
layout: post
title: "{title}"
date: {year}-{month}-{day}
tags: []
---

![Alt text](/assets/images/{year}/{month}/{slug}/image.png)

Write your content here.
"""

    with open(post_path, "w") as f:
        f.write(content)

    print(f"✔ Created post: {post_path}")
    print(f"✔ Created asset folder: {asset_path}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python newpost.py \"Post Title Here\"")
        sys.exit(1)

    title = sys.argv[1]
    create_post(title)

