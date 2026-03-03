#!/bin/bash
# PreToolUse hook: prevent accidental edits to test reference images
# Reference images should only be updated via `just test-update`

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Block edits to test reference images
if [ -n "$FILE_PATH" ] && echo "$FILE_PATH" | grep -q 'tests/.*/ref/'; then
  echo "Blocked: test reference images should not be edited directly. Use 'just test-update' to regenerate them." >&2
  exit 2
fi

exit 0
