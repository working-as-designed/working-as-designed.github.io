#!/bin/bash
# filepath: .lefthook/pre-commit/code_fence_content_type.sh

echo "🔍 Checking for code fences without or with invalid content type..."

# Define allowed content types (add more as needed)
ALLOWED_TYPES="bash|sh|zsh|python|py|js|javascript|json|yaml|yml|html|css|scss|ruby|rb|go|c|cpp|java|php|sql|markdown|md|text|txt|toml|ini|makefile|dockerfile|powershell|ps1|xml|diff|shell|console|plaintext"

failed=0

for file in $(git diff --cached --name-only | grep '_posts/.*\.md$'); do
    in_code_block=false
    while IFS= read -r line; do
        lineno=$(echo "$line" | cut -d: -f1)
        content=$(echo "$line" | cut -d: -f2-)
        if [[ "$content" =~ ^[[:space:]]*\`\`\+ ]]; then
            # Fenced code block (opening or closing)
            if [ "$in_code_block" = false ]; then
                # Opening fence
                if [[ "$content" =~ ^[[:space:]]*\`\`\`$ ]]; then
                    # No language specified
                    echo "❌ $file:$lineno - Code fence without content type"
                    failed=1
                elif [[ "$content" =~ ^[[:space:]]*\`\`\`([[:alnum:]-_]+) ]]; then
                    type=$(echo "$content" | sed -E 's/^[[:space:]]*```([[:alnum:]-_]+).*/\1/')
                    if ! [[ "$type" =~ ^($ALLOWED_TYPES)$ ]]; then
                        echo "❌ $file:$lineno - Code fence with unknown content type: '$type'"
                        failed=1
                    fi
                fi
                in_code_block=true
            else
                # Closing fence, just toggle state
                in_code_block=false
            fi
        fi
    done < <(grep -n '^```' "$file")
done

if [ $failed -eq 1 ]; then
    echo "❌ Commit aborted: Please specify a valid language/content type for all code fences."
    exit 1
else
    echo "✅ All code fences specify a valid content type."
fi
