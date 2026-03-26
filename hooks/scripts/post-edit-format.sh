#!/usr/bin/env bash
# Post-edit hook: auto-format TypeScript/JavaScript files using Prettier
# Triggered after Copilot edits any file

set -euo pipefail

# Read the edited file path from stdin (Copilot passes tool context)
EDITED_FILE="${COPILOT_TOOL_INPUT_PATH:-}"

# Only run on JS/TS files
if [[ -z "$EDITED_FILE" ]]; then
  exit 0
fi

case "$EDITED_FILE" in
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs)
    # Use local Prettier if available, otherwise skip
    if command -v prettier &>/dev/null; then
      prettier --write "$EDITED_FILE" 2>/dev/null || true
    elif [ -f "node_modules/.bin/prettier" ]; then
      node_modules/.bin/prettier --write "$EDITED_FILE" 2>/dev/null || true
    fi
    ;;
esac

exit 0
