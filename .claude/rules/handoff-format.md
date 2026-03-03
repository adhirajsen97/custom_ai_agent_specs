# Handoff Format — Reference and Validation

## Full Template

```markdown
# Team Handoff — [Team Name] → [Next Team Name]

Project: [name] | Date: [YYYY-MM-DD] | Scale: [micro/small/medium/large]

---

## 1. Decisions Made

Key decisions — **BINDING** for downstream teams.

| Decision | Rationale | Alternatives Considered |
|----------|-----------|------------------------|
| [what was decided] | [why] | [what else was evaluated and rejected] |

---

## 2. Deliverables Produced

| Deliverable | Description | Location |
|-------------|-------------|----------|
| [name] | [what it contains] | [file path or folder] |

---

## 3. Constraints Established

Constraints downstream teams **MUST** respect. Not optional unless escalated backward.

- **[Constraint name]:** [detail and rationale]

---

## 4. Open Questions / Risks

| Question / Risk | Severity | Affects | Suggested Owner |
|-----------------|----------|---------|-----------------|
| [description] | blocking / advisory | [which teams] | [who should resolve] |

---

## 5. Recommendations for Next Team

Specific guidance for what the receiving team should prioritize.

- [Recommendation with reasoning — not generic advice]

---

## 6. Assumptions

What was assumed during this team's work. Downstream teams should validate.

- **[Assumption]:** [what was assumed and why]
```

---

## Validation Checklist

Before submitting a handoff, verify:

- [ ] All 6 sections are present (none missing, none blank)
- [ ] **Decisions Made**: every decision has a rationale AND at least one alternative considered
- [ ] **Deliverables Produced**: every deliverable has a file path or folder location (not "see above" or "TBD")
- [ ] **Constraints**: written as firm constraints, not suggestions
- [ ] **Open Questions**: each item has a severity (blocking/advisory) and a suggested owner
- [ ] **Recommendations**: specific to the next team's domain (not generic)
- [ ] **Assumptions**: distinct from decisions — these are things taken as given, not things actively decided
- [ ] No section contains "TBD", "N/A", or "see attached" as the sole content
- [ ] Handoff header includes project name, date, and scale

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| "Deliverables: see project folder" | List each deliverable with its specific path |
| Decision with no alternatives considered | Document what was evaluated and why it was rejected |
| Empty constraints section | If truly none, write "No constraints established — next team has full flexibility on [scope]" |
| "TBD" in open questions severity | Every open question must have blocking or advisory severity |
| Recommendations like "do your best" | Write team-specific guidance: "Design should prioritize mobile-first because 80% of target users are mobile" |
