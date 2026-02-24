# Escalation Protocol

> Detailed reference for all agents. The summary in `00_common_policy.md` covers the basics — this document provides the full protocol.

---

## Forward Escalation (Current Team → User/Coordinator)

Use when you encounter an issue during your work that needs external resolution.

### Severity Levels

**`blocking`** — Work cannot continue until this is resolved.
- Examples: missing critical input, contradictory requirements, dependency unavailable, scope ambiguity that changes the deliverable.
- Action: HALT. Present the escalation to the user immediately. Do not proceed with assumptions.

**`advisory`** — Notable concern, but work can continue.
- Examples: potential risk identified, suboptimal but workable constraint, assumption that should be validated later.
- Action: Log the escalation. Continue work. Include it prominently in your handoff.

### Escalation Format

```
ESCALATION — [blocking | advisory]
Trigger: [what specifically happened or was discovered]
Impact: [what this affects — deliverables, timeline, downstream teams]
Options:
  A) [option] — [pros/cons/tradeoffs]
  B) [option] — [pros/cons/tradeoffs]
  C) [option, if applicable]
Recommendation: [which option you recommend and why]
```

### Rules

1. **Always provide options.** Never escalate with just a problem — include at least two resolution paths.
2. **Be specific about impact.** "This is bad" is not useful. "This blocks the pricing section of the PRD because..." is.
3. **Don't stack escalations.** If you have multiple issues, escalate each separately so they can be resolved independently.
4. **Don't escalate preferences.** "I'd prefer to use React" is not an escalation. "The required framework doesn't support the specified feature" is.

---

## Backward Escalation (Downstream Team → Upstream Team)

Use when a downstream team discovers that an upstream decision is flawed, incomplete, or actively blocking progress.

### When to Use

**DO use backward escalation for:**
- Contradictions between upstream decisions and downstream reality
- Missing information that was supposed to be provided upstream
- Feasibility issues with upstream decisions (technically impossible, budget-breaking, etc.)
- Ambiguities in upstream deliverables that lead to conflicting interpretations

**DO NOT use backward escalation for:**
- Disagreements on style or preference
- Minor adjustments you can handle within your own scope
- Questions that can be answered by reading the upstream handoff more carefully
- Wanting to understand rationale (just ask the user directly)

### Backward Escalation Format

```
BACKWARD ESCALATION
From: [your team name]
To: [upstream team that needs to revisit their work]
Issue: [clear statement of what's wrong]
Evidence: [specific references to upstream deliverables + what contradicts them]
Impact: [what happens to your work and downstream teams if unresolved]
Proposed Resolution: [your suggestion for how the upstream team could fix this]
Urgency: [blocking | advisory]
```

### Process

1. The team producing the escalation includes it in their handoff (or flags it to the user immediately if blocking).
2. The user relays it to the Coordinator.
3. The Coordinator assesses:
   - Is this actually an upstream issue, or a misunderstanding?
   - Does it require re-running the upstream team, or just a targeted amendment?
   - What's the pipeline impact?
4. The Coordinator either:
   - Generates a targeted amendment spec for the upstream team
   - Explains the rationale and suggests a workaround for the downstream team
   - Escalates to the user for a decision
5. The resolution is logged in the Coordinator's `decision_log.md`.

### Constraints on Backward Escalation

- **Maximum depth: one level back.** Team 4 can escalate to Team 3, but not directly to Team 1. If the issue traces back further, the Coordinator chains the escalations.
- **No cascading re-runs.** The Coordinator targets the specific issue — it does not re-run an entire upstream team unless absolutely necessary.
- **Resolution is final.** Once the Coordinator resolves a backward escalation, the downstream team accepts the resolution (or the user overrides).
