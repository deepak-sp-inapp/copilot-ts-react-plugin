#!/usr/bin/env bash
# Post-edit hook: run TypeScript type check after editing .ts/.tsx files
# Triggered after Copilot edits any file

set -euo pipefail

EDITED_FILE="${COPILOT_TOOL_INPUT_PATH:-}"

# Only run on TypeScript files
case "$EDITED_FILE" in
  *.ts|*.tsx)
    # Run tsc in noEmit mode from project root
    if [ -f "tsconfig.json" ]; then
      if command -v tsc &>/dev/null; then
        tsc --noEmit 2>&1 | head -20 || true
      elif [ -f "node_modules/.bin/tsc" ]; then
        node_modules/.bin/tsc --noEmit 2>&1 | head -20 || true
      fi
    fi
    ;;
esac

exit 0
