---
applyTo: "**"
---
# Hooks System

## Copilot Hook Types

- **preToolCall**: Runs before a tool is executed. Use for validation and guardrails.
- **postToolCall**: Runs after a tool completes. Use for auto-formatting and quality checks.

## Available Hooks in This Plugin

| Hook | Trigger | Purpose |
|------|---------|---------|
| `pre-terminal-guard.sh` | `preToolCall: terminal` | Warns before destructive shell commands |
| `pre-push-reminder.sh` | `preToolCall: github` | Reminds to review before pushing |
| `post-edit-format.sh` | `postToolCall: editFiles` | Auto-formats TS/JS with Prettier |
| `typecheck.sh` | `postToolCall: editFiles` | Runs `tsc --noEmit` on TypeScript files |

## Hook Configuration

Hooks are defined in `hooks/hooks.json` relative to the plugin root.
Copilot passes `COPILOT_TOOL_INPUT_PATH` for file-targeting hooks.

## Best Practices

- Keep hook scripts fast (< 5 seconds for sync hooks)
- Use `async: true` for slow operations like type checking
- Always `exit 0` on non-critical warnings to avoid blocking Copilot
- Test scripts manually before enabling
