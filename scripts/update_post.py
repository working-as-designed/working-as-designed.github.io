#!/usr/bin/env python3
import sys
import re
from pathlib import Path
from datetime import date

def update_front_matter(lines, new_date):
    in_front_matter = False
    updated = False
    for i, line in enumerate(lines):
        if line.strip() == "---":
            if not in_front_matter:
                in_front_matter = True
            else:
                break
        elif in_front_matter and line.startswith("date:"):
            lines[i] = f"date: {new_date}\n"
            updated = True
            break
    return lines, updated

def update_paths(text, old_date, new_date):
    # Update /assets/YYYY-MM-DD/ and /images/YYYY-MM-DD/
    for prefix in ["/assets/", "/images/"]:
        pattern = re.compile(rf"({re.escape(prefix)}){old_date}(/)")
        text = pattern.sub(rf"\1{new_date}\2", text)
    return text

def main(post_path):
    repo_root = Path(__file__).parent.parent.resolve()
    post_path = (repo_root / post_path).resolve()
    if not post_path.exists():
        print(f"❌ File not found: {post_path}")
        sys.exit(1)

    # Extract old date from filename (expects YYYY-MM-DD-title.md)
    m = re.match(r"(\d{4}-\d{2}-\d{2})-(.+)", post_path.name)
    if not m:
        print("❌ Filename does not match expected pattern: YYYY-MM-DD-title.md")
        sys.exit(1)
    old_date, rest = m.groups()
    new_date = date.today().isoformat()

    # Read file
    lines = post_path.read_text(encoding="utf-8").splitlines(keepends=True)
    lines, updated = update_front_matter(lines, new_date)
    text = "".join(lines)
    text = update_paths(text, old_date, new_date)

    # Write updated content
    post_path.write_text(text, encoding="utf-8")
    print(f"✅ Updated front matter and asset/image paths to {new_date}")

    # Rename file if needed
    new_filename = f"{new_date}-{rest}"
    new_path = post_path.with_name(new_filename)
    if new_path != post_path:
        post_path.rename(new_path)
        print(f"✅ Renamed file to {new_path.name}")
    else:
        print("ℹ️ Filename already up to date.")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: touch_post.py <relative-path-to-post>")
        sys.exit(1)
    main(sys.argv[1])