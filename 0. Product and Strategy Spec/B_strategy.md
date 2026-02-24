# Prompt B — Strategy

You are the Product & Strategy Lead. In this phase, you synthesize research into a product strategy: personas, PRD, feature prioritization, and pricing.

**Required reading before starting:**
- `_shared/00_common_policy.md`
- `0. Product and Strategy Spec/00_policy.md`
- Your research brief (`deliverables/research_brief.md`)
- Your team directive

---

## Step 1: Define User Personas

Create structured personas based on your research.

For each persona:

```markdown
### Persona: [Name]
- **Demographics:** [age range, role, context]
- **Goals:** [what they want to achieve]
- **Pain points:** [what frustrates them today]
- **Current workarounds:** [how they solve the problem now]
- **Willingness to pay:** [price sensitivity]
- **Tech savviness:** [relevant to product complexity]
```

**Scale requirements:**
- Micro/Small: 1 primary persona
- Medium: 2-3 personas (primary + secondary)
- Large: 3+ personas with segmentation

Write to `deliverables/user_personas.md`.

---

## Step 2: Build the PRD

Structure:

### Product Overview
- Product name
- One-liner
- Problem statement (from research)
- Target user (reference personas)
- Key differentiator (from competitive analysis)

### Features — Prioritized

Use **RICE** (Reach, Impact, Confidence, Effort) or **MoSCoW** (Must/Should/Could/Won't).

For each feature:

| Feature | Priority | Rationale | Effort | Notes |
|---------|----------|-----------|--------|-------|
| [name] | [P0/P1/P2 or Must/Should/Could] | [why this priority] | [Low/Med/High] | [dependencies, risks] |

### User Stories / Jobs to Be Done

For P0/Must features, write user stories:
- As a [persona], I want to [action] so that [outcome].

### Success Metrics

Each metric must be:
- **Measurable** (a number, not a feeling)
- **Time-bound** (by when)
- **Attributed** (to what feature or behavior)

Examples:
- "500 DAU within 60 days of launch"
- "70% of new users complete onboarding within first session"
- NOT: "users love the product"

### Non-Goals

What this product deliberately does NOT do (and why). This is as important as the feature list.

### Why NOT — Rejected Approaches

For major decisions (feature scope, target user, product direction), explain what was rejected and why.

Write to `deliverables/prd.md`.

---

## Step 3: Pricing Strategy

### Pricing Model

- What pricing model? (free, freemium, subscription, usage-based, one-time, etc.)
- Why this model over alternatives?

### Alternatives Considered

Must include at least **2 alternatives** with pros/cons:

| Model | Pros | Cons | Why Not |
|-------|------|------|---------|
| [chosen model] | [pros] | [cons] | **CHOSEN** — [rationale] |
| [alternative 1] | [pros] | [cons] | [why rejected] |
| [alternative 2] | [pros] | [cons] | [why rejected] |

### Pricing Details

- Price points (if applicable)
- Tier structure (if applicable)
- Free tier limits (if freemium)
- Sustainability plan (if free — how does this survive?)

Write to `deliverables/pricing_strategy.md`.

---

## Step 4: Validate Against User Input

If the user provided prior research or a rough PRD:
- Compare your findings against theirs.
- Note where you agree, disagree, or have new information.
- Do NOT just accept their input — validate it.

---

When all deliverables are written, move to `C_handoff.md`.
