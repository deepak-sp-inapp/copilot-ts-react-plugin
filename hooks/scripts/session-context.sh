#!/usr/bin/env bash
# Session context hook: inject tech stack context at the start of a session
# Provides Copilot with project-specific context

set -euo pipefail

PROJECT_ROOT="${PWD}"

# Detect tech stack and output context summary
echo "=== Project Context ==="

# Package manager detection
if [ -f "$PROJECT_ROOT/pnpm-lock.yaml" ]; then
  echo "Package Manager: pnpm"
elif [ -f "$PROJECT_ROOT/yarn.lock" ]; then
  echo "Package Manager: yarn"
elif [ -f "$PROJECT_ROOT/package-lock.json" ]; then
  echo "Package Manager: npm"
fi

# Framework detection from package.json
if [ -f "$PROJECT_ROOT/package.json" ]; then
  if grep -q '"next"' package.json 2>/dev/null; then
    echo "Framework: Next.js"
  elif grep -q '"react"' package.json 2>/dev/null; then
    echo "Framework: React"
  fi

  # TypeScript detection
if [ -f "$PROJECT_ROOT/tsconfig.json" ]; then
  echo "Language: TypeScript"
fi

echo "=== End Context ==="

exit 0
