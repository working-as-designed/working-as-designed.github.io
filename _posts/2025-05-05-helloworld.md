---
layout: post
title: "Hello World!"
tags: [helloworld, jekyll]
---

- Table of Contents
{:toc}

**Edit from the future:** I've rewritten or removed most of the jekyll setup portions that are no longer relevant to this blog.

This post is more of a test post than anything else, but welcome to my web log! Experience has taught me that computers are pain and that memory is fickle, I'm writing these posts with myself as the primary audience and I'm publishing them so that maybe they can help somebody else out.

Here's some things to know about me that (hopefully) will shine through in the blog posts to come:

1. I'm not a smart person, but I ain't no dumbass. I get by.
     - I make mistakes. A lot of them. Sometimes I choose to work inefficiently, sometimes I just don't know no better. I always reserve the right to be wrong, so take nothing here as gospel, **think critically**. If the content works for your situation, great!
     - I intend to spell everything out plainly in my writing. If it's an instructional, I'll put the exact tools I used, the steps I took, the commands I entered to arrive at the end state. If I don't, get at me, I'll do my best to update the content.
     - I'm an iterator and collaborator, I recognise good things and modify them to my own purposes. Rarely if ever, will I be posting about something novel and new. I like for things to just work until the thing is dead, and it's time to fashion a replacement. I'm not trying to work harder than I have to, I'm a bit of a luddite, if it works then it works. It's the way of my people.
2. I suffer from good intentions.
     - Sometimes my eyes are bigger than my stomach. I'll try my best to only write about things that are done, never teasing work to come. A lot of blogs on the internet read like sprints, highly active for a few years and then the author's attention moves on to other things. I'm only human and I'm planning to be one...
3. It's all a work in progress, your inputs are welcomed.
     - I'm never (lol, "never say never") going to add any kind of commenting feature here. But if you know or can find a way to contact me, I'd love to hear what you have to say about the post.
     - Thinking about it a little, that's probably best facilitated through issues, pull requests?, or any contact info that may, or may not be associated to my profile.

![pika](/assets/images/2025/05/helloworld/hello_pikachu.png)

---

## Setup of this web log

Like all my programming these days, I started with GPT. I'll save you all the errors that it made, and stick to the salient points.

### Use Jekyll

- **Why?** It's easy, it's static content, it's a relatively ancient tool, and it works with github pages. That's all we need for now. It's powered by Ruby! 🤮
  - Ruby's mostly fine, I just came up in it's era of competition with Python, and I chose my champion early.

### Create the github repo

- For me, its `working-as-designed.github.io`. Wow! nobody claimed it already. _So lucky._

### Add some content to your local repo

You'll want these at least, but probably more depending on how fancy you get with custom theming. I ended up settleing in on the github-pages theme `hacker` because it does most everything i want and the colorscheme is mostly nonoffensive to me.

These are the bare minimum files you'll need to get started. I'd be shocked if jekyll couldn't start a new site with boilerplate for you, but I handcrafted these:

- `Gemfile`
- `_config.yml`
- `index.html`
- `_posts/`
- `assets/`

### Add the needful to the `Gemfile`

These are the imports that github will need to be making on our behalf.

```txt
source "https://rubygems.org"

gem "jekyll"

# Plugins
gem "faraday-retry"
gem "jekyll-feed"
gem "jekyll-remote-theme"
gem "jekyll-seo-tag"
gem "github-pages", group: :jekyll_plugins
```

### Create a basic `_config.yml`

This is an ultra-basic configuration, cause we keep it simple babyyy. we can do fancy things later.

```yml
title: "working-as-designed"
description: "Experiences from security operations, engineering, incident response, and threat detection"
author: "working-as-designed"
baseurl: ""
url: "https://working-as-designed.github.io"
remote_theme: "pages-themes/hacker@v0.2.0"

plugins:
  - "jekyll-remote-theme"
  - "jekyll-feed"
  - "jekyll-seo-tag"
```

### Create some helper scripts

Someday (probably soon) I'll move these into a dedicated directory.

#### New Post boilerplate

- Woah! A python dependency? **yeah, I think we need to manage a venv**. I Don't wanna keep cluttering this post with more code you can reference in the repository, but check out the `Makefile` and `requirements.txt`

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

#### Generate tag pages

{% raw %}

```py
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
layout: default
title: "Posts tagged with '{data['name']}'"
tag: {data['name']}
permalink: /tags/{slug}.html
---

<!-- This page is auto-generated -->

<ul>
{{% for post in site.posts %}}
{{% if post.tags contains '{data['name']}' %}}
    <li><a href="{{{{ post.url }}}}">{{{{ post.title }}}}</a> ({{{{ post.date | date: "%Y-%m-%d" }}}})</li>
{{% endif %}}
{{% endfor %}}
</ul>
""")
        print(f"👍 Created tag page: {tag_filename}")

if __name__ == "__main__":
    tag_map = collect_all_tags()
    generate_tag_pages(tag_map)
    print("✅ All tag pages generated successfully.")

```

{% endraw %}

**Now make our scripts executable with `chmod +x`**

### Create your home page

In your `index.html` file, put down some basic content. Here's enough to show your posts to readers and allow them to dig through your tagged content.

{% raw %}

```html
---
layout: default
title: Home
---

<h1>📝 Latest Posts</h1>

{% if site.posts.size > 0 %}
<ul>
  {% for post in site.posts %}
    <li>
      <a href="{{ post.url | relative_url }}">{{ post.title }}</a>
      <br />
      <small>{{ post.date | date: "%b %d, %Y" }}</small>

      {% if post.tags %}
        <div>
          🏷 Tags:
          {% for tag in post.tags %}
            <a href="{{ '/tags/' | append: tag | slugify | append: '.html' | relative_url }}">{{ tag }}</a>{% unless forloop.last %}, {% endunless %}
          {% endfor %}
        </div>
      {% endif %}
    </li>
  {% endfor %}
</ul>
{% else %}
<p><em>No posts found. Check back later!</em></p>
{% endif %}

<h2>🔖 All Tags</h2>
{% if site.tags %}
<ul>
  {% assign tags = site.tags | sort %}
  {% for tag in tags %}
    <li>
      <a href="{{ '/tags/' | append: tag[0] | append: '.html' | relative_url }}">{{ tag[0] }}</a> ({{ tag[1].size }})
    </li>
  {% endfor %}
</ul>
{% else %}
<p><em>No tags available.</em></p>
{% endif %}
```

{% endraw %}

### Install lefthook (on ubuntu)

- `curl -1sLf 'https://dl.cloudsmith.io/public/evilmartians/lefthook/setup.deb.sh' | sudo -E bash; sudo apt install lefthook`
  - Yeah, curlbashing is definitely not great. but sometimes, ya gotta do it. audit the code first and develop a sense of (dis)trust.
- At the time of this writing, I'm using version `1.11.12`, and GPT is ALL OVER THE PLACE with its' suggestions about it. Beware.
- Check out [the repo for this site](https://github.com/working-as-designed/working-as-designed.github.io/tree/main/.lefthook) to see future additions.
- **Run `lefthook install` in the repo**

- If lefthook ain't doing shit, you probably need to modify `/lefthook.yml`. We will return to this momentarily...

#### Add some pre-commit scripts

In `.lefthook/pre-commit/`, add files for the following scripts:

#### Does your front matter exist?

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

#### Are your image paths valid?

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
            echo "🚨 Warning: perceived image not found: $img (line $line_number in $file)"
        fi
    done < <(grep -n -oP '!\[.*?\]\(\K.*?(?=\))' "$file")
done

echo "✅ Image path validation check complete."
```

#### Do you need to update/generate tag pages?

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

### Add some pre-push scripts

In `.lefthook/pre-push/`, add a file for the following script:

#### Does your blog build?

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

**Make sure your new scripts are executable with another `chmod +x`**

### Configuring lefthook to run your new scripts

Next, make sure `lefthook.yml` references your pre-commit/pre-push scripts

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

### Check your deployment method

This blog is built from the repo using github actions, this is the definition that's working for me. **MAKE SURE** that your pages settings for the repository are correct. You want to be deploying from a branch called `gh-pages`, make it if you don't have one. I'm using `/ (root)` as my folder because it seemed right at the beginning when I didn't know what I was doing.

- **TURNS OUT**, the theme I'm using assumes a `docs/` directory, so I needed to go back and rework my config to use a remote-theme. You live, you fuck up a lot, sometimes you learn.
- Make sure you have a deploy file at `.github/workflows/deploy.yml` to tell github actions that we need to execute jekyll on the repo contents, and serve the output

```yml
name: "Build and Deploy Jekyll"

on:
  push:
    branches: ["main"]

jobs:
  build-deploy:
    runs-on: "ubuntu-latest"
    steps:
      - uses: "actions/checkout@v3"

      - name: "Setup Ruby"
        uses: "ruby/setup-ruby@v1"
        with:
          ruby-version: "3.1"

      - name: "Install dependencies"
        run: |
          gem install bundler
          bundle install

      - name: "Build site"
        run: "bundle exec jekyll build -d _site"

      - name: "Deploy to GitHub Pages"
        uses: "peaceiris/actions-gh-pages@v3"
        with:
          github_token: "${{ secrets.GITHUB_TOKEN }}"
          publish_dir: "./_site"
          force_orphan: true
          keep_files: false
```

## Setup Conclusion

By now, hopefully you're seeing fun outputs whenever you make new commits to the repo. Make sure to check your `git status` before pushing, you might need to commit newly auto-generated content.

- **Important:** I might've missed some steps. I spent 12 hours off and on fighting Jekyll to get a successful deployment, I did my best to capture what is relevant in this post.
  - **Want things to go faster?** Spend the time to [read the docs](https://jekyllrb.com/docs/), go through the step-by-step. Use that knowledge to craft your prompts.
- I've edited this post a few times to fix minor things: clarify some language, add links, fix broken formatting. Everything described here is mirrored in the repository, I'm just walking you through my process and justifying the decisions made. Take what you like, send me some feedback if you think I'm egregiously messing things up or otherwise could be doing things easier.
- **Big edit from the future:** most of the content from this post has been condensed into the repo's `CONTRIBUTING.md` file. You should probably start there.
