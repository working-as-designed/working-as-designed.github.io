#!/bin/bash
# filepath: .lefthook/pre-commit/validate_python_requirements.sh

echo "🔍 Checking if pip freeze matches requirements.txt..."

# Generate a temp file for current pip freeze
tmpfile=$(mktemp)
pip freeze | sort > "$tmpfile"
sort requirements.txt > "${tmpfile}_req"

# Compare
if ! diff -q "$tmpfile" "${tmpfile}_req" > /dev/null; then
    echo "❌ pip freeze output does not match requirements.txt."
    echo "Run 'pip freeze | sort > requirements.txt' to update."
    exit 1
else
    echo "✅ pip freeze matches requirements.txt."
fi

# Clean up
rm "$tmpfile" "${tmpfile}_req"
