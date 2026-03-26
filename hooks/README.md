# Hooks

Hooks are event-driven automations that fire before or after GitHub Copilot tool executions. They enforce code quality, catch mistakes early, and automate repetitive checks.

## How Hooks Work

```
User request → Copilot picks a tool → preToolCall hook runs → Tool executes → postToolCall hook runs
```

- **`preToolCall`** hooks run before the tool executes. They can warn (write to stderr) but do not block execution.
- **`postToolCall`** hooks run after the tool completes. Used for background analysis and automation.

All hooks are shell scripts that receive context via environment variables and exit with code `0` on success.

## Hooks in This Plugin

### `preToolCall` Hooks

| Hook | Matcher | What It Does | Behavior |
|------|---------|-------------|----------|
| **Terminal guard** | `terminal` | Warns before potentially destructive commands (`rm -rf`, force push, etc.) | Non-blocking warn |
| **Push reminder** | `github` | Shows staged/unstaged diff summary before any GitHub tool call | Non-blocking inform |

### `postToolCall` Hooks

| Hook | Matcher | What It Does | Mode |
|------|---------|-------------|------|
| **Prettier format** | `editFiles` | Auto-formats JS/TS files with Prettier after edits | `async`, 30s timeout |
| **TypeScript check** | `editFiles` | Runs `tsc --noEmit` after editing `.ts`/`.tsx` files | `async`, 30s timeout |

## Hook Configuration (`hooks/hooks.json`)

```json
{
  "hooks": {
    "preToolCall": [
      { "matcher": "terminal", "command": "pre-terminal-guard.sh" },
      { "matcher": "github",   "command": "pre-push-reminder.sh"  }
    ],
    "postToolCall": [
      { "matcher": "editFiles", "command": "post-edit-format.sh", "async": true, "timeout": 30 },
      { "matcher": "editFiles", "command": "typecheck.sh",        "async": true, "timeout": 30 }
    ]
  }
}
```

The `async: true` flag means post-edit hooks run in the background without blocking the Copilot response.

## Script Reference

### `pre-terminal-guard.sh`

Reads `COPILOT_TOOL_INPUT_COMMAND` and warns if it matches any destructive pattern:

| Pattern | Risk |
|---------|------|
| `rm -rf`, `rm -fr` | Recursive file deletion |
| `git push --force`, `git push -f` | Force push overwrites remote history |
| `git reset --hard` | Discards uncommitted changes |
| `git clean -fd`, `git clean -f` | Removes untracked files |
| `chmod -R 777` | Insecure permission grant |
| `dd if=` | Low-level disk write |
| `> /dev/` | Direct device write |
| `mkfs`, `fdisk` | Disk formatting |
| `DROP TABLE`, `DROP DATABASE`, `truncate` | Destructive database operations |

### `pre-push-reminder.sh`

Before any GitHub tool call, runs `git diff --cached --name-only` and `git diff --name-only` to show a summary of staged and unstaged changes, so you can review what will be pushed.

### `post-edit-format.sh`

After any file edit, runs `prettier --write` on the edited file if it is a JS/TS file (`.ts`, `.tsx`, `.js`, `.jsx`, `.mjs`, `.cjs`). Falls back gracefully if Prettier is not installed.

### `typecheck.sh`

After editing a `.ts` or `.tsx` file, runs `tsc --noEmit` from the project root (if `tsconfig.json` exists). Surfaces type errors as warnings without blocking the session.

### `session-context.sh`

**Not registered in `hooks.json` — does not run automatically.** This script is provided as a utility you can invoke manually at session start. It detects and prints the project's tech stack (package manager, framework, TypeScript) so you can share context with Copilot.

## Environment Variables Available in Hooks

| Variable | Available In | Description |
|----------|-------------|-------------|
| `COPILOT_TOOL_INPUT_COMMAND` | `terminal` hooks | The shell command being run |
| `COPILOT_TOOL_INPUT_PATH` | `editFiles` hooks | Path of the file being edited |
| `COPILOT_PLUGIN_ROOT` | all hooks | Absolute path to the plugin root directory |

## Writing Custom Hooks

### Basic Shell Hook Template

```bash
#!/usr/bin/env bash
set -euo pipefail

COMMAND="${COPILOT_TOOL_INPUT_COMMAND:-}"  # terminal hooks
FILE="${COPILOT_TOOL_INPUT_PATH:-}"        # editFiles hooks

# Warn (non-blocking): write to stderr
echo "⚠️  Warning message" >&2

exit 0  # Always exit 0 for non-blocking hooks
```

### Adding a Hook to `hooks.json`

```json
{
  "hooks": {
    "postToolCall": [
      {
        "matcher": "editFiles",
        "description": "Warn about console.log in edited files",
        "command": "bash \"${COPILOT_PLUGIN_ROOT}/hooks/scripts/my-hook.sh\"",
        "async": true,
        "timeout": 10
      }
    ]
  }
}
```

## Related

- [docs/hooks.md](../docs/hooks.md) — Full hook documentation with script reference and examples
- [instructions/common/hooks.md](../instructions/common/hooks.md) — Hook architecture guidelines for instructions
