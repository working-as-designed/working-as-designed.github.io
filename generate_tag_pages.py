#!/usr/bin/env python3

import os
import yaml
from glob import glob
from pathlib import Path
from slugify import slugify  # pip install python-slugify

POSTS_DIR = "_posts"
TAGS_DIR = "tags"

def extract_tags_from_post(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
        if content.startswith("---"):
            end = content.find("---", 3)
            if end != -1:
                front_matter = content[3:end]
                try:
                    metadata = yaml.safe_load(front_matter)
                    return metadata.get('tags', [])
                except yaml.YAMLError:
                    print(f"⚠️ Failed to parse YAML in: {file_path}")
    return []

def collect_all_tags():
    tag_map = {}
    for file in glob(f"{POSTS_DIR}/*.md"):
        tags = extract_tags_from_post(file)
        for tag in tags:
            tag_slug = slugify(tag)
            tag_map.setdefault(tag_slug, {
                "name": tag,
                "posts": []
            })
            tag_map[tag_slug]["posts"].append(file)
    return tag_map

def generate_tag_pages(tag_map):
    os.makedirs(TAGS_DIR, exist_ok=True)
    for slug, data in tag_map.items():
        tag_filename = os.path.join(TAGS_DIR, f"{slug}.html")
        with open(tag_filename, 'w', encoding='utf-8') as f:
            f.write(f"""---
layout: custom-tag
title: "Posts tagged with '{data['name']}'"
tag: {data['name']}
permalink: /tags/{slug}.html
---

<!-- This page is auto-generated -->
""")
        print(f"👍 Created tag page: {tag_filename}")

if __name__ == "__main__":
    tag_map = collect_all_tags()
    generate_tag_pages(tag_map)
    print("✅ All tag pages generated successfully.")
