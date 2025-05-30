# Contributing Guide

Thank you for your interest in contributing to this project! This file is half for me, so I don't have to work as hard to rebuild the envionrment needed to write this blog, half for you, so you can know what dependencies I have on my system and send me the really great haxorinos.

This guide will help you set up your environment and understand the checks that run before each commit.

---

## 1. Clone the Repository

```bash
git clone https://github.com/yourusername/working-as-designed.github.io.git
cd working-as-designed.github.io
```

---

## 2. Python Environment

We use Python for some linting and spell-checking tools. This project requires Python 3.10+.

- **Install Python 3 (if not already installed).**
- **Create a virtual environment:**

```bash
pyenv install 3.10.12
pyenv local 3.10.12
python3 -m venv venv
source venv/bin/activate
```

- **Install Python dependencies:**

```bash
pip install -r requirements.txt
```

---

## 3. Ruby & Jekyll Setup

Jekyll and some hooks require Ruby.

- **Install Ruby (>= 2.7) and Bundler.**
- **Install project gems:**

```bash
bundle install
```

- **Build and serve the site locally:**

```bash
bundle exec jekyll serve
```

---

## 4. Node.js (Optional for now, for some linters)

Some Markdown/YAML linters require Node.js.

- **If you see errors about missing `npm` or `node`**, install Node.js from [nodejs.org](https://nodejs.org/).

```bash
# Download and install nvm:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# in lieu of restarting the shell
\. "$HOME/.nvm/nvm.sh"

# Download and install Node.js:
nvm install 22

# Verify the Node.js version:
node -v # Should print "v22.16.0".
nvm current # Should print "v22.16.0".

# Verify npm version:
npm -v # Should print "10.9.2".

# Update npm as needed. Check your terminal for messaging on this
```

- **Install `markdownlint` and other dependencies** (from the repo's package-lock.json)

```bash
npm ci
```

- **In case of emergency, install `markdownlint` locally:**

```bash
npm install --save-dev markdownlint-cli
```

---

## 5. Rust CLI Tools

Some pre-commit checks (like link checking) use Rust CLI tools.

- **Install Rust (if not already installed):**

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
```

- **Install Lychee (for link checking):**

```bash
cargo install lychee
```

---

## 6. Image tooling

Some pre-commit checks need deep image inspection / modification tooling. Maybe at some point in the future we can do cool shit like automagically write image properties for images we own, but for today, nuking metadata and resizing are good enough.

### EXIF Scrubbing

- **Install Rust (if not already installed):**

```bash
# Linux
apt install exiftool

# Or via Homebrew (macOS):
brew install exiftool
```

### Image Resizing

```bash
# Linux
apt install imagemagick

# Or via Homebrew (macOS):
brew install imagemagick
```

---

## 6. Pre-commit Hooks (Lefthook)

We use [Lefthook](https://github.com/evilmartians/lefthook) to run checks before each commit.

- **Install Lefthook:**

```bash
# On Linux:
curl -1sLf 'https://dl.cloudsmith.io/public/evilmartians/lefthook/setup.deb.sh' | sudo -E bash
sudo apt install lefthook

# Or via Homebrew (macOS):
brew install lefthook
```

---

## 7. What happens on Commit?

Before each commit, Lefthook will:

- Lint YAML files
- Check for broken Markdown links
- Spell-check posts
- Validate code fences in Markdown
- Ensure Python and Ruby dependencies are in sync
- (If present, lol it's not tho) Check Rust code builds and tests pass

If any check fails, the commit will be blocked until you fix the issue.

---

## 8. Troubleshooting

- **pip freeze output does not match requirements.txt:**
Run `pip freeze | sort > requirements.txt` and re-commit.

- **Gemfile.lock is not in sync:**
Run `bundle install` and re-commit.

- **Lychee not found:**
Make sure you installed it with `cargo install lychee` and that `$HOME/.cargo/bin` is in your `PATH`.

- **Yamllint or codespell not found:**
Install them with `pip install -r requirements.txt`.

---

## 9. Need Help?

If you get stuck, open an issue or ask for help in the repository discussions.

---

Happy contributing!
