#!/bin/bash
# Post-edit hook: verify Typst compilation after .typ file edits
# Runs after Edit/Write tool use on .typ files

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only check .typ files
if [ -z "$FILE_PATH" ] || ! echo "$FILE_PATH" | grep -q '\.typ$'; then
  exit 0
fi

# Run a quick compilation check on the entrypoint
if ! typst compile --root "$CLAUDE_PROJECT_DIR" "$CLAUDE_PROJECT_DIR/src/lib.typ" --output /dev/null 2>&1; then
  echo "Typst compilation failed after editing $FILE_PATH" >&2
  exit 0  # Don't block, just warn
fi

exit 0
