#!/usr/bin/env bash
# ============================================================
# new-task.sh — Agent task scaffolding script
# Usage: ./new-task.sh <size> [task-slug] [--stack <ts|python|go>]
#   size: small | medium | large
#   task-slug: optional, e.g. "add-retry-webhook" (used in task_id)
#   --stack: optional, selects conventions file (default: ts)
#            ts     → CONVENTIONS.md
#            python → CONVENTIONS.python.md
#            go     → CONVENTIONS.go.md
#
# What it does:
#   1. Copies the correct task template into agent-specs/
#   2. Copies the correct 03_execution template into agent-specs/
#   3. Copies the correct CONVENTIONS file into agent-specs/
#   4. Stamps task_id with today's date + slug
#   5. Initializes execution_log.jsonl
#   6. Archives existing spec (if any) to specs/archive/<old_task_id>/ before overwriting
#   7. Verifies conventions_version sync between CONVENTIONS.md and 02_context.spec.md
#   8. Prints the correct prompt sequence to run
#   9. Warns on any pre-existing TODO markers in policy/conventions files
#
# NOTE: last_verified in 02_context.spec.md is NOT auto-stamped.
#   Run stamp-context.sh AFTER you have personally verified the context.
# ============================================================

set -euo pipefail

# ── Parse arguments ──────────────────────────────────────────
SIZE="${1:-}"
SLUG="${2:-task}"
STACK="ts"

# Check for --stack flag anywhere in args
for i in "$@"; do
  if [[ "$i" == "--stack" ]]; then
    shift_next=1
    continue
  fi
  if [[ "${shift_next:-}" == "1" ]]; then
    STACK="$i"
    shift_next=0
  fi
done
SPEC_DIR="$(dirname "$0")/agent-specs"
TEMPLATE_DIR="$SPEC_DIR/templates"
TODAY=$(date +%Y-%m-%d)
TASK_ID="T-$(date +%Y%m%d)-${SLUG}"

# ── Colour helpers ────────────────────────────────────────────
RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✅  $*${NC}"; }
warn() { echo -e "${YELLOW}⚠️   $*${NC}"; }
err()  { echo -e "${RED}❌  $*${NC}"; }

# ── Validate input ────────────────────────────────────────────
if [[ -z "$SIZE" ]]; then
  err "Usage: ./new-task.sh <small|medium|large> [task-slug]"
  exit 1
fi

if [[ "$SIZE" != "small" && "$SIZE" != "medium" && "$SIZE" != "large" ]]; then
  err "Invalid size: '$SIZE'. Must be small, medium, or large."
  exit 1
fi

# ── Resolve conventions file based on stack ──────────────────
SCRIPT_DIR="$(dirname "$0")"
case "$STACK" in
  ts)     CONV_SOURCE="$SCRIPT_DIR/CONVENTIONS.md" ;;
  python) CONV_SOURCE="$SCRIPT_DIR/CONVENTIONS.python.md" ;;
  go)     CONV_SOURCE="$SCRIPT_DIR/CONVENTIONS.go.md" ;;
  *)
    err "Invalid stack: '$STACK'. Must be ts, python, or go."
    exit 1
    ;;
esac

if [[ ! -f "$CONV_SOURCE" ]]; then
  err "Conventions file not found: $CONV_SOURCE"
  exit 1
fi

TASK_TEMPLATE="$TEMPLATE_DIR/${SIZE}.task.template.yaml"
EXEC_TEMPLATE="$TEMPLATE_DIR/03_execution.${SIZE}.template.yaml"

if [[ ! -f "$TASK_TEMPLATE" ]]; then
  err "Task template not found: $TASK_TEMPLATE"
  exit 1
fi

if [[ ! -f "$EXEC_TEMPLATE" ]]; then
  err "Execution template not found: $EXEC_TEMPLATE"
  err "Run 'ls $TEMPLATE_DIR' to see available templates."
  exit 1
fi

# ── Safety check: warn if active spec files exist ─────────────
SHOULD_ARCHIVE=0
if [[ -f "$SPEC_DIR/01_task.spec.yaml" ]]; then
  warn "An existing 01_task.spec.yaml was found."
  read -rp "    Overwrite? The current spec will be archived first. [y/N]: " CONFIRM
  if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Aborted. No files changed."
    exit 0
  fi
  SHOULD_ARCHIVE=1
fi

# ── Archive previous spec before overwriting ──────────────────
if [[ $SHOULD_ARCHIVE -eq 1 ]]; then
  OLD_TASK_ID=$(grep 'task_id:' "$SPEC_DIR/01_task.spec.yaml" | head -1 \
    | sed 's/.*task_id: *//' | tr -d ' "' | sed 's/#.*//' | tr -d '[:space:]')
  if [[ -n "$OLD_TASK_ID" ]] && ! echo "$OLD_TASK_ID" | grep -qE 'TODO|YYYY'; then
    ARCHIVE_DIR="$(dirname "$0")/specs/archive/${OLD_TASK_ID}"
    mkdir -p "$ARCHIVE_DIR"
    for f in "$SPEC_DIR"/*; do
      [[ -f "$f" ]] && cp "$f" "$ARCHIVE_DIR/"
    done
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) archived by new-task.sh" > "$ARCHIVE_DIR/archived_at.txt"
    ok "Archived: $OLD_TASK_ID → specs/archive/$OLD_TASK_ID/"
  else
    warn "Old spec has unset task_id (${OLD_TASK_ID}) — archiving skipped"
  fi
fi

# ── Copy and stamp task template ──────────────────────────────
cp "$TASK_TEMPLATE" "$SPEC_DIR/01_task.spec.yaml"
cp "$EXEC_TEMPLATE" "$SPEC_DIR/03_execution.spec.yaml"
cp "$CONV_SOURCE" "$SPEC_DIR/CONVENTIONS.md"

# ── Initialize execution_log.jsonl ────────────────────────────
EXEC_LOG="$SPEC_DIR/execution_log.jsonl"
echo "{\"event\":\"task_created\",\"task_id\":\"${TASK_ID}\",\"size\":\"${SIZE}\",\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}" > "$EXEC_LOG"

# Inject task_id (cross-platform sed)
sed -i.bak "s|task_id: .*|task_id: ${TASK_ID}|g" "$SPEC_DIR/01_task.spec.yaml"
sed -i.bak "s|task_id: .*|task_id: ${TASK_ID}|g" "$SPEC_DIR/03_execution.spec.yaml"

# Clean up backup files
rm -f "$SPEC_DIR/01_task.spec.yaml.bak" \
      "$SPEC_DIR/03_execution.spec.yaml.bak"

# ── Conventions version sync check ───────────────────────────
echo ""
echo "Checking conventions_version sync..."

CONV_VERSION=$(grep 'conventions_version:' "$SPEC_DIR/CONVENTIONS.md" | head -1 | sed 's/.*conventions_version: *"\(.*\)".*/\1/')
CTX_VERSION=$(grep 'conventions_version:' "$SPEC_DIR/02_context.spec.md" | head -1 | sed 's/.*conventions_version: *"\(.*\)".*/\1/')

if [[ -z "$CONV_VERSION" ]]; then
  warn "CONVENTIONS.md has no conventions_version field → treat as stale, escalate before running agent"
elif [[ -z "$CTX_VERSION" ]]; then
  warn "02_context.spec.md has no conventions_version field → fill this in before running agent"
elif [[ "$CONV_VERSION" != "$CTX_VERSION" ]]; then
  warn "conventions_version MISMATCH:"
  warn "  CONVENTIONS.md:    $CONV_VERSION"
  warn "  02_context.spec.md: $CTX_VERSION"
  warn "Update 02_context.spec.md to match CONVENTIONS.md before running agent."
else
  ok "conventions_version in sync: $CONV_VERSION"
fi

# ── TODO marker report ────────────────────────────────────────
echo ""
echo "── TODO markers in policy/conventions files ─────────────────────────"
POLICY_TODOS=$(grep -n "TODO" "$SPEC_DIR/00_policy.spec.md" 2>/dev/null | wc -l | tr -d ' ')
CONV_TODOS=$(grep -n "TODO" "$SPEC_DIR/CONVENTIONS.md" 2>/dev/null | wc -l | tr -d ' ')

if [[ "$POLICY_TODOS" -gt 0 ]]; then
  warn "$POLICY_TODOS TODO markers in 00_policy.spec.md — these indicate a setup error"
fi
if [[ "$CONV_TODOS" -gt 0 ]]; then
  warn "$CONV_TODOS TODO markers in CONVENTIONS.md — these indicate a setup error"
fi
if [[ "$POLICY_TODOS" -eq 0 && "$CONV_TODOS" -eq 0 ]]; then
  ok "No TODO markers in policy or conventions files"
fi

# ── Print next-step instructions ─────────────────────────────
echo ""
ok "Task scaffolded: $TASK_ID ($SIZE)"
echo "    Task spec:    $SPEC_DIR/01_task.spec.yaml"
echo "    Exec spec:    $SPEC_DIR/03_execution.spec.yaml"
echo "    Context:      $SPEC_DIR/02_context.spec.md (NOT yet stamped — run stamp-context.sh)"
echo ""
echo "══════════════════════════════════════════════"
echo "  NEXT STEPS"
echo "══════════════════════════════════════════════"
echo ""
echo "  1. Fill in $SPEC_DIR/01_task.spec.yaml"
echo "     (search for all TODO markers)"
echo ""
echo "  2. Fill in $SPEC_DIR/03_execution.spec.yaml"
echo "     (file_change_plan and steps — this is the agent's execution contract)"
echo ""
echo "  3. Update $SPEC_DIR/02_context.spec.md"
echo "     (relevant files, current behavior, pitfalls)"
echo ""
echo "  4. Verify the context is accurate, then stamp it:"
echo "     → ./stamp-context.sh <your-name>"
echo "     (do NOT skip — validate-task.sh will fail on an un-stamped last_verified)"
echo ""
echo "  5. Run validate-task.sh to confirm no TODO placeholders remain:"
echo "     → ./validate-task.sh"
echo ""

if [[ "$SIZE" == "small" ]]; then
  echo "  6. SIZE = small → autonomy defaults to fully-autonomous"
  echo "     Run Prompt B directly:"
  echo "     → cat $SPEC_DIR/prompts/B_execute.md"
  echo ""
else
  echo "  6. SIZE = $SIZE → run Prompt A first (plan-then-confirm)"
  echo "     → cat $SPEC_DIR/prompts/A_plan.md"
  echo ""
  echo "  7. After human approval, run Prompt B:"
  echo "     → cat $SPEC_DIR/prompts/B_execute.md"
  echo ""
  echo "  8. If session is interrupted:"
  echo "     → cat $SPEC_DIR/prompts/C_resume.md"
fi

echo ""
echo "── TODO markers remaining in new spec files ─────────────────────────"
echo "  01_task.spec.yaml:"
grep -n "TODO" "$SPEC_DIR/01_task.spec.yaml" | sed 's/^/    /' || echo "    (none)"
echo "  03_execution.spec.yaml:"
grep -n "TODO" "$SPEC_DIR/03_execution.spec.yaml" | sed 's/^/    /' || echo "    (none)"
echo "  02_context.spec.md:"
grep -n "TODO\|YYYY-MM-DD\|<your-name>" "$SPEC_DIR/02_context.spec.md" | sed 's/^/    /' || echo "    (none)"
echo ""
