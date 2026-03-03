---
name: progress
description: "Check pipeline status, health, and recommended next action. Shows which teams are complete, active, and pending."
user-invocable: true
---

Read `.pipeline/state.yaml` and `.pipeline/decision_log.md` from the current project directory.

Present:

### Project Status — [Project Name]
Scale: [micro/small/medium/large] | Progress: [X of Y teams complete]

| # | Team | Status | Key Output | Notes |
|---|------|--------|------------|-------|
| 1 | [team] | complete / active / pending / skipped | [1-line summary] | [notes] |

### Open Questions
[List unresolved questions that affect the pipeline, with severity]

### Active Escalations
[List any open backward escalations]

### Pipeline Health Check
Flag any issues found:
- **Staleness**: any completed team output that may be outdated
- **Drift**: goals or constraints that may have changed
- **Blockers**: pending teams blocked by unresolved questions
- **Scope creep**: project that has grown beyond its scale classification

### Recommended Next Action
[Specific next step — which team to dispatch, what question to resolve, etc.]

If `.pipeline/state.yaml` does not exist, tell the user: "No project state found. Run `/discover` to start the discovery interview."
