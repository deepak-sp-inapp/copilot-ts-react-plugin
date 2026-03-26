# Instructions

Instructions are Markdown files that are automatically injected into every Copilot conversation as persistent context. They define the rules, standards, and workflows that Copilot must follow when working in a project.

Instructions are organized into two categories and registered in `.github/plugin/plugin.json`.

```
instructions/
├── common/             ← Apply to all file types (applyTo: "**")
│   ├── agents.md
│   ├── coding-style.md
│   ├── development-workflow.md
│   ├── git-workflow.md
│   ├── hooks.md
│   ├── patterns.md
│   ├── performance.md
│   ├── security.md
│   └── testing.md
└── typescript/         ← Apply to JS/TS files only (applyTo: "**/*.{ts,tsx,js,jsx}")
    ├── coding-style.md
    ├── hooks.md
    ├── patterns.md
    ├── security.md
    └── testing.md
```

---

## How Instructions Work

Each instruction file contains YAML frontmatter with an `applyTo` glob pattern:

- `applyTo: "**"` — injected for every file/task
- `applyTo: "**/*.{ts,tsx,js,jsx}"` — injected only when working on JS/TS files

TypeScript instructions extend their common counterparts and add language-specific details.

---

## Common Instructions

### `agents.md`

`applyTo: "**"`

Documents the available agents and their intended use cases. Provides Copilot with a quick reference table for agent selection:

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| `planner` | Implementation planning | Complex features, refactoring |
| `architect` | System design | Architectural decisions |
| `tdd-guide` | Test-driven development | New features, bug fixes |
| `code-reviewer` | Code review | After writing code |
| `security-reviewer` | Security analysis | Before commits |
| `refactor-cleaner` | Dead code cleanup | Code maintenance |
| `doc-updater` | Documentation | Updating docs |

Also covers multi-agent orchestration patterns — how to chain agents sequentially or run them in parallel for complex tasks.

---

### `coding-style.md`

`applyTo: "**"`

Defines universal coding style rules applied regardless of language.

**Core Rules:**

| Rule | Requirement |
|------|-------------|
| **Immutability** | CRITICAL — always create new objects, never mutate existing ones |
| **Pure Functions** | Prefer functions with no side effects; isolate side effects at boundaries |
| **Small Files** | High cohesion, low coupling; split files when they grow large |
| **Naming** | Descriptive names; avoid abbreviations; use domain language |
| **No Magic Numbers** | Extract constants with meaningful names |
| **Early Returns** | Reduce nesting with guard clauses |

---

### `development-workflow.md`

`applyTo: "**"`

Defines the full feature development pipeline from research to commit.

**Workflow Stages:**

| Stage | Activity |
|-------|----------|
| **0. Research & Reuse** | GitHub code search, web research, check package registries before writing new code |
| **1. Plan First** | Use `planner` agent; generate PRD, architecture, system design, tech doc, and task list |
| **2. TDD** | Write tests first with `tdd-guide`; maintain 80%+ coverage |
| **3. Code Review** | Use `code-reviewer` agent after every change; address CRITICAL and HIGH issues |
| **4. Commit & Push** | Follow git-workflow.md conventions for commit messages and PR process |

**Key principle:** Always search for existing implementations (GitHub, npm) before writing new code.

---

### `git-workflow.md`

`applyTo: "**"`

Defines commit message format and pull request workflow.

**Commit Message Format:**
```
<type>: <description>

<optional body>

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

**Commit Types:** `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `ci`

**PR Workflow:**
- One feature/fix per branch
- PR title follows the same format as commit messages
- All PRs must pass CI checks before merge
- Squash merge preferred for feature branches

---

### `hooks.md`

`applyTo: "**"`

Documents the hooks system architecture and the hooks available in this plugin. Provides Copilot with awareness of when hooks fire and what they do, so it can interpret hook output correctly.

**Hook Types:**
- `preToolCall` — runs before a tool executes; can warn
- `postToolCall` — runs after a tool completes; used for automation

**Available hooks summary:** see [hooks.md](./hooks.md) for full details.

---

### `patterns.md`

`applyTo: "**"`

Defines reusable architectural and implementation patterns.

**Key Patterns:**

| Pattern | Description |
|---------|-------------|
| **Skeleton Projects** | Search for battle-tested templates before starting from scratch |
| **Parallel Agent Evaluation** | Use multiple agents simultaneously to evaluate options (security, extensibility, relevance) |
| **Feature-Based Structure** | Organize code by feature, not by file type |
| **Separation of Concerns** | UI, business logic, and data access in distinct layers |
| **Error Boundaries** | Isolate failures; every async operation needs error handling |

---

### `performance.md`

`applyTo: "**"`

Guides model selection and performance optimization strategies.

**Model Selection Strategy:**

| Model | Use Case |
|-------|----------|
| `gpt-4o-mini` | Lightweight agents, documentation generation, worker agents in multi-agent systems |
| `gpt-4o` | Main development work, orchestrating multi-agent workflows, complex reasoning |

**Code Performance Guidelines:**
- Prefer lazy loading and code splitting for large modules
- Use memoization (`useMemo`, `useCallback`) only when profiling confirms a bottleneck
- Prefer server-side rendering for initial page loads
- Virtualize large lists (react-window, TanStack Virtual)

---

### `security.md`

`applyTo: "**"`

Defines mandatory security checks that apply before every commit, regardless of language.

**Pre-Commit Security Checklist:**
- [ ] No hardcoded secrets (API keys, passwords, tokens)
- [ ] All user inputs validated and sanitized
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (sanitized HTML output)
- [ ] CSRF protection enabled
- [ ] Authentication and authorization verified
- [ ] Rate limiting on all public endpoints
- [ ] Dependency audit (`npm audit` or equivalent) passing

---

### `testing.md`

`applyTo: "**"`

Mandates test-driven development and defines minimum coverage requirements.

**Requirements:**
- Minimum **80% test coverage** across unit + integration + E2E
- All three test types are required for every feature
- Tests must be written **before** implementation (TDD)

**Test Types:**
| Type | What to Test |
|------|-------------|
| **Unit** | Individual functions, utilities, pure components |
| **Integration** | API endpoints, database operations, component interactions |
| **E2E** | Critical user flows from the browser perspective |

---

## TypeScript Instructions

TypeScript instructions extend the common instructions with language-specific rules. They apply only to `.ts`, `.tsx`, `.js`, and `.jsx` files.

---

### `typescript/coding-style.md`

Extends `common/coding-style.md`.

**TypeScript-Specific Rules:**

| Rule | Detail |
|------|--------|
| **Explicit types on public APIs** | All exported functions must have typed parameters and return types |
| **Infer local types** | Let TypeScript infer obvious local variable types (avoid redundant annotations) |
| **Prefer `type` over `interface`** | Use `type` for unions, intersections, and component props |
| **No `any`** | Use `unknown` and narrow with type guards instead |
| **Strict null checks** | Always handle `null`/`undefined` explicitly |
| **Readonly where applicable** | Use `Readonly<T>` and `as const` for immutable data |

---

### `typescript/hooks.md`

Extends `common/hooks.md`.

Adds TypeScript-specific hook configurations:
- **Prettier**: Auto-format JS/TS files after every edit
- **TypeScript check**: Run `tsc --noEmit` after editing `.ts`/`.tsx` files
- **`console.log` warning**: Warn when `console.log` appears in edited files

---

### `typescript/patterns.md`

Extends `common/patterns.md`.

**TypeScript-Specific Patterns:**

| Pattern | Detail |
|---------|--------|
| **API Response Type** | Standard `ApiResponse<T>` interface with `success`, `data`, `error`, `meta` |
| **Result Type** | `Result<T, E>` for explicit error handling without throwing |
| **Discriminated Unions** | Use for state machines and variant types |
| **Zod Schemas** | Runtime validation at API boundaries; infer TypeScript types from schemas |
| **Generic Utilities** | Reusable typed utilities over `any`-based helpers |

---

### `typescript/security.md`

Extends `common/security.md`.

**TypeScript-Specific Security Rules:**

| Rule | Detail |
|------|--------|
| **No hardcoded secrets** | Always use `process.env.VAR_NAME`; never inline strings |
| **Validate env vars at startup** | Use Zod to parse and validate all environment variables on app init |
| **Type-safe query builders** | Use Prisma, Drizzle, or Kysely — never raw string SQL |
| **Sanitize user input** | Use `DOMPurify` for HTML; `zod.parse()` for structured data |
| **Secure headers** | Set `Content-Security-Policy`, `X-Frame-Options`, `HSTS` |

---

### `typescript/testing.md`

Extends `common/testing.md`.

**TypeScript-Specific Testing:**

| Type | Tool |
|------|------|
| **Unit / Integration** | Vitest + React Testing Library |
| **E2E** | Playwright |
| **API Mocking** | MSW (Mock Service Worker) |
| **Type Testing** | `tsd` or `expect-type` for testing type definitions |

Includes the `e2e-runner` agent for Playwright E2E testing assistance.
