# Instructions

## Structure

Instructions are organized into a **common** layer plus **language-specific** directories.
All files use the `.instructions.md` extension so Copilot auto-discovers them.

```
.github/instructions/
├── common/                            # Language-agnostic principles (apply to all files)
│   ├── agents.instructions.md
│   ├── coding-style.instructions.md
│   ├── development-workflow.instructions.md
│   ├── git-workflow.instructions.md
│   ├── hooks.instructions.md
│   ├── patterns.instructions.md
│   ├── performance.instructions.md
│   ├── security.instructions.md
│   └── testing.instructions.md
└── typescript/                        # TypeScript/JavaScript specific
    ├── coding-style.instructions.md
    ├── hooks.instructions.md
    ├── patterns.instructions.md
    ├── security.instructions.md
    └── testing.instructions.md
```

- **`common/`** contains universal principles with no language-specific code examples. Applied to all files via `applyTo: "**"`.
- **`typescript/`** extends the common rules with TypeScript/React-specific patterns, tools, and code examples. Applied only to JS/TS files via `applyTo: "**/*.{ts,tsx,js,jsx}"`.

## How Instructions Are Applied

Each instruction file contains YAML frontmatter with an `applyTo` glob pattern. GitHub Copilot injects matching instruction files into the conversation context automatically.

- `applyTo: "**"` — injected for every file/task
- `applyTo: "**/*.{ts,tsx,js,jsx}"` — injected only when working on JS/TS files

TypeScript instructions **extend** (not replace) common instructions. When language-specific and common rules conflict, language-specific rules take precedence.

## Auto-Discovery

The `.instructions.md` extension enables two discovery mechanisms:

1. **Via `plugin.json`** — all files are explicitly listed under `components.instructions`; works in both plugin mode and copy-to-.github mode.
2. **Direct auto-discovery** — Copilot scans `.github/instructions/**/*.instructions.md` automatically when the files are present in the project.

## Instructions vs Skills

- **Instructions** define standards, conventions, and checklists that apply broadly (e.g., "80% test coverage", "no hardcoded secrets").
- **Skills** (`skills/` directory) provide deep, actionable reference material for specific tasks (e.g., `tdd-workflow`, `security-review`).

Language-specific instruction files reference relevant skills where appropriate. Instructions tell you *what* to do; skills tell you *how* to do it.

## Adding a New Language

To add support for a new language (e.g., `python/`):

1. Create a `.github/instructions/python/` directory
2. Add files that extend the common instructions — use `.instructions.md` extension:
   - `coding-style.instructions.md` — formatting tools, idioms, error handling patterns
   - `testing.instructions.md` — test framework, coverage tools, test organization
   - `patterns.instructions.md` — language-specific design patterns
   - `hooks.instructions.md` — `postToolCall` hooks for formatters, linters, type checkers
   - `security.instructions.md` — secret management, security scanning tools
3. Each file should start with:
   ```
   > This file extends [common/xxx.instructions.md](../common/xxx.instructions.md) with <Language> specific content.
   ```
4. Register the new files in `.github/plugin/plugin.json` under `"instructions"`.
5. Reference existing skills if available, or create new ones under `.github/skills/`.
