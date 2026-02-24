# 04_verify_and_handoff.spec.md — Verification & Handoff Protocol
# ─────────────────────────────────────────────────────────────
# This file defines exactly how the agent verifies work and delivers handoff.
# Read this BEFORE writing code. Knowing the exit criteria shapes implementation.
# ─────────────────────────────────────────────────────────────

## The Definition of Done

A task is complete when ALL of the following are true — not before:

1. A valid `APPROVED: <task_id>` token was received from the human before execution began
2. Every check in `03_execution.spec.yaml` has been run and passed
3. Actual command output (not a summary) is included in the handoff
4. Every acceptance criterion in `01_task.spec.yaml` is explicitly addressed
5. All 7 handoff sections are present and complete
6. No TODO comments exist in any file that was touched
7. No commented-out code exists in any file that was touched
8. The agent has not claimed "it should work" — only actual output counts

A response that says "all tests pass" without pasting the output is **not done**.

---

## Verification Procedure

### Step 1 — Run checks in order from `03_execution.spec.yaml`

For each check:
- Run the exact command specified. Do not substitute similar commands.
- Capture the **full output** — do not truncate unless instructed.
- Record: command run, timestamp, exit code, output summary.
- If exit code is non-zero: halt immediately. Output the full failure output.
  Do not attempt to fix silently. Do not re-run hoping it clears. Report and stop.

### Step 2 — Validate no unintended changes

Run the following and confirm only listed files were touched:

```bash
git diff --name-only
```

If any file appears that is NOT in `file_change_plan` → escalate before delivering handoff.
This is a scope violation regardless of whether the change seems benign.

### Step 3 — Verify test isolation

Run the full test suite (not just scoped tests) at least once before final handoff:

```bash
npm test
```

This catches regressions in adjacent tests caused by module-level changes.
If pre-existing tests fail that were passing before this task: document in handoff risks.
Do not fix pre-existing failures — that is out of scope.

### Step 4 — Final lint and type-check

```bash
npm run lint && npx tsc --noEmit
```

Both must exit 0. A type error in a file you didn't touch is still a blocker —
escalate with the error, do not suppress it.

---

## Handoff Format (Full Task)

Use this exact structure. Do not reorder sections. Do not skip sections.

---

### 1. Files Changed

List every file touched. Include action (modified / created / deleted).

```
Modified:  path/to/service.ts
Modified:  path/to/service.test.ts
Created:   path/to/newModule.ts
Created:   path/to/newModule.test.ts
```

---

### 2. What Changed

For each file: 1–3 bullets describing **behavioral and logic changes**.
Do not describe line numbers, variable names, or formatting changes.
Focus on: what the code now does that it didn't before (or no longer does).

```
path/to/service.ts
  - Now checks for duplicate event_id before inserting — returns existing record on match
  - Logs idempotency hits at INFO level with event_id in context

path/to/newModule.ts
  - New module: encapsulates retry logic — max 3 attempts, exponential backoff from 100ms
  - Only retries on TransientError — non-transient errors propagate immediately
```

---

### 3. Verification Results

For every check in `03_execution.spec.yaml`, paste:
- The exact command run
- The actual output (or a clearly marked truncated excerpt if over 50 lines)
- Pass / Fail

```
Command:  npm run lint
Output:   (paste actual output)
Result:   PASS — exit code 0, 0 errors, 0 warnings

Command:  npm test -- --testPathPattern=service
Output:   (paste actual output — test names, counts, duration)
Result:   PASS — 12 tests, 0 failures, 0 skipped

Command:  npx tsc --noEmit
Output:   (paste actual output)
Result:   PASS — exit code 0
```

---

### 4. Acceptance Criteria Check

For each criterion in `01_task.spec.yaml:acceptance_criteria`, state:
- Met / Partially met / Not met
- Evidence: the test(s) listed in `test_names` for that criterion must be present and passing
- If `test_names` lists specific tests, cite each by name with pass/fail status

```
✅ Met — "Duplicate event_id returns 200 with existing record"
   test_names: ["processWebhook — duplicate event_id — returns existing record"]
   Evidence: test PASS — matched declared test_names

✅ Met — "All new logic is covered by unit tests"
   test_names: ["coverage threshold check"]
   Evidence: coverage report shows 94% on service.ts (threshold: 90%)

⚠️ Partially met — "Logging on every code path"
   test_names: ["logs happy path", "logs error path", "logs timeout path"]
   Evidence: 2/3 tests pass — timeout path test not yet implemented, tracked in risks

❌ Not met — (explain why and what is blocked)
```

---

### 5. Risks / Follow-ups

Document every risk, edge case not covered, or out-of-scope issue found.
If none: write "No risks identified." — do not leave blank.

```
Risk: Timeout path in service.ts does not log — low severity, tracked as follow-up
Risk: Event ID collision window is ~30ms — acceptable per product decision, documented
Out-of-scope bug found: validator.ts line 42 has a null dereference on missing `user.address`
  → NOT fixed (out of scope), recommend T-YYYYMMDD-fix-validator as follow-up task
```

---

### 6. Assumptions

Explicit list of every assumption made during implementation.
If you assumed something was true that you could not verify: list it here.

```
- Assumed event_id is always a UUID string — no validation in spec, used as-is
- Assumed existing tests in service.test.ts were all passing before this task began
- Assumed emailSender.ts retry pattern is the canonical example per CONVENTIONS.md
```

---

### 7. Open Escalations

List any issues raised during the task that were escalated but not fully resolved.
If none: write "No open escalations."

```
Escalation raised: coverage threshold in jest.config.ts was already at 89% before task start
  (below the 90% required). Did not lower it. Threshold check passes with new tests added.
  Recommend a cleanup task to raise threshold back to 90% + buffer.
```

---

## Partial Handoff (Large Tasks — After Each Sub-task)

For large tasks, deliver a partial handoff after each sub-task using the template
defined in `03_execution.spec.yaml:subtasks[*].partial_handoff_template`.

Partial handoffs must include:
1. Sub-task ID and title
2. Files changed in this sub-task only
3. Verification output for this sub-task's checks
4. Whether the next sub-task is unblocked (yes/no + reason if no)
5. Any risks or assumptions specific to this sub-task

The final sub-task delivers the full 7-section handoff covering the entire task.
For sections completed in prior sessions, mark them:
`[completed in prior session — verified via <evidence>]`

---

## Execution Log (`execution_log.jsonl`)

An append-only log file (`agent-specs/execution_log.jsonl`) records structured events
throughout the task lifecycle. This log is the system's observability backbone — it
enables post-task analysis, process improvement, and audit.

### Log Format

Each line is a self-contained JSON object. Do not pretty-print — one object per line.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `event` | string | yes | Event type (see below) |
| `task_id` | string | yes | The task_id from `01_task.spec.yaml` |
| `timestamp` | string | yes | ISO 8601 UTC (e.g., `2026-02-24T14:30:00Z`) |
| `step_id` | string | no | Step or sub-task ID (e.g., `step-3`, `T-20260224-a`) |
| `action` | string | no | What was done (e.g., `run_check`, `write_file`) |
| `result` | string | no | Outcome (`pass`, `fail`, `skipped`, `escalated`) |
| `detail` | string | no | Additional context (error message, file path, etc.) |
| `duration_ms` | number | no | Elapsed time in milliseconds |

### Event Types

| Event | When to log |
|-------|-------------|
| `task_created` | `new-task.sh` initializes the log (auto-generated) |
| `pre_flight_pass` | All `validate-task.sh` checks pass |
| `pre_flight_fail` | `validate-task.sh` fails — include error count in `detail` |
| `plan_approved` | Human sends `APPROVED: <task_id>` token |
| `step_start` | Agent begins a step from `03_execution.spec.yaml` |
| `step_complete` | Agent finishes a step |
| `check_run` | A verification check is run — include command + result |
| `check_fail` | A check fails — include command + output excerpt in `detail` |
| `escalation` | Agent outputs an escalation report — include reason |
| `subtask_handoff` | Partial handoff delivered for a sub-task |
| `handoff_delivered` | Full 7-section handoff delivered |

### Agent Responsibility

The agent MUST append to `execution_log.jsonl` at each event above during execution.
Use the exact format — do not omit required fields. The log is append-only: never
delete or overwrite previous entries.

### Example Entries

```jsonl
{"event":"task_created","task_id":"T-20260224-add-retry","size":"medium","timestamp":"2026-02-24T10:00:00Z"}
{"event":"plan_approved","task_id":"T-20260224-add-retry","timestamp":"2026-02-24T10:15:00Z"}
{"event":"step_start","task_id":"T-20260224-add-retry","step_id":"step-1","action":"read_files","timestamp":"2026-02-24T10:16:00Z"}
{"event":"step_complete","task_id":"T-20260224-add-retry","step_id":"step-1","result":"pass","duration_ms":12000,"timestamp":"2026-02-24T10:16:12Z"}
{"event":"check_run","task_id":"T-20260224-add-retry","step_id":"check-lint","action":"run_check","result":"pass","detail":"npm run lint — exit 0","duration_ms":3400,"timestamp":"2026-02-24T10:25:00Z"}
{"event":"handoff_delivered","task_id":"T-20260224-add-retry","timestamp":"2026-02-24T10:30:00Z"}
```

---

## What Makes a Handoff Unacceptable

Reject any handoff that:
- Omits any of the 7 sections
- Claims checks pass without actual output
- Uses "should be fine" or "looks correct" without evidence
- Lists risks as empty when the task touched core infrastructure
- Lists assumptions as empty (there are always assumptions)
- Has TODO comments remaining in touched files
- Has commented-out code remaining in touched files
- Modified files not in `file_change_plan`
