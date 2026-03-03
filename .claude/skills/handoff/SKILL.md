---
name: handoff
description: "Generate or validate a team handoff document. Pass the team name and optionally a path to their output to validate."
argument-hint: "<team-name> [path-to-output]"
user-invocable: true
---

$ARGUMENTS

If arguments include a file path, read that file and validate the handoff:

**Validation checklist:**
- [ ] All 6 sections present (Decisions Made, Deliverables Produced, Constraints Established, Open Questions/Risks, Recommendations for Next Team, Assumptions)
- [ ] Every decision has a rationale AND at least one alternative considered
- [ ] Every deliverable has a specific file path (not "see above" or "TBD")
- [ ] Every constraint is written as a firm constraint, not a suggestion
- [ ] Every open question has a severity (blocking/advisory) and a suggested owner
- [ ] Recommendations are specific to the next team's domain
- [ ] No section contains "TBD", "N/A", or "see attached" as the sole content

If the handoff is valid: "Handoff looks complete. Ready to return to the coordinator."
If invalid: list exactly what's missing or needs fixing.

If no file path is provided, generate a blank handoff template for the specified team:

```markdown
# Team Handoff — [Team Name] → [Next Team Name]

Project: [name] | Date: [YYYY-MM-DD] | Scale: [micro/small/medium/large]

## 1. Decisions Made

| Decision | Rationale | Alternatives Considered |
|----------|-----------|------------------------|
| | | |

## 2. Deliverables Produced

| Deliverable | Description | Location |
|-------------|-------------|----------|
| | | |

## 3. Constraints Established

- **[Constraint]:** [detail and rationale]

## 4. Open Questions / Risks

| Question / Risk | Severity | Affects | Suggested Owner |
|-----------------|----------|---------|-----------------|
| | blocking / advisory | | |

## 5. Recommendations for Next Team

- [Specific recommendation with reasoning]

## 6. Assumptions

- **[Assumption]:** [what was assumed and why]
```
