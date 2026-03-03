# Escalation Protocol

## Forward Escalation (Current Team → Coordinator/User)

Use when you encounter an issue during your work that needs external resolution.

### Severity

**`blocking`** — Work cannot continue until resolved.
- Examples: missing critical input, contradictory requirements, scope ambiguity that changes the deliverable.
- Action: HALT. Present escalation immediately. Do not proceed with assumptions.

**`advisory`** — Notable concern, work can continue.
- Examples: potential risk, suboptimal but workable constraint, assumption needing later validation.
- Action: Log it. Continue work. Include prominently in handoff.

### Format

```
ESCALATION — [blocking | advisory]
Trigger: [what specifically happened or was discovered]
Impact: [what this affects — deliverables, downstream teams]
Options:
  A) [option] — [pros/cons/tradeoffs]
  B) [option] — [pros/cons/tradeoffs]
Recommendation: [which option and why]
```

### Rules
1. Always provide options. Never escalate with just a problem — include at least two resolution paths.
2. Be specific about impact. "This is bad" is useless. "This blocks the pricing section because..." is useful.
3. Don't stack escalations. Raise each issue separately so they can be resolved independently.
4. Don't escalate preferences. "I'd prefer React" is not an escalation. "The required framework doesn't support the specified feature" is.

---

## Backward Escalation (Downstream Team → Upstream Team)

Use ONLY when a downstream team discovers an upstream decision is flawed, incomplete, or actively blocking progress.

### When to Use

**DO use for:**
- Contradictions between upstream decisions and downstream reality
- Missing information that upstream was supposed to provide
- Feasibility issues (technically impossible, budget-breaking)
- Ambiguities in upstream deliverables causing conflicting interpretations

**DO NOT use for:**
- Style or preference disagreements
- Minor adjustments you can handle within your scope
- Questions answerable by re-reading the upstream handoff
- Wanting to understand rationale (ask the coordinator)

### Format

```
BACKWARD ESCALATION
From: [your team]
To: [upstream team that needs to revisit]
Issue: [clear statement of what's wrong]
Evidence: [specific references to upstream deliverables + what contradicts them]
Impact: [what happens to your work and downstream teams if unresolved]
Proposed Resolution: [your suggestion for how the upstream team could fix this]
Urgency: [blocking | advisory]
```

### Process

1. Include the escalation in your handoff (or flag immediately if blocking).
2. Coordinator assesses: Is this actually upstream's issue, or a misunderstanding?
3. Coordinator either: generates a targeted amendment spec for the upstream team, explains the rationale and suggests a workaround, or escalates to the user.
4. Resolution is logged in `.pipeline/decision_log.md`.

### Constraints
- **Max depth: one level back.** Team 4 can escalate to Team 3, not directly to Team 1.
- **No cascading re-runs.** The Coordinator targets the specific issue — it does not re-run an entire upstream team unless absolutely necessary.
- **Resolution is final.** Once the Coordinator resolves a backward escalation, the downstream team accepts the resolution (or the user overrides).
