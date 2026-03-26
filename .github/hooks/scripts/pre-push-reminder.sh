#!/usr/bin/env bash
# Pre-push hook: remind to review staged changes before pushing to remote
# Triggered before Copilot executes any github tool call

set -euo pipefail

# Check if inside a git repository
if ! git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
  exit 0
fi

# Show staged and unstaged changes summary
STAGED=$(git diff --cached --name-only 2>/dev/null)
UNSTAGED=$(git diff --name-only 2>/dev/null)

if [[ -n "$STAGED" ]]; then
  echo "📋 Staged changes pending commit:"
  echo "$STAGED" | sed 's/^/   ✔ /'
fi

if [[ -n "$UNSTAGED" ]]; then
  echo "📝 Unstaged changes not yet committed:"
  echo "$UNSTAGED" | sed 's/^/   ○ /'
fi

if [[ -n "$STAGED" || -n "$UNSTAGED" ]]; then
  echo ""
  echo "💡 Reminder: Review all changes before pushing to remote."
fi

exit 0
