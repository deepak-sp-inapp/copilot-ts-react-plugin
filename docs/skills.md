# Skills

Skills are reusable knowledge modules that Copilot activates when it detects matching context in your prompts. They provide structured guidance, patterns, and checklists for specific development workflows.

Skills are defined in the `skills/` directory as `SKILL.md` files and registered in `.github/plugin/plugin.json`.

```
skills/
├── frontend-patterns/
│   └── SKILL.md
├── security-review/
│   ├── SKILL.md
│   └── cloud-infrastructure-security.md
├── security-scan/
│   └── SKILL.md
└── tdd-workflow/
    └── SKILL.md
```

---

## How Skills Work

Each `SKILL.md` contains a YAML frontmatter block with:
- `name` — identifier for the skill
- `description` — when and why to use it
- `triggers` — phrases that auto-activate the skill
- `version` — version of the skill definition

When a trigger phrase appears in your conversation, Copilot automatically applies the skill's guidance.

---

## Skill Reference

### `frontend-patterns`

| Field | Value |
|-------|-------|
| **File** | `skills/frontend-patterns/SKILL.md` |
| **Version** | `1.0.0` |
| **Triggers** | `react component`, `state management`, `performance optimization`, `custom hook`, `form validation` |

**Purpose:** Provides modern frontend development patterns for React and TypeScript projects.

**Topics Covered:**

| Topic | Patterns |
|-------|----------|
| **Component Patterns** | Composition over inheritance, compound components, render props, controlled/uncontrolled |
| **State Management** | `useState`, `useReducer`, Zustand, Context API, server state with React Query/SWR |
| **Custom Hooks** | Extracting logic into reusable hooks, hook composition |
| **Performance** | `React.memo`, `useMemo`, `useCallback`, virtualization, code splitting, lazy loading |
| **Form Handling** | Controlled inputs, Zod schema validation, React Hook Form |
| **Data Fetching** | React Query, SWR, server components, optimistic updates |
| **Accessibility** | ARIA roles, keyboard navigation, focus management |

**When Activated:**
- Building React components
- Managing application state
- Optimizing rendering performance
- Implementing form validation
- Creating custom hooks

---

### `security-review`

| Field | Value |
|-------|-------|
| **File** | `skills/security-review/SKILL.md` |
| **Origin** | ECC |

**Purpose:** Comprehensive security checklist and patterns for secure coding. Activated when working with authentication, user input, API endpoints, secrets, or sensitive features.

**Checklist Areas:**

| Area | What It Checks |
|------|----------------|
| **Secrets Management** | No hardcoded API keys/passwords; environment variables used correctly |
| **Input Validation** | All user inputs sanitized and validated with Zod/Joi |
| **Authentication** | JWT handling, session security, token expiry |
| **Authorization** | Role-based access control, resource ownership checks |
| **API Security** | Rate limiting, CORS configuration, input/output sanitization |
| **SQL/NoSQL** | Parameterized queries, ORM usage, no string concatenation in queries |
| **XSS Prevention** | DOMPurify, Content Security Policy, safe rendering |
| **CSRF Protection** | SameSite cookies, CSRF tokens |
| **Dependency Security** | `npm audit`, known CVE checks |

**When Activated:**
- Implementing authentication or authorization
- Handling user input or file uploads
- Creating API endpoints
- Working with secrets or credentials
- Implementing payment features
- Storing or transmitting sensitive data

**Supporting File:** `skills/security-review/cloud-infrastructure-security.md` — extended guidance for cloud infrastructure security (IAM, network policies, secrets in CI/CD).

---

### `security-scan`

| Field | Value |
|-------|-------|
| **File** | `skills/security-scan/SKILL.md` |
| **Origin** | ECC |

**Purpose:** Audits the Copilot/Claude Code plugin configuration itself for security vulnerabilities, misconfigurations, and injection risks using **AgentShield**.

**What It Scans:**

| Target | Checks |
|--------|--------|
| `CLAUDE.md` / plugin instructions | Hardcoded secrets, auto-run instructions, prompt injection patterns |
| `settings.json` | Overly permissive allow lists, missing deny lists, dangerous bypass flags |
| `mcp.json` / `.mcp.json` | Risky MCP servers, hardcoded env secrets, `npx` supply chain risks |
| `hooks/` scripts | Command injection via interpolation, data exfiltration, silent error suppression |
| `agents/*.md` | Unrestricted tool access, prompt injection surface, missing model specs |

**When to Run:**
- Setting up a new project
- After modifying plugin configuration files
- Before committing configuration changes
- Periodic security hygiene

**Tool:** [AgentShield](https://github.com/affaan-m/agentshield) (`pip install insa-its`)

---

### `tdd-workflow`

| Field | Value |
|-------|-------|
| **File** | `skills/tdd-workflow/SKILL.md` |
| **Origin** | ECC |

**Purpose:** Enforces test-driven development with 80%+ coverage including unit, integration, and E2E tests.

**Core Principles:**
1. Tests are always written **before** implementation code
2. Minimum **80% coverage** (unit + integration + E2E combined)
3. All edge cases, error scenarios, and boundary conditions must be tested

**Test Types Required:**

| Type | Scope | Tools |
|------|-------|-------|
| **Unit** | Individual functions, utilities, React components | Vitest, React Testing Library |
| **Integration** | API endpoints, database operations, multi-component flows | Vitest, MSW (mock service worker) |
| **E2E** | Critical user journeys end-to-end | Playwright |

**TDD Cycle:**
```
Write failing test (RED) → Implement minimum code (GREEN) → Clean up (REFACTOR) → Repeat
```

**When Activated:**
- Writing new features or functionality
- Fixing bugs
- Refactoring existing code
- Adding API endpoints or React components
