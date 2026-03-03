---
name: discover
description: "Start or restart the project discovery interview. The Coordinator will interview you about your idea, classify the project scale, and build a pipeline plan."
user-invocable: true
---

Run the full project discovery interview workflow. Start at Phase 1 (Idea Capture) and proceed through all 5 phases, adapting depth to the project's complexity.

At the end of the interview, produce:
1. Project summary with scale classification and reasoning
2. Pipeline plan with team roster and ordering
3. Critical unknowns
4. Recommended first team and scope
5. User action items

Write state files (`.pipeline/state.yaml` and `.pipeline/decision_log.md`) on completion.

If a `.pipeline/state.yaml` already exists, ask the user: "A project state already exists for [project name]. Do you want to (a) continue from where you left off, or (b) start fresh with a new project?"
