resume last session at `claude --resume 3717451c-2525-4060-bda9-78c5aa1afd1d
# Agent Spec System — README`

A structured spec system for delegating coding tasks to AI agents (Claude, Cursor, Copilot, etc.)
with reliable, predictable, and verifiable results across small, medium, and large tasks.

---

## What This System Does

Without structure, AI agents hallucinate scope, skip tests, add unrequested dependencies,
and deliver "done" without evidence. This system fixes that by giving every task:

- A **governing policy** the agent reads before touching anything
- A **task spec** defining exactly what to build and what success looks like
- An **execution plan** defining exactly which files to touch and in what order
- A **handoff contract** defining what "done" actually means (output + evidence, not claims)
- **Validation scripts** that block the agent from running on incomplete specs
- **Git hooks** that prevent placeholder-filled specs from being committed

The result: agents that follow your rules, stay in scope, escalate when blocked,
and deliver verifiable output every time.

---

## Quick Start (Your First Task)

```bash
# 1. Install git hooks (one-time setup)
./hooks/install.sh

# 2. Scaffold a new task
./new-task.sh small add-idempotency-check
# or: ./new-task.sh medium refactor-webhook-handler
# or: ./new-task.sh large rebuild-notification-service

# 3. Fill in the generated spec files (see "What You Edit" below)
#    agent-specs/01_task.spec.yaml      ← task definition
#    agent-specs/03_execution.spec.yaml ← file change plan
#    agent-specs/02_context.spec.md     ← code context

# 4. Validate — must pass before running the agent
./validate-task.sh

# 5. Hand prompts to your agent (see "Workflow by Task Size" below)
```

---

## Repository Structure

```
agent-specs/
│
├── README.md                          ← You are here
│
│── SETUP FILES (configure once per project)
├── CONVENTIONS.md                     ← Your team's coding standards
├── 00_policy.spec.md                  ← Agent governing rules (read-only after setup)
├── 02_context.spec.md                 ← Template: filled per-task by human
├── 04_verify_and_handoff.spec.md      ← Handoff contract (read-only)
│
│── GENERATED PER TASK (by new-task.sh, then filled by human)
├── 01_task.spec.yaml                  ← Active task definition
├── 03_execution.spec.yaml             ← Active execution plan
│
│── SCRIPTS
├── new-task.sh                        ← Scaffolds a new task (run this to start)
├── validate-task.sh                   ← Validates spec before handing to agent
│
│── PROMPTS (paste into agent at each stage)
├── prompts/
│   ├── A_plan.md                      ← Give to agent first (medium/large tasks)
│   ├── B_execute.md                   ← Give to agent to execute
│   └── C_resume.md                    ← Give to agent to resume interrupted work
│
│── TEMPLATES (source files — do not edit the active task files directly)
├── templates/
│   ├── small.task.template.yaml
│   ├── medium.task.template.yaml
│   ├── large.task.template.yaml
│   ├── 03_execution.small.template.yaml
│   ├── 03_execution.medium.template.yaml
│   └── 03_execution.large.template.yaml
│
└── hooks/                             ← Git hooks for automated enforcement
    ├── install.sh
    ├── check-conventions-version.sh   ← Pre-commit: version sync check
    └── check-todo-fields.sh           ← Pre-push: TODO placeholder check
```

---

## What Each Person / Agent Touches

### 🟢 Human Edits (you fill these in per task)

| File | What to fill in |
|------|----------------|
| `01_task.spec.yaml` | Title, problem summary, acceptance criteria, risk level, blast radius, rollback steps |
| `02_context.spec.md` | Relevant files table, current behavior description, patterns to follow, known pitfalls |
| `03_execution.spec.yaml` | `file_change_plan` (exact files + what changes), ordered steps, verification commands |
| `CONVENTIONS.md` | Your team's actual patterns: logger, error types, test style, naming rules |

**Rule of thumb:** If it has `TODO:` in it, a human needs to fill it in before the agent sees it.

---

### 🔵 Human Sets Up Once (then leaves alone)

| File | What it is |
|------|-----------|
| `CONVENTIONS.md` | Your coding standards. Edit when team conventions change — bump `conventions_version` when you do. |
| `00_policy.spec.md` | Agent governing policy. Edit only if you want to change how agents behave system-wide. |
| `04_verify_and_handoff.spec.md` | Handoff contract. Defines "done." No per-task edits needed. |

---

### 🔴 Agent Reads Only (never edits)

| File | Why the agent reads it |
|------|----------------------|
| `00_policy.spec.md` | Learn governing rules, escalation triggers, scope discipline |
| `CONVENTIONS.md` | Learn code patterns to follow |
| `04_verify_and_handoff.spec.md` | Understand what a complete handoff looks like |

---

### 🟡 Agent Reads + Produces Output Against

| File | Agent's relationship to it |
|------|--------------------------|
| `01_task.spec.yaml` | Reads acceptance criteria, constraints, risk level |
| `02_context.spec.md` | Reads current behavior, pitfalls, relevant files |
| `03_execution.spec.yaml` | Reads file_change_plan and steps; executes them in order |

---

### ⚙️ Scripts (run by human, not agent)

| Script | When to run |
|--------|------------|
| `new-task.sh <size> [slug]` | Start of every new task — scaffolds spec files |
| `validate-task.sh` | After filling in specs, before running agent — blocks on any unresolved placeholder |
| `hooks/install.sh` | Once per repo — installs git hooks |

---

## Workflow by Task Size

### Small Task (1–3 files, no new abstractions)

```
1. ./new-task.sh small <slug>
2. Fill in: 01_task.spec.yaml + 03_execution.spec.yaml + 02_context.spec.md
3. ./validate-task.sh                    ← must pass
4. Paste prompts/B_execute.md → agent    ← agent executes directly, no plan step
5. Agent delivers 7-section handoff
```

### Medium Task (3–8 files, ≤1 new module)

```
1. ./new-task.sh medium <slug>
2. Fill in: 01_task.spec.yaml + 03_execution.spec.yaml + 02_context.spec.md
3. ./validate-task.sh                    ← must pass
4. Paste prompts/A_plan.md → agent       ← agent produces plan, waits
5. Review plan → approve or request changes
6. Paste prompts/B_execute.md → agent    ← agent executes
7. Agent delivers 7-section handoff
```

### Large Task (8+ files, multiple abstractions)

```
1. ./new-task.sh large <slug>
2. Fill in: 01_task.spec.yaml + 03_execution.spec.yaml + 02_context.spec.md
   (including decomposition sub-tasks in 03_execution)
3. ./validate-task.sh                    ← must pass
4. Paste prompts/A_plan.md → agent       ← agent produces full plan, waits
5. Review plan → approve
6. Paste prompts/B_execute.md → agent    ← agent executes sub-task A only
7. Review partial handoff → approve → agent continues to sub-task B
   (repeat for each sub-task)
8. Agent delivers final 7-section handoff covering entire task
```

### Resuming Interrupted Work

```
1. Paste prompts/C_resume.md → agent
2. Agent assesses state (what's done, what's not, what needs re-verification)
3. Agent presents resume plan → approve
4. Agent continues from last confirmed-clean checkpoint
```

---

## Task Size Reference

| Size | Files Touched | New Abstractions | Sessions | Autonomy Default |
|------|--------------|------------------|----------|------------------|
| small | 1–3 | None | 1 | `fully-autonomous` |
| medium | 3–8 | ≤1 new module | 1–2 | `plan-then-confirm` |
| large | 8+ | Multiple | 3+ | `human-in-loop` |

**When in doubt → round up.** Underclassifying size is the most common cause of scope bleed.

**Blast radius override:** If `blast_radius: core` (touching auth, DB schema, entry points,
or core shared libs), the agent is forced to a higher autonomy level regardless of file count.

---

## The Spec Files Explained

### `01_task.spec.yaml` — What to Build

The task definition. Filled in by a human per task. Contains:
- `title` — short imperative description of the task
- `problem.summary` / `problem.goal` — what's broken and what done looks like
- `problem.non_goals` — explicitly what you are NOT doing (prevents scope creep)
- `acceptance_criteria` — observable, testable list of what must be true when done
- `constraints` — allowed dependencies, API contract rules
- `risk_level` + `blast_radius` — controls autonomy level and escalation behavior
- `rollback` — structured revert instructions per file/sub-task

---

### `02_context.spec.md` — Code Context

Gives the agent understanding of the codebase without making it explore blindly. Contains:
- `Relevant Files` table — exact paths, roles, key exports
- `Current Behavior` — step-by-step description of what the code does today
- `Existing Patterns to Follow` — specific file references for logger, retry, error handling
- `Known Pitfalls` — edge cases, nulls, prior failure modes
- `Test Isolation Notes` — known test ordering issues or shared fixtures
- `Out-of-Scope Context` — files the agent must not touch even if they seem related

---

### `03_execution.spec.yaml` — How to Build It

The agent's execution contract. Filled in by a human per task. Contains:
- `file_change_plan` — every authorized file, action (modify/create/delete), and change summary
- `steps` — ordered sequence: read → write → verify
- `checks` — exact commands to run, pass conditions, scope
- `rollback_steps` — concrete revert instructions (not prose)

**This is the most important file to fill in carefully.** Vague change summaries produce
vague implementations. The more precise the `file_change_plan`, the tighter the agent stays in scope.

---

### `CONVENTIONS.md` — Your Team's Standards

The coding rulebook the agent must follow. Set up once for your project:
- Language, formatter, linter, test framework
- Architecture patterns: Result<T,E>, logging, error types, retry logic, DB access
- Naming conventions
- Test requirements (minimum happy/fail/edge coverage per function)
- What agents must never do

**When you change this file:** bump `conventions_version`, update `last_updated`,
and update `02_context.spec.md:conventions_version` to match.
The pre-commit git hook will enforce this automatically after running `hooks/install.sh`.

---

## Escalation — What Happens When the Agent Gets Stuck

The agent will stop and output a structured escalation report if it hits a blocker:

```
ESCALATION REQUIRED
───────────────────────────────────────
Reason:   A required change falls outside the declared file_change_plan
Trigger:  Scope discipline rule — 00_policy.spec.md
Blocker:  validator.ts needs to be modified but is not in file_change_plan
Impact:   Cannot complete acceptance criterion 2 without touching this file
Options:
  A) Add validator.ts to file_change_plan and re-approve execution plan (safest)
  B) Descope criterion 2 to a follow-up task
Waiting for: human decision
───────────────────────────────────────
```

When you see this: read the options, decide, respond with your choice.
The agent does not proceed until you respond. This is intentional.

---

## Common Escalation Triggers

| Trigger | Cause | Fix |
|---------|-------|-----|
| Unresolved TODO fields | Spec not fully filled in | Run `validate-task.sh` before giving to agent |
| conventions_version mismatch | CONVENTIONS.md updated without syncing context | Update `02_context.spec.md:conventions_version` |
| Stale context (>14 days) | `last_verified` too old | Re-verify file paths, re-stamp date |
| Path-based risk trigger | File matches auth/migrations/secrets pattern | Declare `risk_override: justified` or upgrade autonomy |
| File not in `file_change_plan` | Agent discovered a needed file you didn't list | Add file to plan and re-approve |
| New dependency needed | Package not in `allowed_additions` | Add to `allowed_additions` with approval fields |

---

## Validation Script Reference

```bash
./validate-task.sh
```

Checks (in order):
1. All required spec files exist
2. No unresolved `TODO:`, `YYYY-MM-DD`, or `<placeholder>` values in required fields
3. `conventions_version` matches between `CONVENTIONS.md` and `02_context.spec.md`
4. `02_context.spec.md:last_verified` is within 14 days
5. `task_id` is consistent across `01_task.spec.yaml` and `03_execution.spec.yaml`
6. `risk_level` + `blast_radius` + `autonomy` are coherent (e.g., `risk: high` requires `human-in-loop`)

**Exit code 0** = safe to run agent.
**Exit code 1** = blocked, fix errors first.

---

## Git Hooks Reference

Install once with `./hooks/install.sh`. After that they run automatically.

| Hook | Trigger | What it checks |
|------|---------|---------------|
| `pre-commit` | Every `git commit` | `conventions_version` in sync between CONVENTIONS.md and 02_context.spec.md |
| `pre-push` | Every `git push` | No unresolved TODO/placeholder values in active spec files |

Bypass in an emergency: `git commit --no-verify` / `git push --no-verify`.
Do not bypass routinely — the hooks exist because manual discipline drifts.

---

## Adapting to Your Repo

### If your repo doesn't use Jest/TypeScript

Add `toolchain_overrides` to your task spec:

```yaml
toolchain_overrides:
  test_command: "npx vitest run"
  lint_command: "npx eslint ."
  typecheck_command: "npx tsc --noEmit"
```

The agent will use these commands instead of the CONVENTIONS.md defaults.

### If your patterns differ from the defaults in CONVENTIONS.md

Edit `CONVENTIONS.md` to match your actual repo. Update:
- Logger usage pattern (point to your actual logger)
- Error type pattern (point to your actual error classes)
- Retry pattern (point to your actual reference implementation)
- Test mocking style

Then bump `conventions_version` and sync `02_context.spec.md`.

### If you want stricter or looser autonomy defaults

Edit the `autonomy` field in `01_task.spec.yaml` after scaffolding.
Policy still enforces minimum autonomy levels for `risk_level: high` and `blast_radius: core`.

---

## File Ownership at a Glance

```
                    ┌─────────────────────────────────────────────┐
                    │  HUMAN SETS UP ONCE (project-level config)  │
                    │  CONVENTIONS.md                             │
                    │  00_policy.spec.md                          │
                    │  04_verify_and_handoff.spec.md              │
                    └──────────────────┬──────────────────────────┘
                                       │
                    ┌──────────────────▼──────────────────────────┐
                    │  HUMAN FILLS IN PER TASK                    │
                    │  01_task.spec.yaml      (what to build)     │
                    │  02_context.spec.md     (code context)      │
                    │  03_execution.spec.yaml (how to build it)   │
                    └──────────────────┬──────────────────────────┘
                                       │  validate-task.sh passes
                    ┌──────────────────▼──────────────────────────┐
                    │  AGENT READS ALL OF THE ABOVE               │
                    │  A_plan.md    → produces plan               │
                    │  B_execute.md → executes plan               │
                    │  C_resume.md  → resumes if interrupted      │
                    └──────────────────┬──────────────────────────┘
                                       │
                    ┌──────────────────▼──────────────────────────┐
                    │  AGENT DELIVERS                             │
                    │  7-section handoff with actual check output │
                    └─────────────────────────────────────────────┘
```