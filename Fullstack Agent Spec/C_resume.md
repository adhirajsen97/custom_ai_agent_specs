# Prompt C — Resume After Partial Failure or Interruption

---

You are a senior engineer resuming a partially completed task from a spec packet.

A previous execution of this task was interrupted or failed.
**Do not re-execute work that has already passed verification.**

---

## Step 1: Determine Your Environment

Before assessing task state, identify which environment you are running in:

### Environment A — CLI / IDE Agent (has shell access)
You can run commands. Proceed to **Step 2A**.

### Environment B — Web / Chat Agent (stateless, no shell access)
You cannot run `git diff` or shell commands.
Proceed to **Step 2B**.

---

## Step 2A — CLI/IDE: Assess Current State via Shell

Run the following and report results before taking any action:

```bash
# 1. Which files have been modified?
git diff --name-only

# 2. What is the current diff scope?
git diff --stat

# 3. Which checks are currently passing?
npm run lint 2>&1 | tail -5
npm test -- <scoped-test-file> 2>&1 | tail -20
npx tsc --noEmit 2>&1 | tail -10

# 4. Are there uncommitted partial changes?
git status --short
```

Report: which steps from `03_execution.spec.yaml` are confirmed complete.

**If task is `size: large`:** also proceed to **Step 2C** before Step 3.

Then proceed to **Step 3**.

---

## Step 2B — Web/Chat: Assess Current State via Human

Since you cannot access the shell, ask the human to provide the following
before you produce a resume plan:

**Request from human (copy and send this):**

```
To resume this task, I need the following from your local repo:

1. Run: git diff --name-only
   → Which files have been modified?

2. Run: git diff --stat
   → What is the scope of current changes?

3. Run: npm run lint && npm test -- <scoped> && npx tsc --noEmit
   → Which checks are currently passing or failing?

4. Describe: At what step did the previous session stop?
   (e.g. "finished idempotency logic, hadn't started retry yet")

5. If size is large: Which sub-task was in progress?
   Was the sub-task partial handoff delivered and approved?
   (e.g. "Sub-task B partial handoff was approved, Sub-task C not started")

6. Paste: Any error output from the last failure (if applicable)
```

Do not produce a resume plan until the human provides this information.

**If task is `size: large`:** also request the sub-task state information in item 5.
Once received, proceed to **Step 2C** (large tasks) or **Step 3** (small/medium).

---

## Step 2C — Large Task Sub-task State Assessment

Large tasks decompose into sub-tasks. Resume must account for sub-task state,
not just file state. Sub-task state and file state can disagree — both must be checked.

For each sub-task in `03_execution.spec.yaml:subtasks`:

| Sub-task ID | Status | Evidence |
|-------------|--------|----------|
| T-TODO-a | Complete / In Progress / Not Started | partial handoff approved / files changed / nothing |
| T-TODO-b | ... | ... |
| T-TODO-c | ... | ... |
| T-TODO-d | ... | ... |

### Sub-task state rules

**Complete:** a sub-task is complete only if:
  - Its partial handoff was delivered AND
  - The human explicitly approved it AND
  - Its `checks` all passed (with output to prove it)

**In Progress (partial):** a sub-task is in progress if:
  - Some of its files have been modified BUT
  - Checks have not all passed, OR partial handoff was not approved

**Not Started:** no files from this sub-task have been modified

### Invalidation check (critical for large tasks)

If a sub-task that was previously marked complete had files modified by a LATER
partial sub-task that is now being rolled back or revised:
→ Mark the earlier sub-task as **needs re-verification** even if it previously passed.

Example: Sub-task B's `coreService.ts` was modified during a partial Sub-task C attempt
that was then interrupted. Sub-task B's checks must be re-run before Sub-task C begins.

### Never carry forward an unverified sub-task

If there is any doubt about whether a prior sub-task is clean:
→ Re-run its checks before resuming
→ Do not assume it's still passing because it passed before

---

## Step 3: Produce a Resume Plan

Based on confirmed state, produce:

### Completed (do not re-run)
List each completed step (or sub-task for large tasks) with evidence.
Evidence = check output, human confirmation message, git commit hash.

### Remaining
List only the steps/sub-tasks from `03_execution.spec.yaml` that are NOT yet complete.

### Needs Re-verification
List any previously-passing step or sub-task whose state may have been invalidated
by subsequent partial changes. These must be re-run even if they passed before.

### Resume Starting Point
State exactly where execution will resume:
- For small/medium: "Resuming at step-X: [description]"
- For large: "Resuming at sub-task [ID], step [N]: [description]"
  "The following prior sub-tasks will be re-verified first: [list]"

---

## Step 4: Confirm Before Executing

State the resume plan explicitly.

Unless `autonomy: fully-autonomous` is set in `01_task.spec.yaml`,
**wait for human confirmation before executing any remaining steps.**

For large tasks: confirmation is required before each sub-task regardless of prior approval.

---

## Step 5: Execute Remaining Steps Only

Follow all rules from `00_policy.spec.md` and Prompt B.

- Do not re-apply changes to files that are already correctly modified
- Do not re-run checks that are confirmed passing and not invalidated
- For large tasks: deliver partial handoff after each sub-task, wait for approval
- If you encounter an escalation trigger: stop immediately per `00_policy.spec.md`

---

## Step 6: Deliver the Full Handoff

The final handoff must cover the **entire task** — not just the resumed portion.

Use the full 7-section handoff format from `04_verify_and_handoff.spec.md`.

Mark any section that was completed in the prior session with:
`[completed in prior session — verified via <evidence>]`

For large tasks: consolidate all sub-task partial handoffs into the final handoff.
Each sub-task's files, changes, and check results should be included under
the relevant sections (Files Changed, Verification Results, etc.).
