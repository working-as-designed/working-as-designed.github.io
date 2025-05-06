#!/usr/bin/env python3
import os
import yaml
import re

POSTS_DIR = "_posts"
TAGS_DIR = "tags"

def get_all_tags():
    tags = set()

    # Scan all posts
    for filename in os.listdir(POSTS_DIR):
        if filename.endswith('.md'):
            filepath = os.path.join(POSTS_DIR, filename)

            # Open and read the front matter of each post
            with open(filepath, 'r', encoding='utf-8') as file:
                content = file.read()
                # Extract YAML front matter (between the first '---')
                if content.startswith('---'):
                    try:
                        front_matter_end = content.index('---', 3)
                        front_matter = yaml.safe_load(content[3:front_matter_end])

                        # Collect all tags from the post
                        if 'tags' in front_matter:
                            tags.update(front_matter['tags'])

                    except yaml.YAMLError as e:
                        print(f"Error reading front matter in {filename}: {e}")

    return tags

def create_tag_page(tag):
    # Define tag page content
    tag_slug = re.sub(r'\s+', '-', tag.lower())
    tag_page_content = f"""---
layout: tag
tag: {tag}
title: "Posts tagged with {tag}"
permalink: /tags/{tag_slug}/
---
"""

    # Define the file path
    tag_file_path = os.path.join(TAGS_DIR, f"{tag_slug}.md")

    # Create the file if it doesn't already exist
    if not os.path.exists(tag_file_path):
        os.makedirs(TAGS_DIR, exist_ok=True)
        with open(tag_file_path, 'w', encoding='utf-8') as tag_file:
            tag_file.write(tag_page_content)
        print(f"Created tag page for: {tag}")
    else:
        print(f"Tag page for '{tag}' already exists.")

def main():
    tags = get_all_tags()
    print(f"Found tags: {tags}")

    for tag in tags:
        create_tag_page(tag)

if __name__ == "__main__":
    main()

