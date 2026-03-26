# Agents

This plugin ships **7 specialized agents** that GitHub Copilot can invoke automatically or on demand. All agents are defined in the `agents/` directory and registered in `.github/plugin/plugin.json`.

---

## How Agents Work

Agents are Markdown files with YAML frontmatter that define a custom AI persona with a specific role, toolset, and model. Copilot selects agents automatically based on task context, or you can invoke them explicitly by name.

```
agents/
├── architect.agent.md
├── code-reviewer.agent.md
├── doc-updater.agent.md
├── planner.agent.md
├── refactor-cleaner.agent.md
├── security-reviewer.agent.md
└── tdd-guide.agent.md
```

---

## Agent Reference

### `architect`

| Field | Value |
|-------|-------|
| **File** | `agents/architect.agent.md` |
| **Model** | `gpt-4o` |
| **Tools** | `codebase` |
| **Activation** | Proactive — planning new features, refactoring large systems, or making architectural decisions |

**Purpose:** Software architecture specialist for system design, scalability, and technical decision-making.

**Responsibilities:**
- Design system architecture for new features
- Evaluate technical trade-offs between approaches
- Recommend patterns and best practices (feature-based folder structure, module federation, etc.)
- Identify scalability bottlenecks and plan for future growth
- Ensure architectural consistency across the codebase

**Key Outputs:** Architecture decision records, component diagrams (text-based), scalability recommendations, folder structure guidance.

---

### `code-reviewer`

| Field | Value |
|-------|-------|
| **File** | `agents/code-reviewer.agent.md` |
| **Model** | `gpt-4o` |
| **Tools** | `codebase`, `terminal` |
| **Activation** | Proactive — immediately after writing or modifying any code. **MUST BE USED for all code changes.** |

**Purpose:** Expert code review specialist ensuring quality, security, and maintainability.

**Review Process:**
1. Runs `git diff --staged` and `git diff` to gather all changes
2. Reads full files — never reviews changes in isolation
3. Applies a confidence-based checklist (only reports issues with >80% certainty)
4. Reports findings from CRITICAL → LOW severity

**Review Checklist covers:** Correctness, security vulnerabilities, performance, readability, maintainability, test coverage, and TypeScript type safety.

---

### `doc-updater`

| Field | Value |
|-------|-------|
| **File** | `agents/doc-updater.agent.md` |
| **Model** | `gpt-4o-mini` |
| **Tools** | `codebase`, `editFiles`, `terminal` |
| **Activation** | Proactive — for updating codemaps, READMEs, and documentation guides |

**Purpose:** Documentation and codemap specialist that keeps documentation current with the actual codebase.

**Responsibilities:**
- Generate architectural codemaps to `docs/CODEMAPS/`
- Update READMEs and guides from code
- Perform AST analysis using the TypeScript compiler API
- Track import/export dependency graphs across modules
- Ensure docs accurately reflect the current state of code

---

### `planner`

| Field | Value |
|-------|-------|
| **File** | `agents/planner.agent.md` |
| **Model** | `gpt-4o` |
| **Tools** | `codebase` |
| **Activation** | Proactive — when implementing features, architectural changes, or complex refactoring |

**Purpose:** Expert planning specialist creating comprehensive, actionable implementation plans.

**Planning Process:**
1. **Requirements Analysis** — Clarifies scope, identifies unknowns
2. **Codebase Analysis** — Explores existing patterns and relevant code
3. **Research** — Uses GitHub code search and web research for prior art
4. **Plan Generation** — Produces step-by-step implementation plan with dependencies
5. **Risk Assessment** — Identifies potential blockers and edge cases

**Key Outputs:** Numbered implementation steps, dependency ordering, risk flags, test strategy outline.

---

### `refactor-cleaner`

| Field | Value |
|-------|-------|
| **File** | `agents/refactor-cleaner.agent.md` |
| **Model** | `gpt-4o` |
| **Tools** | `codebase`, `editFiles`, `terminal` |
| **Activation** | Proactive — for removing unused code, duplicates, and refactoring |

**Purpose:** Dead code cleanup and consolidation specialist.

**Detection Tools Used:** `knip`, `depcheck`, `ts-prune`

**Responsibilities:**
- Detect unused exports, variables, imports, and files
- Identify and consolidate duplicate logic
- Remove unused npm packages
- Safely refactor without breaking functionality
- Ensure all changes are verified by tests before removal

---

### `security-reviewer`

| Field | Value |
|-------|-------|
| **File** | `agents/security-reviewer.agent.md` |
| **Model** | `gpt-4o` |
| **Tools** | `codebase`, `editFiles`, `terminal` |
| **Activation** | Proactive — after writing code handling user input, authentication, API endpoints, or sensitive data |

**Purpose:** Security vulnerability detection and remediation specialist.

**Scans For:**
- OWASP Top 10 vulnerabilities
- Hardcoded secrets (API keys, passwords, tokens)
- SQL/NoSQL injection
- XSS and CSRF vulnerabilities
- Server-Side Request Forgery (SSRF)
- Unsafe cryptography
- Insecure dependencies (`npm audit`)
- Missing rate limiting and authentication checks

---

### `tdd-guide`

| Field | Value |
|-------|-------|
| **File** | `agents/tdd-guide.agent.md` |
| **Model** | `gpt-4o` |
| **Tools** | `codebase`, `editFiles`, `terminal` |
| **Activation** | Proactive — when writing new features, fixing bugs, or refactoring code |

**Purpose:** Test-Driven Development specialist enforcing write-tests-first methodology.

**TDD Cycle Enforced:**
1. **RED** — Write a failing test first
2. **GREEN** — Write minimum code to pass the test
3. **REFACTOR** — Clean up while keeping tests green

**Coverage Requirement:** Minimum **80%** test coverage across unit, integration, and E2E tests.

**Test Stack:** Vitest + React Testing Library (unit/integration), Playwright (E2E).

---

## Agent Selection Guide

| Task | Recommended Agent |
|------|-------------------|
| Planning a new feature | `planner` → `architect` |
| Writing new code | `tdd-guide` → `code-reviewer` |
| Fixing a bug | `tdd-guide` → `code-reviewer` |
| Handling auth / user input | `security-reviewer` |
| Removing dead code | `refactor-cleaner` |
| Updating docs/READMEs | `doc-updater` |
| Architectural decisions | `architect` |
