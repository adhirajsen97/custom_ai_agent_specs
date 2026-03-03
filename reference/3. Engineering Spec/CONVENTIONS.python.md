# CONVENTIONS.python.md
# ─────────────────────────────────────────────────────────────
# Python ecosystem conventions. Use this file when `stack: python`
# is declared in `01_task.spec.yaml` or passed to `new-task.sh --stack python`.
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

- Language: Python 3.11+ (type hints required on all public functions)
- Formatter: Black (config in `pyproject.toml` — do not override inline)
- Linter: Ruff (config in `pyproject.toml` or `ruff.toml` — do not disable rules inline)
- Type checker: mypy (`mypy.ini` or `pyproject.toml` — strict mode recommended)
- Test framework: pytest (`pyproject.toml` or `pytest.ini`)
- Dependency management: see `pyproject.toml` / `requirements.txt`

> **Per-repo overrides:** If the repo uses unittest, nose, or another test runner,
> declare `toolchain_overrides` in `01_task.spec.yaml` with the actual commands.

---

## Architecture Patterns

### Service layer returns
- Use explicit result types (e.g., `Result[T, E]` from `returns` library or custom)
- Alternatively, use typed exceptions with a base `ServiceError` class
- Never return bare `None` where a failure state is possible — use Optional with documentation or Result types
- Never use bare `except:` or `except Exception:` without re-raising or logging

### Logging
- Always use `logging.getLogger(__name__)` — never `print()`
- Use structured logging (e.g., `structlog` or stdlib with extra dict)
- Never log sensitive values: passwords, tokens, PII
- Log at the start and end of every service operation with status

### Error types
- Define custom exception classes inheriting from a base `ServiceError`
- Never raise bare `Exception("message")` — use typed exceptions
- Transient errors (DB, network) should be retryable and typed as such

### Retry logic
- Use `tenacity` library or custom retry decorator
- Max retries: 3
- Backoff: exponential starting at 0.1s
- Only retry on transient error types — never retry on validation errors

### DB access
- All DB calls go through a repository/DAO layer
- Never write raw SQL in services or handlers (use ORM or query builder)
- Repository functions return typed results

---

## Naming Conventions

| Construct | Convention | Example |
|---|---|---|
| Files | snake_case.py | webhook_processor.py |
| Classes | PascalCase | WebhookProcessor |
| Functions & variables | snake_case | process_webhook |
| Constants | UPPER_SNAKE_CASE | MAX_RETRY_COUNT |
| Test files | `test_<subject>.py` | test_webhook_processor.py |
| Exception classes | PascalCase + Error suffix | TransientDbError |
| Private members | `_leading_underscore` | _validate_input |

---

## Test Conventions

- All unit tests: mock every external dependency with `unittest.mock.patch` or `pytest-mock`
- No real DB, network, or filesystem calls in unit tests
- Test names: `test_<function>_<scenario>_<expected_outcome>`
  - OK: `test_process_webhook_duplicate_event_id_returns_existing`
  - Bad: `test_works` or `test_1`
- Minimum required tests per new function:
  - Happy path
  - At least one failure path
  - Edge case (empty input, None field, boundary value)
- Do not delete or skip existing tests to make a suite pass
- Coverage threshold: enforced in `pyproject.toml` — do not lower it

### Test isolation requirements
- Each test must be independently runnable in any order
- No shared mutable state across test classes unless wrapped in setup/teardown
- Use `pytest` fixtures with appropriate scope (function-level by default)

---

## Comments Policy

- Add comments only where logic is non-obvious
- Use docstrings on all public functions and classes (Google or NumPy style)
- Do not leave TODO comments in final output — track in handoff instead
- No commented-out code blocks in final output

---

## What Agents Must Not Do

- Do not introduce new patterns not listed here
- Do not add `# noqa` or `# type: ignore` without a documented reason in handoff
- Do not change Black/Ruff/mypy config as part of a task
- Do not change test framework configuration
- Do not lower coverage thresholds
- Do not add `print()` debugging statements — use logger or remove before handoff
