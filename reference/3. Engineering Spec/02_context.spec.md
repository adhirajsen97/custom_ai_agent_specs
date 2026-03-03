# 02_context.spec.md — Task Context

last_verified: YYYY-MM-DD       # stamp with stamp-context.sh after verifying — MUST NOT remain as YYYY-MM-DD
verified_by: <your-name>        # MUST be replaced — angle-bracket values trigger escalation
conventions_version: "1.0.0"   # MUST match CONVENTIONS.md:conventions_version exactly
                                 # Mismatch → mandatory escalation per 00_policy

> ⚠️  STALENESS RULES (agent: enforce before writing code)
>
> 1. If last_verified is older than 14 days → re-verify all file paths, escalate stale ones
> 2. If a major refactor occurred after last_verified → re-verify entire context, escalate
> 3. If conventions_version does not match CONVENTIONS.md → escalate before writing code
> 4. If ANY field still contains TODO, YYYY-MM-DD, or <angle-bracket> → escalate per 00_policy
>
> ALL FOUR must be clear before proceeding with execution.

---

## Relevant Files

<!-- INSTRUCTIONS (delete this block before agent runs):
  Replace every TODO row with the actual files relevant to this task.
  The agent will halt if it detects TODO: path or TODO: role in this table.
  Only list files that are in scope — do not include out-of-scope files here.
-->

| File | Role | Key Functions / Exports | Blast Radius |
|------|------|-------------------------|--------------|
| `path/to/file.ts` | Role description | `functionName`, `ExportedType` | peripheral |
| `path/to/test.ts` | Unit tests | Test suite names | isolated |

---

## Current Behavior

<!-- INSTRUCTIONS (delete before agent runs):
  Be specific. Step-by-step, not high-level summaries.
  The agent uses this to understand what it must NOT break.
-->

- Describe what the code currently does (step-by-step, input → processing → output)
- Identify the specific gap or failure the task addresses
- Name the exact functions, paths, or conditions involved
- If the current behavior is a bug: describe the failure mode precisely

---

## Existing Patterns to Follow

<!-- INSTRUCTIONS (delete before agent runs):
  Point the agent at specific files/lines it should mirror.
  Vague guidance produces inconsistent code.
-->

- **Logger usage** — see `services/<example>.ts:L42` — use `logger.withContext({ event_id })`
- **Result<T,E> pattern** — see `services/<example>.ts:L18` — never throw, always return Result
- **Retry pattern** — see `services/emailSender.ts` — mirror exactly, max 3, exponential 100ms base
- **Test mocking style** — `jest.spyOn` only, no real IO, see `services/<example>.test.ts`
- **Error types** — see `lib/errors.ts` — use typed classes, never raw `new Error(...)`

---

## Known Pitfalls

<!-- INSTRUCTIONS (delete before agent runs):
  List every edge case, gotcha, or prior failure mode you know about.
  If none are known, write "None documented." — do not leave this blank.
-->

- Edge case 1 — e.g., provider retries same `event_id` within 30s — must be idempotent
- Edge case 2 — e.g., `user.address` is optional and may be `null` — guard before access
- Known missing functionality — e.g., no lookup by `external_ref` field yet — do not add it

---

## Test Isolation Notes

<!-- INSTRUCTIONS (delete before agent runs):
  Describe any known test interference issues, shared state, or ordering dependencies.
  If none: write "No known test isolation issues." — agent uses this to plan test execution order.
-->

- Any shared test fixtures across suites: list them
- Any tests that must run in sequence (and why): list them
- Any known flaky tests in adjacent suites: list them so agent does not re-run indefinitely

---

## Out-of-Scope Context (Do Not Touch)

<!-- INSTRUCTIONS (delete before agent runs):
  Explicitly list files the agent must not touch, even if they seem related.
  This prevents "helpful" refactoring outside scope.
-->

- `path/to/adjacent.ts` — related but not in scope for this task
- `path/to/other.ts` — owned by another team, do not modify
- `db/migrations/` — no schema changes unless explicitly approved in 01_task.spec.yaml
