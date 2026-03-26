# Hooks

Hooks are event-driven automations that fire before or after GitHub Copilot tool executions. They enforce code quality, catch mistakes early, and automate repetitive checks — without requiring manual intervention.

```
.github/hooks/
├── hooks.json          ← Hook configuration (registered in plugin.json)
├── README.md
└── scripts/
    ├── post-edit-format.sh      ← Auto-format JS/TS after edits
    ├── pre-push-reminder.sh     ← Review staged changes before push
    ├── pre-terminal-guard.sh    ← Warn on destructive shell commands
    ├── session-context.sh       ← Inject tech-stack context at session start
    └── typecheck.sh             ← Run tsc --noEmit after TS file edits
```

---

## How Hooks Work

```
User request → Copilot picks a tool → preToolCall hook runs → Tool executes → postToolCall hook runs
```

- **`preToolCall`** hooks run before the tool executes. They can warn (write to stderr) but do not block execution.
- **`postToolCall`** hooks run after the tool completes. Used for analysis and automation.

All hooks are shell scripts that receive context via environment variables and exit with code `0` on success.

---

## Hook Configuration (`.github/hooks/hooks.json`)

```json
{
  "hooks": {
    "preToolCall": [
      { "matcher": "terminal",  "command": "bash \"${COPILOT_PLUGIN_ROOT}/.github/hooks/scripts/pre-terminal-guard.sh\"" },
      { "matcher": "github",    "command": "bash \"${COPILOT_PLUGIN_ROOT}/.github/hooks/scripts/pre-push-reminder.sh\"" }
    ],
    "postToolCall": [
      { "matcher": "editFiles", "command": "bash \"${COPILOT_PLUGIN_ROOT}/.github/hooks/scripts/post-edit-format.sh\"", "async": true, "timeout": 30 },
      { "matcher": "editFiles", "command": "bash \"${COPILOT_PLUGIN_ROOT}/.github/hooks/scripts/typecheck.sh\"",        "async": true, "timeout": 30 }
    ]
  }
}
```

The `async: true` flag means post-edit hooks run in the background without blocking the main Copilot response.

---

## Script Reference

### `pre-terminal-guard.sh`

| Field | Value |
|-------|-------|
| **Trigger** | `preToolCall` — `terminal` matcher |
| **Behavior** | Warns (non-blocking) |

Inspects the command Copilot is about to run in the terminal. If it matches any pattern in the destructive commands list, it prints a warning message before execution.

**Destructive patterns detected:**

| Pattern | Risk |
|---------|------|
| `rm -rf`, `rm -fr` | Recursive file deletion |
| `git push --force`, `git push -f` | Force push overwrites remote history |
| `git reset --hard` | Discards uncommitted changes permanently |
| `git clean -fd`, `git clean -f` | Removes untracked files |
| `chmod -R 777` | Insecure permission grant |
| `dd if=` | Low-level disk write |
| `> /dev/` | Direct device write |
| `mkfs`, `fdisk` | Disk formatting |
| `DROP TABLE`, `DROP DATABASE`, `truncate` | Destructive database operations |

**Output example:**
```
⚠️  WARNING: Potentially destructive command detected: 'rm -rf'
   Command: rm -rf ./dist
   Review carefully before proceeding.
```

---

### `pre-push-reminder.sh`

| Field | Value |
|-------|-------|
| **Trigger** | `preToolCall` — `github` matcher |
| **Behavior** | Informs (non-blocking) |

Before any GitHub tool call (e.g., creating a PR, pushing code), shows a summary of staged and unstaged changes so you can review what will be included.

**Output example:**
```
📋 Staged changes pending commit:
   ✔ src/components/Button.tsx
   ✔ src/hooks/useAuth.ts

📝 Unstaged changes not yet committed:
   ○ src/utils/helpers.ts

💡 Reminder: Review all changes before pushing to remote.
```

---

### `post-edit-format.sh`

| Field | Value |
|-------|-------|
| **Trigger** | `postToolCall` — `editFiles` matcher |
| **Behavior** | Auto-formats (async, non-blocking) |
| **Timeout** | 30 seconds |

After Copilot edits a file, automatically formats it with **Prettier** if the file is a JavaScript or TypeScript file. Falls back gracefully if Prettier is not installed.

**Supported extensions:** `.ts`, `.tsx`, `.js`, `.jsx`, `.mjs`, `.cjs`

**Prettier resolution order:**
1. Global `prettier` in `PATH`
2. Local `node_modules/.bin/prettier`
3. Skip silently if neither is available

---

### `typecheck.sh`

| Field | Value |
|-------|-------|
| **Trigger** | `postToolCall` — `editFiles` matcher |
| **Behavior** | Runs type check (async, non-blocking) |
| **Timeout** | 30 seconds |

After Copilot edits a `.ts` or `.tsx` file, runs `tsc --noEmit` to check for TypeScript compilation errors. Errors are surfaced as warnings in the Copilot output without blocking the session.

---

### `session-context.sh`

| Field | Value |
|-------|-------|
| **Trigger** | Not currently auto-wired (example lifecycle script) |
| **Behavior** | Injects project context when run manually or by a future session-start hook |

This script is not registered in `.github/hooks/hooks.json` and does **not** run automatically. It is provided as an example of a session-start script you can call manually (for example, from your shell or editor) or wire up yourself if your environment adds support for session-start lifecycle hooks.

When run, it detects and reports the project's technology stack so Copilot has accurate context from the first message.

**Detects:**
- **Package manager** — pnpm, yarn, or npm (via lockfile detection)
- **Framework** — Next.js or React (via `package.json` dependency check)
- **Language** — TypeScript (via `tsconfig.json` presence)

**Output example:**
```
=== Project Context ===
Package Manager: pnpm
Framework: Next.js
Language: TypeScript
=== End Context ===
```

---

## Writing Custom Hooks

### Basic Shell Hook Template

```bash
#!/usr/bin/env bash
set -euo pipefail

COMMAND="${COPILOT_TOOL_INPUT_COMMAND:-}"  # terminal hooks
FILE="${COPILOT_TOOL_INPUT_PATH:-}"        # editFiles hooks

# Warn (non-blocking): write to stderr
echo "⚠️  Warning message" >&2

exit 0  # Always exit 0 unless intentionally blocking
```

### Exit Codes

| Code | Meaning |
|------|---------|
| `0` | Success — continue normally |
| `2` | Block the tool call (`preToolCall` only) |
| Other non-zero | Error — logged but does not block |

### Environment Variables Available in Hooks

| Variable | Available In | Description |
|----------|-------------|-------------|
| `COPILOT_TOOL_INPUT_COMMAND` | terminal hooks | The shell command being run |
| `COPILOT_TOOL_INPUT_PATH` | editFiles hooks | Path of the file being edited |
| `COPILOT_PLUGIN_ROOT` | all hooks | Absolute path to the plugin root directory |
