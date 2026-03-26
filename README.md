# copilot-ts-react-plugin

A **GitHub Copilot plugin** that enhances Copilot for React TypeScript development. It adds specialized agents, contextual skills, automated hooks, and persistent coding instructions — all wired together through a single plugin manifest.

All components live inside `.github/` so the plugin works in two modes without any reconfiguration:
- **Plugin mode** — reference this repository as a Copilot plugin
- **Copy mode** — paste the `.github/` folder into any project and everything activates automatically

---

## What's Inside

| Component | Count | What it does |
|-----------|-------|-------------|
| [Agents](docs/agents.md) | 7 | Specialized AI personas (architect, TDD guide, security reviewer, etc.) |
| [Skills](docs/skills.md) | 4 | Context-aware knowledge modules (frontend patterns, TDD workflow, security) |
| [Hooks](docs/hooks.md) | 5 scripts | Automated pre/post tool-call actions (format, typecheck, safety guards) |
| [Instructions](docs/instructions.md) | 14 files | Always-on rules for coding style, security, testing, git workflow |
| MCP | 4 servers | filesystem, memory, sequential-thinking, context7 |

---

## Installation

### Option A — Plugin (recommended)

Reference this repository as a Copilot plugin in your Copilot configuration:

```json
{
  "plugins": [
    "https://github.com/your-org/copilot-ts-react-plugin"
  ]
}
```

Copilot loads `plugin.json` and activates all components automatically.

### Option B — Copy to project

Copy the `.github/` folder from this repo into your project's root:

```
your-project/
└── .github/           ← copy the entire .github/ folder here
    ├── agents/
    ├── hooks/
    ├── instructions/
    ├── skills/
    ├── .mcp.json
    └── plugin/
        └── plugin.json
```

All features activate automatically — agents, skills, instructions, hooks, and MCP servers are discovered from the `.github/` folder. No additional configuration needed.

> **Note:** In copy mode, if Copilot does not auto-load MCP via `plugin.json`, also copy `.github/.mcp.json` to your project root as `.mcp.json`.

---

## How It Works

Once loaded, the plugin activates automatically:
- **Instructions** are injected into every conversation (via `plugin.json` + auto-discovery of `*.instructions.md`)
- **Agents** activate based on task context (or invoke by name)
- **Skills** activate when trigger phrases appear in your prompt
- **Hooks** run silently in the background on every file edit or terminal command
- **MCP servers** extend tool access with memory, filesystem, reasoning, and live docs

---

## Agents

Seven specialized agents covering the full development lifecycle:

| Agent | Role | Model |
|-------|------|-------|
| [`architect`](docs/agents.md#architect) | System design & technical decisions | gpt-4o |
| [`planner`](docs/agents.md#planner) | Feature planning & implementation steps | gpt-4o |
| [`tdd-guide`](docs/agents.md#tdd-guide) | Test-driven development, 80%+ coverage | gpt-4o |
| [`code-reviewer`](docs/agents.md#code-reviewer) | Code quality, security, maintainability | gpt-4o |
| [`security-reviewer`](docs/agents.md#security-reviewer) | OWASP Top 10, secrets, injection, auth | gpt-4o |
| [`refactor-cleaner`](docs/agents.md#refactor-cleaner) | Dead code removal, deduplication | gpt-4o |
| [`doc-updater`](docs/agents.md#doc-updater) | Documentation & codemap generation | gpt-4o-mini |

→ [Full agents documentation](docs/agents.md)

---

## Skills

Four knowledge modules that activate automatically on matching prompts:

| Skill | Triggers On |
|-------|-------------|
| [`frontend-patterns`](docs/skills.md#frontend-patterns) | `react component`, `state management`, `custom hook`, `form validation` |
| [`security-review`](docs/skills.md#security-review) | Auth, user input, API endpoints, secrets, payments |
| [`security-scan`](docs/skills.md#security-scan) | Plugin/config auditing with AgentShield |
| [`tdd-workflow`](docs/skills.md#tdd-workflow) | New features, bug fixes, refactoring |

→ [Full skills documentation](docs/skills.md)

---

## Hooks

Five shell scripts that automate quality checks:

| Script | When | What it does |
|--------|------|-------------|
| `pre-terminal-guard.sh` | Before terminal command | Warns on destructive commands (`rm -rf`, force push, etc.) |
| `pre-push-reminder.sh` | Before GitHub tool call | Shows staged/unstaged diff summary |
| `post-edit-format.sh` | After file edit | Auto-formats with Prettier (async) |
| `typecheck.sh` | After `.ts`/`.tsx` edit | Runs `tsc --noEmit` (async) |
| `session-context.sh` | Manual (run at session start) | Detects and injects tech stack context |

→ [Full hooks documentation](docs/hooks.md)

---

## Instructions

Fourteen instruction files defining persistent rules across two scopes:

**Common** (all files): coding style, security checklist, testing requirements, git workflow, development workflow, agent orchestration, hooks system, patterns, performance.

**TypeScript** (`.ts`, `.tsx`, `.js`, `.jsx`): extends all common rules with TS-specific types, strict null checks, Zod validation, Playwright E2E, and secure environment variable handling.

All files use the `.instructions.md` extension for automatic Copilot discovery.

→ [Full instructions documentation](docs/instructions.md)

---

## Repository Structure

```
copilot-ts-react-plugin/
├── .github/
│   ├── plugin/
│   │   └── plugin.json          ← Plugin manifest (registers all components)
│   ├── agents/                  ← 7 agent definitions
│   ├── skills/                  ← 4 skill modules
│   ├── hooks/                   ← Hook config + 5 scripts
│   ├── instructions/
│   │   ├── common/              ← 9 universal instruction files (*.instructions.md)
│   │   └── typescript/          ← 5 TypeScript-specific instruction files (*.instructions.md)
│   └── .mcp.json                ← MCP server configuration
└── docs/                        ← Documentation (not copied to projects)
    ├── agents.md
    ├── architecture.md
    ├── hooks.md
    ├── instructions.md
    └── skills.md
```

→ [Full architecture documentation](docs/architecture.md)

---

## Development Workflow

This plugin enforces the following workflow for all changes:

```
Research → Plan → TDD → Implement → Code Review → Security Review → Commit
```

1. **Research** — search GitHub and npm before writing new code
2. **Plan** — use the `planner` agent for non-trivial tasks
3. **TDD** — write failing tests first with the `tdd-guide` agent
4. **Implement** — write code to pass the tests
5. **Review** — run `code-reviewer` and `security-reviewer` agents
6. **Commit** — follow conventional commit format

---

## Documentation

| Document | Description |
|----------|-------------|
| [docs/architecture.md](docs/architecture.md) | Plugin structure, dual-mode operation, data flow |
| [docs/agents.md](docs/agents.md) | All 7 agents — purpose, tools, activation, outputs |
| [docs/skills.md](docs/skills.md) | All 4 skills — triggers, checklists, patterns |
| [docs/hooks.md](docs/hooks.md) | All hooks — scripts, exit codes, custom hook guide |
| [docs/instructions.md](docs/instructions.md) | All 14 instruction files — rules, requirements, patterns |
