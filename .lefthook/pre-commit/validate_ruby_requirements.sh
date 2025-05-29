#!/bin/bash
# .lefthook/pre-commit/validate_ruby_requirements.sh

echo "🔍 Checking if Gemfile.lock is up to date with Gemfile..."
if ! bundle check > /dev/null 2>&1; then
  echo "❌ Gemfile.lock is not in sync with Gemfile. Run 'bundle install'."
  exit 1
else
  echo "✅ Gemfile.lock is up to date."
fi
