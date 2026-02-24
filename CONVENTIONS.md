# CONVENTIONS.md
# ─────────────────────────────────────────────────────────────
# STALENESS CONTROL
# conventions_version MUST be bumped on any change to this file.
# Any agent reading this file MUST:
#   1. Check conventions_version matches the value in 02_context.spec.md
#   2. If mismatch → escalate before writing code
#   3. If last_updated is YYYY-MM-DD (un-stamped) → treat as stale, escalate
#   4. If this file has no conventions_version field → treat as stale, escalate
#
# ENGINEER: When editing this file →
#   a) Bump conventions_version (semver: patch for clarifications,
#      minor for new rules, major for breaking changes to patterns)
#   b) Update last_updated to today's date
#   c) Update 02_context.spec.md:conventions_version to match
#   d) A git pre-commit hook (see hooks/check-conventions-version.sh)
#      will fail the commit if these are out of sync.
# ─────────────────────────────────────────────────────────────
conventions_version: "1.0.0"   # bump on ANY change (semver)
last_updated: YYYY-MM-DD        # update whenever this file changes
verified_by: <your-name>

> Agents: if conventions_version does not match 02_context.spec.md's
> declared conventions_version, STOP and escalate before writing any code.
> Do not assume conventions are current. Do not infer the correct version.

---

## Language & Toolchain

- Language: TypeScript (strict mode — `"strict": true` in tsconfig)
- Formatter: Prettier (config in `.prettierrc` — do not override inline)
- Linter: ESLint (config in `.eslintrc` — do not disable rules inline)
- Test framework: Jest (`jest.config.ts` — do not add new test runners)
- Node version: see `.nvmrc` — do not deviate

> **Per-repo overrides:** If the repo's `package.json` uses Vitest, Mocha, or another
> test runner instead of Jest, that repo's `01_task.spec.yaml` MUST declare
> `toolchain_overrides` listing the actual commands. The agent uses those commands.
> Do not assume Jest if the override is declared.

---

## Architecture Patterns

### Service layer returns
- Always use `Result<T, E>` from `lib/result.ts`
- Never `throw` from a service function — return `Result.err(...)` instead
- Never return raw `null` or `undefined` from a service — use `Result`

### Logging
- Always use `logger.withContext({ event_id, ... })` from `lib/logger.ts`
- Never use `console.log`, `console.error`, or `console.warn`
- Never log sensitive values: passwords, tokens, full card numbers, PII
- Log at the start and end of every service operation with status

### Error types
- Use typed error classes from `lib/errors.ts`
- Never use raw `new Error("string message")`
- Transient DB errors use `TRANSIENT_DB_ERROR` from `lib/errors.ts`
- Non-transient errors must not be retried — check error type before retry

### Retry logic
- Mirror the pattern in `services/emailSender.ts` exactly
- Max retries: 3
- Backoff: exponential starting at 100ms
- Only retry on errors typed as `TransientError` from `lib/errors.ts`

### DB access
- All DB calls go through the repo layer in `db/`
- Never write raw queries in services or handlers
- Repo functions return `Result<T, DbError>`

---

## Naming Conventions

| Construct | Convention | Example |
|---|---|---|
| Files | camelCase.ts | webhookProcessor.ts |
| Classes | PascalCase | WebhookProcessor |
| Functions & variables | camelCase | processWebhook |
| Constants | UPPER_SNAKE_CASE | MAX_RETRY_COUNT |
| Test files | `<subject>.test.ts` | webhookProcessor.test.ts |
| Error classes | PascalCase + Error suffix | TransientDbError |
| Result types | `Result<SuccessType, ErrorType>` | Result<Event, DbError> |

---

## Test Conventions

- All unit tests: mock every external dependency with `jest.spyOn`
- No real DB, network, or filesystem calls in unit tests — ever
- Test names: `"<function> — <scenario> — <expected outcome>"`
  - ✅ `"processWebhook — duplicate event_id — returns success without inserting"`
  - ❌ `"should work"` or `"test 1"`
- Minimum required tests per new function:
  - Happy path
  - At least one failure path
  - Edge case (empty input, null field, boundary value)
- Do not delete or comment out existing tests to make a suite pass
- Coverage threshold: enforced in `jest.config.ts` — do not lower it

### Test isolation requirements
- Each test file must be independently runnable in any order
- No shared mutable state across `describe` blocks unless wrapped in `beforeEach` reset
- If a test requires setup that modifies module-level state, use `jest.isolateModules()`
- Do not rely on test execution order for correctness

---

## Comments Policy

- Add comments only where logic is non-obvious
- Do not restate what the code already says
- Do not leave TODO comments in final output — track in handoff instead
- No commented-out code blocks in final output

---

## What Agents Must Not Do

- Do not introduce new patterns not listed here
- Do not add `eslint-disable` comments without a documented reason in handoff
- Do not change `.prettierrc` or `.eslintrc` as part of a task
- Do not add `@ts-ignore` or `@ts-expect-error` without explicit approval
- Do not change test framework configuration
- Do not lower coverage thresholds in `jest.config.ts`
- Do not add `console.log` debugging statements — use logger or remove before handoff

---

## Hooks (Setup Once Per Repo)

The following git hooks should be installed to enforce version sync automatically.
Run `hooks/install.sh` to set them up.

### `hooks/check-conventions-version.sh` (pre-commit)
Fails commit if `CONVENTIONS.md:conventions_version` does not match
`02_context.spec.md:conventions_version`. Prevents silent drift.

### `hooks/check-todo-fields.sh` (pre-push)
Scans `agent-specs/` for unresolved TODO markers, YYYY-MM-DD dates,
and angle-bracket placeholders. Fails push if any are found.
Prevents spec files with placeholder values from being pushed to shared branches.
