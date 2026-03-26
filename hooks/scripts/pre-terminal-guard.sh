#!/usr/bin/env bash
# Pre-terminal hook: warn before potentially destructive shell commands
# Triggered before Copilot executes any terminal tool call

set -euo pipefail

COMMAND="${COPILOT_TOOL_INPUT_COMMAND:-}"

if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# Patterns considered destructive
DESTRUCTIVE_PATTERNS=(
  "rm -rf"
  "rm -fr"
  "git push --force"
  "git push -f"
  "git reset --hard"
  "git clean -fd"
  "git clean -f"
  "chmod -R 777"
  "dd if="
  "> /dev/"
  "mkfs"
  "fdisk"
  "DROP TABLE"
  "DROP DATABASE"
  "truncate"
)

for pattern in "${DESTRUCTIVE_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qi "$pattern"; then
    echo "⚠️  WARNING: Potentially destructive command detected: '$pattern'"
    echo "   Command: $COMMAND"
    echo "   Review carefully before proceeding."
    break
  fi
done

exit 0
