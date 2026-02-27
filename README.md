# Multi-Agent SDLC Spec System (Coordinator + Team Agents)

A spec-driven, multi-agent workflow that helps you go from **raw idea → shipped product** by assigning AI agents to the roles you normally have to wear yourself (product, design, engineering, QA, GTM, ops), all orchestrated by a **Coordinator** that keeps the project coherent across sessions.

---

## Contents
- [Why this project?](#why-this-project)
- [What’s included](#whats-included)
- [Roles (the “teams”)](#roles-the-teams)
- [How to use](#how-to-use)
- [How to follow the workflow](#how-to-follow-the-workflow)
- [Behind the scenes: how Coordinator + agents actually work](#behind-the-scenes-how-coordinator--agents-actually-work)
- [SDLC mapping (for beginners + industry folks)](#sdlc-mapping-for-beginners--industry-folks)
- [Tips](#tips)
- [License](#license)

---

## Why this project?

Most “AI coding” tools optimize for writing code faster. That’s useful, but it doesn’t solve the harder problem: **getting from an idea to a shipped product when you’re wearing every hat**. :contentReference[oaicite:2]{index=2}

This system exists because the real bottleneck isn’t code — it’s **coordination**: choosing the right thing to build, preserving decisions, keeping teams aligned, and not losing context between “roles.” :contentReference[oaicite:3]{index=3}

It’s designed as a **spec layer** (policies + prompts + handoff contracts) that sits above any particular model/tool, so you can swap the engine without rebuilding your workflow. :contentReference[oaicite:4]{index=4}

---

## What’s included

At a high level, the system is:
- A **Coordinator** agent that interviews you, clarifies goals, and builds/adapts a project pipeline. :contentReference[oaicite:5]{index=5}
- Multiple **team agents** (Product, Design, Engineering, QA, etc.) that each produce one “deliverable.”
- A **mandatory handoff format** so every output becomes the next input (no missing context, no silent contradictions). :contentReference[oaicite:6]{index=6}
- A lightweight **persistent state** approach (YAML snapshots + decision log + pipeline plan) so you can work across many clean chat sessions without bloating context. :contentReference[oaicite:7]{index=7}

> Core principle: **each team agent’s output is the next team’s input through a binding contract.** :contentReference[oaicite:8]{index=8}

---

## Roles (the teams)

The default pipeline looks like: :contentReference[oaicite:9]{index=9}

1. **Coordinator**
   - Interviews you, distills the idea, sets goals/outcomes, and generates the pipeline. :contentReference[oaicite:10]{index=10}
   - Acts as a *reasoner* (not just a router): it checks conflicts, changes the pipeline if decisions change, and pulls teams earlier/later when needed. :contentReference[oaicite:11]{index=11}

2. **Product & Strategy**
   - Market/user framing, competitive notes, PRD, feature prioritization. :contentReference[oaicite:12]{index=12}

3. **Design & UX**
   - User flows, wireframes, design system constraints. :contentReference[oaicite:13]{index=13}

4. **Engineering**
   - Architecture + implementation plan + code execution tasks. :contentReference[oaicite:14]{index=14}

5. **QA & Security**
   - Test strategy, risk review, security audit/compliance checklist. :contentReference[oaicite:15]{index=15}

6. **Data & Analytics**
   - KPIs, tracking plan, dashboards/telemetry plan. :contentReference[oaicite:16]{index=16}

7. **GTM & Customer Success**
   - Launch plan, growth loops, onboarding/support posture. :contentReference[oaicite:17]{index=17}

8. **Operations & Legal**
   - ToS/privacy basics, runbooks, cost modeling, operational readiness. :contentReference[oaicite:18]{index=18}

### Two important behavior rules
- **Decisions flow downward and are binding** (upstream constraints apply downstream; disagreements escalate explicitly). :contentReference[oaicite:19]{index=19}
- **Evidence over vibes**: teams should cite sources/assumptions instead of producing confident fluff. :contentReference[oaicite:20]{index=20}

---

## How to use

### Step 1 — Setup
Add this repo inside your project folder (copy it, or add as a submodule/subtree).
your-project/
├─ agent-specs/                         # this repo (policies, prompts, templates)
│  ├─ **all files from this repo**


### Step 2 — Coordinator session
Open a new chat with your preferred model/tool and paste the Coordinator prompt.
I recommend using a higher end model for the planning or for the coordinator persona

Tell it:
- your idea (1–3 paragraphs)
- constraints (time, budget, tech stack, platform)
- “I want you to act as the Coordinator and build the pipeline + first directives.”

The Coordinator should output:
- distilled project statement + goals
- initial pipeline (which agents, in what order)
- “next session prompts” for each team agent

### Step 3 — Begin development (team sessions)
Take the Coordinator’s directive for the *next team* and paste it into a **new clean chat**.

That team agent produces:
- its deliverable (e.g., PRD, wireframes, architecture)
- a **handoff doc** (what the Coordinator must know next)

### Step 4 — Connect multiple agents (handoff loop)
After each team session:
1. Copy the **handoff doc**
2. Start a fresh chat with the **Coordinator**
3. Paste the handoff doc
4. The Coordinator decides next steps, resolves conflicts, and emits the next team prompt(s)

Repeat until shipped.

---

## How to follow the workflow

### The “one loop” you repeat

(You) Idea / Update
→ (Coordinator) clarifies + plans + assigns next role
→ (Team Agent) produces deliverable + handoff
→ (Coordinator) updates state + assigns next role


### Minimal checklist per cycle
- [ ] Did the team output match upstream constraints? :contentReference[oaicite:21]{index=21}
- [ ] Did it include assumptions/sources where needed? :contentReference[oaicite:22]{index=22}
- [ ] Did it produce a handoff doc that a new session can understand? :contentReference[oaicite:23]{index=23}
- [ ] Did the Coordinator update the pipeline if the project changed? :contentReference[oaicite:24]{index=24}

---

## Behind the scenes: how Coordinator + agents actually work

### 1) Coordinator is a “reasoner,” not a traffic cop
Instead of blindly routing tasks, the Coordinator evaluates whether new decisions require pipeline changes (skip teams, reorder teams, add compliance earlier, etc.). :contentReference[oaicite:25]{index=25}

### 2) Binding contracts prevent drift
Outputs aren’t “nice-to-have notes.” They become constraints:
- Product decisions → Design constraints
- Design specs → Engineering requirements
- Engineering architecture → QA audit surface :contentReference[oaicite:26]{index=26}

### 3) Context stays small on purpose (anti-bloat)
Instead of carrying huge chat history, state is kept as compact snapshots:
- **Project state**: overwritten each session (current snapshot)
- **Decision log**: append-only but compresses over time
- **Pipeline plan**: overwritten; completed teams collapse to one-liners :contentReference[oaicite:27]{index=27}

This lets “session 8 load as fast as session 1.” :contentReference[oaicite:28]{index=28}

### 4) Evidence requirements reduce “strategy fluff”
Agents must attach sources or explicit assumptions for claims (market, UX, growth projections, etc.). :contentReference[oaicite:29]{index=29}

---

## SDLC mapping (for beginners + industry folks)

### If you’re not familiar with SDLC
Just follow the pipeline order. Think of it like:
1. **Figure out what to build** (Product)
2. **Decide how it should work** (Design)
3. **Build it** (Engineering)
4. **Make sure it doesn’t break / isn’t risky** (QA/Security)
5. **Decide how you’ll measure success** (Data/Analytics)
6. **Launch + support it** (GTM/CS + Ops/Legal)

The Coordinator will keep you from skipping steps accidentally when the project needs them. :contentReference[oaicite:30]{index=30}

### If you *are* familiar with SDLC
Use it like a modular SDLC router:
- Skip Design for API-only products (Coordinator can collapse teams when appropriate). :contentReference[oaicite:31]{index=31}
- Pull Ops/Legal earlier when compliance shows up.
- Run QA/Security in parallel once architecture stabilizes.
- Swap in your own internal templates (PRD format, ADRs, threat models) while keeping the same handoff contract pattern. :contentReference[oaicite:32]{index=32}

---

## Tips
- Treat handoffs as **interfaces**: clear inputs/outputs beat long prose. :contentReference[oaicite:33]{index=33}
- Don’t let downstream teams override upstream decisions silently — escalate conflicts back to Coordinator. :contentReference[oaicite:34]{index=34}
- Keep “state” lightweight and “deliverables” detailed. :contentReference[oaicite:35]{index=35}
- Require evidence/assumptions for anything that smells like strategy. :contentReference[oaicite:36]{index=36}

---

## License
Add your license here.

Recommended layout:
