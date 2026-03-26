# Instructions

## Structure

Instructions are organized into a **common** layer plus **language-specific** directories:

```
instructions/
├── common/          # Language-agnostic principles (apply to all files)
│   ├── agents.md
│   ├── coding-style.md
│   ├── development-workflow.md
│   ├── git-workflow.md
│   ├── hooks.md
│   ├── patterns.md
│   ├── performance.md
│   ├── security.md
│   └── testing.md
└── typescript/      # TypeScript/JavaScript specific
    ├── coding-style.md
    ├── hooks.md
    ├── patterns.md
    ├── security.md
    └── testing.md
```

- **`common/`** contains universal principles with no language-specific code examples. Applied to all files via `applyTo: "**"`.
- **`typescript/`** extends the common rules with TypeScript/React-specific patterns, tools, and code examples. Applied only to JS/TS files via `applyTo: "**/*.{ts,tsx,js,jsx}"`.

## How Instructions Are Applied

Each instruction file contains YAML frontmatter with an `applyTo` glob pattern. GitHub Copilot injects matching instruction files into the conversation context automatically.

- `applyTo: "**"` — injected for every file/task
- `applyTo: "**/*.{ts,tsx,js,jsx}"` — injected only when working on JS/TS files

TypeScript instructions **extend** (not replace) common instructions. When language-specific and common rules conflict, language-specific rules take precedence.

## Instructions vs Skills

- **Instructions** define standards, conventions, and checklists that apply broadly (e.g., "80% test coverage", "no hardcoded secrets").
- **Skills** (`skills/` directory) provide deep, actionable reference material for specific tasks (e.g., `tdd-workflow`, `security-review`).

Language-specific instruction files reference relevant skills where appropriate. Instructions tell you *what* to do; skills tell you *how* to do it.

## Adding a New Language

To add support for a new language (e.g., `python/`):

1. Create an `instructions/python/` directory
2. Add files that extend the common instructions:
   - `coding-style.md` — formatting tools, idioms, error handling patterns
   - `testing.md` — test framework, coverage tools, test organization
   - `patterns.md` — language-specific design patterns
   - `hooks.md` — `postToolCall` hooks for formatters, linters, type checkers
   - `security.md` — secret management, security scanning tools
3. Each file should start with:
   ```
   > This file extends [common/xxx.md](../common/xxx.md) with <Language> specific content.
   ```
4. Register the new files in `.github/plugin/plugin.json` under `"instructions"`.
5. Reference existing skills if available, or create new ones under `skills/`.
