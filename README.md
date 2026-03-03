# Multi-Team Product Pipeline

A coordinator-driven multi-agent system for taking a project from idea to launch. Uses Claude Code's native agent orchestration — no manual copy-pasting between sessions.

## What This Is

A set of Claude Code configuration files (custom agents, skills, rules) that turn a single `claude --agent coordinator` session into a full product development pipeline. The Coordinator agent interviews you, builds a plan, and dispatches specialized team agents — each working in its own isolated context — and processes their handoffs automatically.

**Teams available:**
- `product-strategist` — Market research, competitive analysis, personas, PRD, pricing
- `design-lead` — User flows, wireframe specs, design system, accessibility
- `engineer` — Architecture, implementation, testing (bridges to Engineering Spec conventions)
- `qa-security` — Test strategy, security audit, compliance checklist
- `data-analyst` — KPIs, event tracking plan, analytics stack, A/B testing
- `gtm-lead` — Positioning, channel strategy, launch plan, growth loops, customer success
- `ops-legal` — Legal outlines, compliance, operational runbooks, cost model

## Quick Start

**1. Install** — Copy `.claude/` and `CLAUDE.md` into your project:

```bash
cp -r /path/to/multi_spec_system/.claude/ your-project/.claude/
cp /path/to/multi_spec_system/CLAUDE.md your-project/CLAUDE.md
```

Or as a git submodule:

```bash
cd your-project
git submodule add https://github.com/adhirajsen97/custom_ai_agent_specs.git .claude-specs
cp -r .claude-specs/.claude .claude
cp .claude-specs/CLAUDE.md CLAUDE.md
```

**2. Run** — Start the coordinator in your project directory:

```bash
cd your-project
claude --agent coordinator
```

**3. Follow the coordinator** — It will interview you, propose a plan, and ask for confirmation before dispatching each team. You stay in control at every step.

## Full Lifecycle Walkthrough

Here's what a typical session looks like from start to finish, using a micro-scale project as an example.

### Step 1: Start the Coordinator

```bash
claude --agent coordinator
```

The coordinator greets you and begins the discovery interview. It asks about your idea, target users, problem being solved, constraints, and existing assets. The depth adapts to complexity — a micro project gets 2-3 follow-ups, a large project gets 10+.

### Step 2: Review the Pipeline Plan

After the interview, the coordinator proposes a plan:

```
### Project Summary
Name: TaskFlow
One-liner: A lightweight CLI task manager for developers
Scale: Micro (single-feature utility, <100 users, solo developer)

### Pipeline Plan
| # | Team               | Why                                  | Focus Area            |
|---|--------------------|--------------------------------------|-----------------------|
| 1 | product-strategist | Define scope, personas, feature list | CLI UX, core commands |
| 2 | engineer           | Build the tool                       | Go CLI, local storage |

Teams skipped: design-lead (CLI, no visual UI), qa-security (no user data),
data-analyst (no tracking needed), gtm-lead (personal tool), ops-legal (no legal surface)

### Recommended First Team
product-strategist — Define the core command set and user persona before building.
```

You can approve, adjust the team list, or ask questions. The coordinator pushes back if your changes seem risky but ultimately defers to you.

### Step 3: Team Dispatch

When you confirm, the coordinator dispatches the first team:

```
Dispatching product-strategist now. They will:
- Research existing CLI task managers
- Define target user persona
- Prioritize the core command set
- Produce a PRD with success metrics

This runs in an isolated context. You'll see their output when they're done.
```

The team agent works autonomously — reading your project files, producing deliverables, and writing them to `deliverables/`. When it finishes, it presents its handoff and states: *"My work is complete. The coordinator will now validate this handoff and dispatch the next team in the pipeline."*

### Step 4: Coordinator Processes the Return

The coordinator validates the handoff and presents a clear transition:

```
### Status
Pipeline: 1 of 2 teams complete

### What Just Happened
product-strategist returned with 4 deliverables:
- deliverables/research_brief.md — 5 competitors analyzed
- deliverables/user_personas.md — 1 persona (solo dev, 50+ tasks/week)
- deliverables/feature_priorities.md — 8 commands prioritized via RICE
- deliverables/prd.md — MVP scope: add, list, done, delete, priority flag

Handoff validated: all 6 sections present, decisions have rationales,
deliverables have file paths.

Key decisions (BINDING for engineer):
- Go CLI with local JSON storage
- 5 core commands for MVP, 3 deferred to v2
- Success metric: <200ms response time for all commands

### Recommended Next Action
Dispatch engineer. They will receive the PRD, command specs, and
persona as binding upstream decisions.

### Pipeline Overview
| # | Team               | Status   | Key Output                      |
|---|--------------------|----------|---------------------------------|
| 1 | product-strategist | complete | PRD, personas, feature priority |
| 2 | engineer           | ready    | Waiting — dispatch now?         |
```

You review and confirm. The coordinator dispatches the next team with all upstream decisions included.

### Step 5: Pipeline Complete

After all teams finish, the coordinator produces a final summary:

```
### Status
Pipeline complete — all 2 teams finished.

### Project Summary — TaskFlow
All deliverables are in deliverables/. Key files:
- deliverables/prd.md — Product requirements
- deliverables/feature_priorities.md — Prioritized command list
- deliverables/engineering_handoff.md — Architecture decisions, test results

### Cross-Cutting Decisions
| Decision                    | Made By            | Affects     |
|-----------------------------|--------------------|-------------|
| Go CLI + local JSON storage | product-strategist | engineer    |
| 5 core commands for MVP     | product-strategist | engineer    |
| Cobra framework + Viper     | engineer           | future work |

### Open Items
| Item                          | Severity | Owner |
|-------------------------------|----------|-------|
| v2 command set not prioritized | advisory | user  |

Pipeline state saved to .pipeline/state.yaml.
```

## Skills Reference

Skills are shortcuts you can use inside a coordinator session. They're invoked with a `/` prefix.

### `/discover` — Start or Restart Discovery

Use when starting a new project or when you want to re-interview from scratch.

```
/discover
```

If a project state already exists, it asks whether to continue or start fresh. Runs the full 5-phase interview and writes `.pipeline/state.yaml` on completion.

**When to use:** Beginning of a new project. Also useful if your project direction has changed significantly and you want a clean re-plan.

### `/progress` — Check Pipeline Status

Use to see where you are at any point.

```
/progress
```

Shows a status table, open questions, active escalations, pipeline health check (staleness, drift, blockers, scope creep), and a recommended next action.

**When to use:** Returning to a session after a break. Checking whether a blocking question has been resolved. Getting a bird's-eye view before deciding what to do next.

### `/handoff` — Generate or Validate Handoffs

Use to validate a team's handoff or generate a blank template.

```
/handoff product-strategist deliverables/handoff.md    # Validate existing handoff
/handoff engineer                                       # Generate blank template
```

Checks all 6 required sections, validates that decisions have rationales, deliverables have file paths, and open questions have severity ratings.

**When to use:** Before confirming a team's output, to double-check completeness. When manually producing a handoff for a team you ran outside the pipeline.

## Session Management

### Resuming a Session

The coordinator persists state in two places:
- **Agent memory** — automatically loaded when you start `claude --agent coordinator`
- **`.pipeline/state.yaml`** — current pipeline state, readable by you and the coordinator

Just run `claude --agent coordinator` in your project directory and it picks up where you left off. Use `/progress` to see the current state.

### What `.pipeline/` Contains

```
your-project/
  .pipeline/
    state.yaml          <- Current pipeline state (teams, statuses, decisions)
    decision_log.md     <- Append-only history of all decisions made
  deliverables/
    product/            <- Product team deliverables
    design/             <- Design team deliverables
    engineering/        <- Engineering deliverables
    ...
```

**`state.yaml`** is overwritten each session — it's always the current state. **`decision_log.md`** is append-only and capped at ~50 entries (oldest get compressed into a History section).

You can read these files directly to inspect pipeline state outside of a coordinator session.

## Handling Edge Cases

### Incomplete Handoff

If a team returns a handoff missing required sections, the coordinator rejects it and tells you exactly what's missing:

```
Handoff validation FAILED for design-lead:
- Decisions Made: 2 decisions missing "Alternatives Considered"
- Deliverables: wireframe_specs.md listed but no file path
- Open Questions: 1 question missing severity rating

The team needs to fix these before we can proceed.
```

### Blocking Escalation

If a team encounters something it can't resolve (missing critical input, contradictory requirements), it raises a blocking escalation. The coordinator presents it with options:

```
ESCALATION — blocking (from engineer)
Trigger: PRD specifies real-time sync but product-strategist chose local JSON storage
Impact: Cannot implement sync without a server component
Options:
  A) Drop real-time sync from MVP — ship local-only first
  B) Add a simple sync server — increases scope to "small" scale
Recommendation: Option A — aligns with micro scale and solo dev constraints

Which option do you want to go with?
```

### Backward Escalation

If a downstream team discovers an upstream decision is flawed, the coordinator mediates:

```
BACKWARD ESCALATION (from engineer → product-strategist)
Issue: Specified "offline-first" but 3 of 5 core features require API calls
The coordinator will generate a targeted amendment for product-strategist
to clarify the offline scope — not a full re-run.
```

### Skipping or Reordering Teams

Tell the coordinator directly: "Skip qa-security" or "Run gtm-lead before engineer." It will adjust the pipeline and log the change in the decision log. It may push back if the reorder creates dependency issues.

### Revisiting a Completed Team's Output

Tell the coordinator: "I want to revise the product strategy." It will assess what's changed, determine if downstream teams are affected, and either generate a targeted amendment or re-dispatch the team with updated context.

## Customization

### Adding a New Team Agent

1. Create `.claude/agents/new-team.md` with the agent definition (frontmatter + system prompt)
2. Add `new-team` to the coordinator's `tools` list in its frontmatter
3. Add the team to the coordinator's Team Roster and pipeline order descriptions

### Adding a New Skill

1. Create `.claude/skills/skill-name/SKILL.md`
2. Skills are auto-discovered — no registration needed

### Adjusting Rigor by Team

Change the `model` field in each agent's frontmatter:
- `opus` — high rigor, complex reasoning (coordinator, engineer)
- `sonnet` — good balance for most teams
- `haiku` — fast, lightweight, template-driven work (ops-legal)

## Architecture Reference

For contributors or anyone wanting to understand the internals:

- **`CLAUDE.md`** — Shared contract loaded by all agents (~60 lines). Contains the handoff format, core rules, and escalation summary.
- **`.claude/rules/`** — Detailed policies (escalation protocol, handoff validation template). Loaded on demand.
- **`.claude/agents/`** — 8 agent definitions. Each is self-contained — knows its role, workflow, evidence standards, and output format.
- **`.claude/skills/`** — 3 user-facing shortcuts (`/discover`, `/progress`, `/handoff`).
- **`.claude/settings.json`** — `SubagentStop` hook that reminds the coordinator to validate handoffs after team agents complete.
- **`reference/`** — Original spec files preserved as source material. The Engineering Spec at `reference/3. Engineering Spec/` is the authoritative reference the `engineer` agent bridges to.

**Dispatch flow:** Coordinator calls `Agent(product-strategist, prompt="...")` → team works in isolated context → returns result to coordinator → coordinator validates, updates state, presents transition to user → user confirms → next team dispatched.

**State persistence:** Dual — agent memory (auto-loaded by Claude Code) + `.pipeline/state.yaml` and `.pipeline/decision_log.md` (inspectable files in your project directory).
