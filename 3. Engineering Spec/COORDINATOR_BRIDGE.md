# Coordinator Bridge — Engineering Spec

> This document explains how to map a Coordinator `team_directive` into the Engineering Spec's existing task and context format. The Engineering Spec itself is NOT modified.

---

## When You Receive a Team Directive

The Coordinator generates a `team_directive` (from `0. Coordinator/team_directive.template.md`) when it's Engineering's turn in the pipeline. This bridge doc tells you how to translate that into the Engineering Spec's native formats.

---

## Mapping: Team Directive → `01_task.spec.yaml`

| Directive Section | Maps To (in task YAML) | Notes |
|-------------------|----------------------|-------|
| **Your Mission** | `task.objective` | Use the mission as the task objective |
| **Expected Deliverables** | `task.deliverables[]` | Each deliverable becomes an entry |
| **Constraints** | `task.constraints[]` | Timeline, budget, tech constraints |
| **Scale** (from header) | `task.scale` | micro/small/medium/large → determines which execution template |
| **Open Questions to Resolve** | `task.open_questions[]` | Engineering should resolve these during planning |

## Mapping: Team Directive → `02_context.spec.md`

| Directive Section | Maps To (in context spec) | Notes |
|-------------------|--------------------------|-------|
| **Project Context** | `## Project Overview` | High-level project description |
| **Context From Prior Teams** | `## Upstream Context` | Decisions and deliverables from prior teams |
| **Key Inputs** | `## Inputs` | Reference materials for the engineering team |
| **Binding Upstream Decisions** | `## Constraints` | These are NON-NEGOTIABLE — engineering must respect them |
| **Handoff Target** | `## Handoff Requirements` | What the next team needs from engineering |

---

## Workflow

1. Receive the Coordinator's `team_directive` for Engineering
2. Use the mappings above to fill in `01_task.spec.yaml` and `02_context.spec.md`
3. Select the execution template based on scale (small/medium/large)
4. Run the Engineering Spec's normal workflow: `A_plan.md` → `B_execute.md` → `C_resume.md` (if needed)
5. Produce deliverables + handoff using `_shared/team_handoff.template.md`

---

## Key Principle

The Engineering Spec's internal process (planning, execution, verification) stays exactly the same. The Coordinator's directive simply provides richer context and binding constraints from the broader product pipeline. This bridge ensures nothing is lost in translation.
