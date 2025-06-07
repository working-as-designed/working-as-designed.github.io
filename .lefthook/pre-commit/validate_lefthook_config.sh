#!/bin/bash
# filepath: .lefthook/pre-commit/validate_lefthook_config.sh

set -e

echo "🔎 Validating Lefthook config and scripts..."

LEFTHOOK_DIR=".lefthook"
LEFTHOOK_CONFIG="lefthook.yml"

# 1. Find all scripts in .lefthook (recursively, files only)
mapfile -t scripts < <(find "$LEFTHOOK_DIR" -type f -not -name "*.md" -not -name "*.txt" | sort)

if [ ! -f "$LEFTHOOK_CONFIG" ]; then
  echo "❌ Lefthook config file ($LEFTHOOK_CONFIG) not found."
  exit 1
fi

fail=0

# 2. Extract all run: script paths from lefthook.yml (handles YAML lists, quotes, and indentation)
run_paths=$(grep -E '^\s*run:' -A 1 "$LEFTHOOK_CONFIG" | grep -E '^\s*["'\'']?\.' | sed -E 's/^[^"]*["'\'']?([^"'\'' ]+)["'\'']?.*/\1/' | sort | uniq)

# 3. For each run_path, check if it exists and is executable
while read -r run_path; do
  [ -z "$run_path" ] && continue
  if [ ! -f "$run_path" ]; then
    echo "❌ Lefthook job references missing script: '$run_path'"
    fail=1
  elif [ ! -x "$run_path" ]; then
    echo "❌ Lefthook job references script without execute permissions: '$run_path'"
    fail=1
  fi
done <<< "$run_paths"

# 4. For each script, check if it is referenced by any run: key (warn only)
for script in "${scripts[@]}"; do
  script_rel="${script#./}"
  found=0
  while read -r run_path; do
    [ -z "$run_path" ] && continue
    if [ "$script_rel" = "$run_path" ]; then
      found=1
      break
    fi
  done <<< "$run_paths"
  if [ "$found" -eq 0 ]; then
    echo "⚠️  Script '$script_rel' is not referenced by any job in $LEFTHOOK_CONFIG."
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "✅ Lefthook config and scripts are valid."
  exit 0
else
  echo "❌ Lefthook config or script validation failed."
  exit 1
fi