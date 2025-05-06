---
layout: post
title: "Hello World!"
tags: [helloworld, jekyll]
---

## Hello World!

This is more of a test post than anything else, but welcome to my web log! Experience has taught me that computers are pain and that memory is fickle, I'm writing these posts with myself as the primary audience and I'm publishing them so that maybe they can help somebody else out.

Here's some things to know about me that (hopefully) will shine through in the blog posts to come:

1. I'm not a smart person, but I ain't no dumbass. I get by.
     - I make mistakes. A lot of them. Sometimes I choose to work inefficiently, sometimes I just don't know no better.
     - I like for things to just work until the thing is dead, and it's time to fashion a replacement. I'm not trying to work harder than I have to, I'm a bit of a luddite, if it works then it works.
     - I intend to spell everything out plainly in my writing. If it's an instructional, I'll put the exact tools I used, the steps I took, the commands I entered to arrive at the end state. If I don't, get at me, I'll do my best to update the content.
     - Rarely if ever, will I be posting about something novel and new. I'm an iterator and collaborator, I recognise good things and modify them to my own purposes.
2. I suffer from good intentions.
     - Sometimes my eyes are bigger than my stomach. I'll try my best to only write about things that are done, never teasing work to come. A lot of blogs on the internet read like sprints, highly active for a few years and then the author's attention moves on to other things. I'm only human and I'm planning to be one...
3. It's all a work in progress, your inputs are welcomed.
     - I'm never (lol, "never say never") going to add any kind of commenting feature here. But if you know or can find a way to contact me, I'd love to hear what you have to say about the post.
     - Thinking about it a little, that's probably best facilitated through issues, pull requests?, or any contact info that may, or may not be associated to my profile.

<div style="text-align: center;">
![pika](/assets/images/2025/05/helloworld/hello_pikachu.png)
</div>

## Setup of this web log

Like all my programming these days, I started with GPT. I'll save you all the errors that it made, and stick to the salient points.

1. Use Jekyll
    - **Why?** It's easy, it's static content, it's a relatively ancient tool, and it works with github pages. That's all we need for now. This is a god time to go find a plastic baggie, because you're probably going to throw up in your mouth a little bit. It's Ruby!
2. Create the github repo
   - For me, its `working-as-designed.github.io`. Wow! nobody claimed it already. So lucky.
3. Add some content to your local repo. You'll want:
    ```
    Gemfile
    _config.yml
    _layouts/tag_page.html (for using jekyll's built-in tagging feature)
    _posts/
    assets/
    ```
4. Add the needful to the `Gemfile`. These are the imports that github will need to be making on our behalf.
    ```
    gem "jekyll", "~> 4.3.3"

    # Plugins
    gem "jekyll-feed"
    gem "jekyll-seo-tag"
    gem "minimal-mistakes-jekyll"
    ```
5. Create a basic `_config.yml`. This is an ultra-basic configuration, cause we keep it simple, baby
    ```yml
    title: working-as-designed
    description: This is my blog. There are many like it, but this one is mine.
    baseurl: ""
    url: "https://working-as-designed.github.io"
    theme: minimal-mistakes-jekyll

    plugins:
    - jekyll-feed
    - jekyll-seo-tag

    tag_page_layout: tag_page
    tag_page_dir: tags
    tag_permalink_style: pretty
    ```
6. Create some helper scripts
    1. New Post boilerplate
        ```py
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
        ```
    2. Generate tag pages
        ```py
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
        ```
    3. Make our scripts executable with `chmod +x`
7. Install lefthook (on ubuntu)
    - `curl -1sLf 'https://dl.cloudsmith.io/public/evilmartians/lefthook/setup.deb.sh' | sudo -E bash; sudo apt install lefthook`
    - At the time of this writing, I'm using version `1.11.12`, and GPT is ALL OVER THE PLACE with its' suggestions about it. Beware.
    1. Run `lefthook install` in the repo
        - If lefthook ain't doing shit, you probably need to modify `/lefthook.yml`. We wil return to this momentarily...
    2.  Add some pre-commit scripts
        1. Does your front matter exist?
            ```sh
            echo "🔍 Running front matter checks..."

            # Check YAML front matter in all Markdown posts
            for file in $(git diff --cached --name-only | grep '_posts/.*\.md$'); do
                if ! grep -q "^---" "$file"; then
                    echo "❌ Missing front matter in $file"
                    exit 1
                fi
            done

            echo "✅ Front Matter looks good"
            ```
        2. Are your image paths valid?
            ```sh
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
            ```
        3. Do you need to update/generate tag pages?
            ```sh
            echo "🔁 Generating tag pages..."
            python3 generate_tag_pages.py

            if [ $? -ne 0 ]; then
            echo "❌ Tag generation failed. Commit aborted."
            exit 1
            fi

            # Auto-add new tag files to the commit
            git add tags/*.md

            echo "✅ Tag pages updated and staged."
            ```
    3.  Add some pre-push scripts
        1. Does your blog build?
            ```sh
            echo "🛠 Building site before push..."

            bundle exec jekyll build --future > /dev/null

            if [ $? -ne 0 ]; then
                echo "❌ Jekyll build failed. Push aborted."
                exit 1
            else
                echo "✅ Jekyll build successful. Proceeding with push."
            fi
            ```
    4. Make sure your new scripts are executable with another `chmod +x`
    5. Then, make sure `lefthook.yml` references your pre-commit/pre-push scripts
        ```yml
        pre-commit:
        jobs:
            - name: front_matter_check
            run:
                .lefthook/pre-commit/front_matter_check.sh
            - name: valid_images_check
            run:
                .lefthook/pre-commit/valid_images_check.sh
            - name: tag_page_creation
            run:
                .lefthook/pre-commit/tag_page_creation.sh

        pre-push:
        jobs:
            - name: build_site
            run:
                .lefthook/pre-push/build_site.sh
        ```
8. By now, hopefully you're seeing fun outputs whenever you make new commits to the repo. Make sure to check your `git status` before pushing, you might need to commit newly auto-generated content.