# Architecture

This document describes the overall structure of the `copilot-ts-react-plugin` and how its components interact.

---

## Overview

The plugin is a **GitHub Copilot extension** that enhances Copilot's behavior when working on React TypeScript projects. It is composed of four integrated layers:

```
┌─────────────────────────────────────────────────────────┐
│                   GitHub Copilot Chat                    │
└────────────────────────┬────────────────────────────────┘
                         │ plugin.json registers all components
┌────────────────────────▼────────────────────────────────┐
│                 copilot-ts-react-plugin                  │
│                                                          │
│  ┌─────────────┐  ┌────────────┐  ┌──────────────────┐  │
│  │ Instructions│  │   Agents   │  │     Skills       │  │
│  │  (context)  │  │ (personas) │  │  (knowledge)     │  │
│  └─────────────┘  └────────────┘  └──────────────────┘  │
│                                                          │
│  ┌───────────────────────────────────────────────────┐  │
│  │                    Hooks                          │  │
│  │          (event-driven automations)               │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## Repository Structure

```
copilot-ts-react-plugin/
│
├── .github/
│   └── plugin/
│       └── plugin.json          ← Plugin manifest; registers all components
│
├── agents/                      ← 7 specialized AI agent personas
│   ├── architect.agent.md
│   ├── code-reviewer.agent.md
│   ├── doc-updater.agent.md
│   ├── planner.agent.md
│   ├── refactor-cleaner.agent.md
│   ├── security-reviewer.agent.md
│   └── tdd-guide.agent.md
│
├── skills/                      ← 4 reusable knowledge modules
│   ├── frontend-patterns/
│   │   └── SKILL.md
│   ├── security-review/
│   │   ├── SKILL.md
│   │   └── cloud-infrastructure-security.md
│   ├── security-scan/
│   │   └── SKILL.md
│   └── tdd-workflow/
│       └── SKILL.md
│
├── hooks/                       ← Event-driven automations
│   ├── hooks.json               ← Hook configuration
│   └── scripts/
│       ├── post-edit-format.sh
│       ├── pre-push-reminder.sh
│       ├── pre-terminal-guard.sh
│       ├── session-context.sh
│       └── typecheck.sh
│
├── instructions/                ← Persistent rules injected into all conversations
│   ├── common/                  ← Apply to all files (applyTo: "**")
│   │   ├── agents.md
│   │   ├── coding-style.md
│   │   ├── development-workflow.md
│   │   ├── git-workflow.md
│   │   ├── hooks.md
│   │   ├── patterns.md
│   │   ├── performance.md
│   │   ├── security.md
│   │   └── testing.md
│   └── typescript/              ← Apply to JS/TS files (applyTo: "**/*.{ts,tsx,js,jsx}")
│       ├── coding-style.md
│       ├── hooks.md
│       ├── patterns.md
│       ├── security.md
│       └── testing.md
│
├── docs/                        ← Plugin documentation (this folder)
│   ├── agents.md
│   ├── architecture.md
│   ├── hooks.md
│   ├── instructions.md
│   └── skills.md
│
├── .mcp.json                    ← MCP server configuration (filesystem, memory, sequential-thinking, context7)
├── .gitignore
└── README.md
```

---

## Component Layers

### Layer 1: Instructions (Always-On Context)

Instructions are the foundation. They are injected automatically into every Copilot conversation and define the baseline rules for coding style, security, testing, git workflow, and agent usage.

- **Common instructions** apply to all files and tasks
- **TypeScript instructions** apply only when working with `.ts`/`.tsx`/`.js`/`.jsx` files
- TypeScript instructions **extend** (not replace) common instructions

### Layer 2: Agents (Specialized Personas)

Agents are AI personas with a specific role, toolset, and model. They activate proactively based on the task context or can be invoked by name. Each agent has read-only or read-write access to different tools depending on its role.

**Tool access levels:**
| Agent | codebase | editFiles | terminal |
|-------|:--------:|:---------:|:--------:|
| architect | ✓ | — | — |
| planner | ✓ | — | — |
| code-reviewer | ✓ | — | ✓ |
| tdd-guide | ✓ | ✓ | ✓ |
| doc-updater | ✓ | ✓ | ✓ |
| refactor-cleaner | ✓ | ✓ | ✓ |
| security-reviewer | ✓ | ✓ | ✓ |

**Model selection:**
| Model | Agents |
|-------|--------|
| `gpt-4o` | architect, planner, code-reviewer, tdd-guide, refactor-cleaner, security-reviewer |
| `gpt-4o-mini` | doc-updater (lightweight, frequent invocation) |

### Layer 3: Skills (Contextual Knowledge)

Skills are activated automatically when trigger phrases appear in the conversation. They inject structured guidance, checklists, and patterns for a specific domain without replacing the active agent.

Skills are **additive** — they layer guidance on top of whatever agent is active.

### Layer 4: Hooks (Automation)

Hooks run shell scripts at specific tool-execution lifecycle events. They are the automation layer — running independent of conversations to enforce consistency (formatting, type checking, safety warnings).

**Hook execution flow:**
```
Copilot invokes tool
       ↓
preToolCall hooks fire (can warn)
       ↓
Tool executes
       ↓
postToolCall hooks fire (async, non-blocking)
```

---

## Plugin Manifest (`plugin.json`)

All components are registered in `.github/plugin/plugin.json`. This is the single source of truth for what Copilot loads.

```json
{
  "name": "copilot-ts-react-plugin",
  "version": "1.0.0",
  "components": {
    "instructions": [ "...all instruction files..." ],
    "agents":       [ "...all agent files..." ],
    "skills":       [ "...all skill files..." ],
    "hooks":        "hooks/hooks.json"
  }
}
```

---

## Data Flow: A Typical Feature Request

```
User: "Add a login form with validation"
        │
        ▼
Instructions loaded (coding-style, security, testing, typescript/*)
        │
        ▼
Planner agent activated → Creates implementation plan
        │
        ▼
TDD-guide agent → Writes failing tests first
        │
        ▼
frontend-patterns skill activated (trigger: "form validation")
        │
        ▼
Implementation code written
        │
        ▼
post-edit-format.sh fires → Prettier formats the file
typecheck.sh fires        → tsc --noEmit validates types
        │
        ▼
code-reviewer agent → Reviews the full diff
        │
        ▼
security-reviewer agent → Checks input handling, auth
        │
        ▼
User commits → pre-push-reminder.sh shows staged diff
```

---

## MCP Configuration (`.mcp.json`)

The `.mcp.json` file configures Model Context Protocol servers used by the plugin. These servers extend Copilot's tool access with persistent memory, filesystem operations, structured reasoning, and live documentation lookup.

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem@2026.1.14", "."],
      "description": "Filesystem access for all agents — reads existing components before generating, writes new files, explores project structure"
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory@2026.1.26"],
      "description": "Persistent memory — stores React/TypeScript component patterns, naming conventions, and team decisions across sessions"
    },
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking@2025.12.18"],
      "description": "Chain-of-thought reasoning — used by planner and architect agents before writing code"
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@2.1.4"],
      "description": "Live documentation lookup — fetches up-to-date React, TypeScript, Vite, Next.js, and ecosystem library docs on demand"
    }
  }
}
```

> **Note:** Keep under 10 MCP servers enabled to preserve the context window. Change the `"."` in the filesystem server args to an absolute path if running Copilot from a different working directory.
