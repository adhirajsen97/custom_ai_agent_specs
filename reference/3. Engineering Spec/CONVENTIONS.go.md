# CONVENTIONS.go.md
# ─────────────────────────────────────────────────────────────
# Go ecosystem conventions. Use this file when `stack: go`
# is declared in `01_task.spec.yaml` or passed to `new-task.sh --stack go`.
#
# STALENESS CONTROL — same rules as CONVENTIONS.md:
#   conventions_version must match 02_context.spec.md
#   Bump on any change. Mismatch → escalate.
# ─────────────────────────────────────────────────────────────
conventions_version: "1.0.0"   # bump on ANY change (semver)
last_updated: YYYY-MM-DD        # update whenever this file changes
verified_by: <your-name>

> Agents: if conventions_version does not match 02_context.spec.md's
> declared conventions_version, STOP and escalate before writing any code.

---

## Language & Toolchain

- Language: Go 1.22+ (modules required)
- Formatter: `gofmt` / `goimports` (non-negotiable — standard Go formatting)
- Linter: `golangci-lint` (config in `.golangci.yml` — do not disable linters inline)
- Test framework: stdlib `testing` package + `testify` for assertions (if in go.mod)
- Dependency management: Go modules (`go.mod` / `go.sum`)

> **Per-repo overrides:** If the repo uses different tooling, declare
> `toolchain_overrides` in `01_task.spec.yaml` with the actual commands.

---

## Architecture Patterns

### Error handling
- Always return `error` as the last return value — never panic in library code
- Use sentinel errors (`var ErrNotFound = errors.New(...)`) for expected failures
- Use `fmt.Errorf("context: %w", err)` for wrapping — preserve error chain
- Never ignore returned errors — handle or explicitly assign to `_` with comment

### Logging
- Use the project's established logger (e.g., `slog`, `zerolog`, `zap`)
- Never use `fmt.Println` or `log.Println` for application logging
- Use structured logging with key-value pairs
- Never log sensitive values: passwords, tokens, PII
- Log at the start and end of every service operation

### Service layer
- Service functions return `(T, error)` tuples
- Never return bare `nil` where caller expects data — return zero value + error
- Use context.Context as the first parameter for cancellation/timeout support

### Retry logic
- Use a retry helper or `backoff` library
- Max retries: 3
- Backoff: exponential starting at 100ms
- Only retry on transient errors — check error type before retry

### DB access
- All DB calls go through a repository layer
- Never write raw SQL in handlers — use repository functions
- Repository functions return `(T, error)` tuples
- Use `sqlx` or project ORM — match existing patterns

---

## Naming Conventions

| Construct | Convention | Example |
|---|---|---|
| Files | snake_case.go | webhook_processor.go |
| Packages | lowercase, no underscores | webhookprocessor |
| Exported types | PascalCase | WebhookProcessor |
| Unexported types | camelCase | webhookConfig |
| Functions (exported) | PascalCase | ProcessWebhook |
| Functions (unexported) | camelCase | validateInput |
| Constants | PascalCase or UPPER_SNAKE | MaxRetryCount |
| Interfaces | PascalCase, -er suffix for single-method | Processor, Reader |
| Test files | `<subject>_test.go` | webhook_processor_test.go |
| Error variables | `Err` prefix | ErrNotFound |

---

## Test Conventions

- All unit tests: mock external dependencies using interfaces + test doubles
- No real DB, network, or filesystem calls in unit tests
- Test names: `Test<Function>_<Scenario>_<Expected>` or table-driven tests
  - OK: `TestProcessWebhook_DuplicateEventID_ReturnsExisting`
  - Bad: `TestIt` or `Test1`
- Use table-driven tests for multiple input/output scenarios
- Minimum required tests per new function:
  - Happy path
  - At least one failure path
  - Edge case (empty input, nil field, boundary value)
- Do not delete or skip existing tests to make a suite pass
- Coverage: run with `go test -coverprofile` — do not lower thresholds

### Test isolation requirements
- Each test must be independently runnable
- No shared mutable state across test functions
- Use `t.Cleanup()` for teardown, not `defer` in test helpers
- Use `t.Parallel()` where safe for faster execution

---

## Comments Policy

- Add comments only where logic is non-obvious
- All exported symbols must have godoc comments (`// FunctionName does X`)
- Do not leave TODO comments in final output — track in handoff instead
- No commented-out code blocks in final output

---

## What Agents Must Not Do

- Do not introduce new patterns not listed here
- Do not add `//nolint` comments without a documented reason in handoff
- Do not change linter config as part of a task
- Do not add `fmt.Println` debugging — use logger or remove before handoff
- Do not change `go.mod` Go version without explicit approval
- Do not lower coverage thresholds
