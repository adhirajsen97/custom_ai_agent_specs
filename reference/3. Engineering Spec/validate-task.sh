#!/usr/bin/env bash
# ============================================================
# validate-task.sh — Pre-flight spec validation
# Usage: ./validate-task.sh [--strict]
#
# Run this before handing any spec to an agent.
# Fails with a non-zero exit code if:
#   - Any required spec file is missing
#   - Any required field contains an unresolved placeholder
#   - conventions_version is out of sync
#   - 02_context.spec.md is stale (>14 days)
#   - 03_execution.spec.yaml is missing
#
# --strict mode: also warns on optional fields that are still TODO
#
# Exit codes:
#   0 — all checks pass, safe to run agent
#   1 — blocking issues found, do not run agent
# ============================================================

set -euo pipefail

SPEC_DIR="$(dirname "$0")/agent-specs"
STRICT="${1:-}"
TODAY=$(date +%Y-%m-%d)
ERRORS=0
WARNINGS=0

# ── Colour helpers ────────────────────────────────────────────
RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'; BOLD='\033[1m'; NC='\033[0m'
ok()    { echo -e "  ${GREEN}✅  $*${NC}"; }
fail()  { echo -e "  ${RED}❌  $*${NC}"; ((ERRORS++)); }
warn()  { echo -e "  ${YELLOW}⚠️   $*${NC}"; ((WARNINGS++)); }
header(){ echo -e "\n${BOLD}── $* ──────────────────────────────────────────────${NC}"; }

# ── Helper: check file exists ─────────────────────────────────
require_file() {
  local path="$1" label="$2"
  if [[ ! -f "$path" ]]; then
    fail "MISSING: $label → $path"
    return 1
  fi
  return 0
}

# ── Helper: scan file for placeholder patterns ────────────────
scan_placeholders() {
  local file="$1" label="$2"
  local in_block_scalar=0

  # Check for TODO markers in value position (not in comments)
  while IFS= read -r line; do
    # Skip comment lines (lines starting with optional whitespace then #)
    if echo "$line" | grep -qE '^\s*#'; then
      in_block_scalar=0
      continue
    fi

    # Detect YAML block scalar openers (key: | or key: >)
    if echo "$line" | grep -qE ':\s*[|>][+-]?\s*$'; then
      in_block_scalar=1
      continue
    fi

    # A non-indented non-empty line ends any active block scalar
    if [[ $in_block_scalar -eq 1 ]] && echo "$line" | grep -qE '^[^[:space:]]'; then
      in_block_scalar=0
    fi

    # Inside a block scalar: flag any TODO in the indented content
    if [[ $in_block_scalar -eq 1 ]]; then
      if echo "$line" | grep -qE 'TODO'; then
        fail "Unresolved TODO in $label (block scalar): $line"
      fi
      continue
    fi

    # Flag lines where a YAML value is or begins with TODO
    # Broader pattern: catches `: TODO`, `: TODO:`, `: TODO fill this in`, etc.
    if echo "$line" | grep -qE ':\s+"?TODO'; then
      fail "Unresolved TODO in $label: $line"
    fi
    # Flag un-stamped dates
    if echo "$line" | grep -qE ':\s+YYYY-MM-DD'; then
      fail "Un-stamped date in $label: $line"
    fi
    # Flag angle-bracket placeholders in values
    if echo "$line" | grep -qE ':\s+<[^>]+>'; then
      fail "Angle-bracket placeholder in $label: $line"
    fi
  done < "$file"
  # Errors are tracked via fail() which increments ERRORS — no return value needed
}

# ── Helper: returns 0 (true) if path matches an auto-risk-trigger pattern ────
is_risk_trigger_path() {
  local p="$1"
  local base="${p##*/}"
  # auth
  [[ "$p" == *auth/* || "$p" == auth/* || "$base" == *Auth* || "$base" == *auth* ]] && return 0
  # migrations
  [[ "$p" == *migrations/* || "$p" == db/migrations/* ]] && return 0
  # env / secrets
  [[ "$base" == .env* || "$base" == *.env || "$p" == *secrets/* ]] && return 0
  # middleware
  [[ "$p" == *middleware/* ]] && return 0
  # core shared libs
  [[ "$base" == errors.ts || "$base" == result.ts || "$base" == logger.ts ]] && return 0
  # toolchain config
  [[ "$base" == tsconfig*.json || "$base" == .eslintrc* || "$base" == .prettierrc* ]] && return 0
  # dependency manifests
  [[ "$base" == package.json || "$base" == package-lock.json || "$base" == yarn.lock ]] && return 0
  # db / schema / migration filenames
  [[ "$base" == *.sql || "$p" == *schema* || "$p" == *migration* ]] && return 0
  # gateway / router / entry points
  [[ "$p" == *gateway* || "$p" == *router* || "$base" == index.ts ]] && return 0
  return 1
}

echo ""
echo -e "${BOLD}validate-task.sh — Pre-flight spec validation${NC}"
echo -e "${BOLD}Spec directory: $SPEC_DIR${NC}"
echo ""

# ═══════════════════════════════════════════════════════════════
# CHECK 1: Required files exist
# ═══════════════════════════════════════════════════════════════
header "Required Files"

require_file "$SPEC_DIR/00_policy.spec.md"    "00_policy.spec.md"    && ok "00_policy.spec.md"
require_file "$SPEC_DIR/01_task.spec.yaml"    "01_task.spec.yaml"    && ok "01_task.spec.yaml"
require_file "$SPEC_DIR/02_context.spec.md"   "02_context.spec.md"   && ok "02_context.spec.md"
require_file "$SPEC_DIR/03_execution.spec.yaml" "03_execution.spec.yaml" && ok "03_execution.spec.yaml"
require_file "$SPEC_DIR/04_verify_and_handoff.spec.md" "04_verify_and_handoff.spec.md" && ok "04_verify_and_handoff.spec.md"
require_file "$SPEC_DIR/CONVENTIONS.md"       "CONVENTIONS.md"       && ok "CONVENTIONS.md"

# ═══════════════════════════════════════════════════════════════
# CHECK 2: Placeholder scan — required spec files
# ═══════════════════════════════════════════════════════════════
header "Placeholder Scan"

if [[ -f "$SPEC_DIR/01_task.spec.yaml" ]]; then
  ERRORS_BEFORE=$ERRORS
  scan_placeholders "$SPEC_DIR/01_task.spec.yaml" "01_task.spec.yaml"
  [[ $ERRORS -eq $ERRORS_BEFORE ]] && ok "01_task.spec.yaml — no unresolved placeholders"
fi

if [[ -f "$SPEC_DIR/02_context.spec.md" ]]; then
  ERRORS_BEFORE=$ERRORS
  scan_placeholders "$SPEC_DIR/02_context.spec.md" "02_context.spec.md"
  [[ $ERRORS -eq $ERRORS_BEFORE ]] && ok "02_context.spec.md — no unresolved placeholders"
fi

if [[ -f "$SPEC_DIR/03_execution.spec.yaml" ]]; then
  ERRORS_BEFORE=$ERRORS
  scan_placeholders "$SPEC_DIR/03_execution.spec.yaml" "03_execution.spec.yaml"
  [[ $ERRORS -eq $ERRORS_BEFORE ]] && ok "03_execution.spec.yaml — no unresolved placeholders"
fi

# ═══════════════════════════════════════════════════════════════
# CHECK 3: conventions_version sync
# ═══════════════════════════════════════════════════════════════
header "Conventions Version Sync"

if [[ -f "$SPEC_DIR/CONVENTIONS.md" && -f "$SPEC_DIR/02_context.spec.md" ]]; then
  CONV_VERSION=$(grep 'conventions_version:' "$SPEC_DIR/CONVENTIONS.md" | head -1 \
    | sed 's/.*conventions_version: *"\(.*\)".*/\1/' | tr -d ' ')
  CTX_VERSION=$(grep 'conventions_version:' "$SPEC_DIR/02_context.spec.md" | head -1 \
    | sed 's/.*conventions_version: *"\(.*\)".*/\1/' | tr -d ' ')

  if [[ -z "$CONV_VERSION" ]]; then
    fail "CONVENTIONS.md has no conventions_version field"
  elif [[ -z "$CTX_VERSION" ]]; then
    fail "02_context.spec.md has no conventions_version field"
  elif [[ "$CONV_VERSION" != "$CTX_VERSION" ]]; then
    fail "conventions_version MISMATCH: CONVENTIONS.md=$CONV_VERSION, 02_context.spec.md=$CTX_VERSION"
  else
    ok "conventions_version in sync: $CONV_VERSION"
  fi
fi

# ═══════════════════════════════════════════════════════════════
# CHECK 4: Context freshness (02_context.spec.md last_verified)
# ═══════════════════════════════════════════════════════════════
header "Context Freshness"

if [[ -f "$SPEC_DIR/02_context.spec.md" ]]; then
  LAST_VERIFIED=$(grep 'last_verified:' "$SPEC_DIR/02_context.spec.md" | head -1 \
    | sed 's/.*last_verified: *\([0-9-]*\).*/\1/' | tr -d ' ')

  if [[ -z "$LAST_VERIFIED" || "$LAST_VERIFIED" == "YYYY-MM-DD" ]]; then
    fail "02_context.spec.md:last_verified is not stamped (verify context then run stamp-context.sh)"
  else
    # Calculate days since last_verified (macOS and Linux compatible)
    if command -v python3 &>/dev/null; then
      DAYS_AGO=$(python3 -c "
from datetime import date
verified = date.fromisoformat('$LAST_VERIFIED')
today = date.fromisoformat('$TODAY')
print((today - verified).days)
" 2>/dev/null || echo "unknown")
    else
      DAYS_AGO="unknown"
    fi

    if [[ "$DAYS_AGO" == "unknown" ]]; then
      warn "Could not calculate context age — verify manually that last_verified ($LAST_VERIFIED) is within 14 days"
    elif [[ "$DAYS_AGO" -gt 14 ]]; then
      fail "02_context.spec.md is STALE: last_verified=$LAST_VERIFIED (${DAYS_AGO} days ago, limit: 14)"
    else
      ok "Context is fresh: last_verified=$LAST_VERIFIED (${DAYS_AGO} days ago)"
    fi
  fi
fi

# ═══════════════════════════════════════════════════════════════
# CHECK 5: task_id consistency across spec files
# ═══════════════════════════════════════════════════════════════
header "Task ID Consistency"

if [[ -f "$SPEC_DIR/01_task.spec.yaml" && -f "$SPEC_DIR/03_execution.spec.yaml" ]]; then
  TASK_ID_01=$(grep 'task_id:' "$SPEC_DIR/01_task.spec.yaml" | head -1 | sed 's/.*task_id: *//' | tr -d ' "')
  TASK_ID_03=$(grep 'task_id:' "$SPEC_DIR/03_execution.spec.yaml" | head -1 | sed 's/.*task_id: *//' | tr -d ' "')

  if echo "$TASK_ID_01" | grep -qE 'TODO|YYYY'; then
    fail "01_task.spec.yaml:task_id is not set: $TASK_ID_01"
  elif echo "$TASK_ID_03" | grep -qE 'TODO|YYYY'; then
    fail "03_execution.spec.yaml:task_id is not set: $TASK_ID_03"
  elif [[ "$TASK_ID_01" != "$TASK_ID_03" ]]; then
    fail "task_id MISMATCH: 01_task=$TASK_ID_01, 03_execution=$TASK_ID_03"
  else
    ok "task_id consistent: $TASK_ID_01"
  fi
fi

# ═══════════════════════════════════════════════════════════════
# CHECK 6: file_change_plan — verify modify/delete paths exist
# ═══════════════════════════════════════════════════════════════
header "File Change Plan Path Existence"

if [[ -f "$SPEC_DIR/03_execution.spec.yaml" ]]; then
  REPO_ROOT="$(dirname "$SPEC_DIR")"
  FCP_IN_PLAN=0
  FCP_PATH=""
  FCP_FOUND_ANY=0

  while IFS= read -r fcp_line; do
    # Enter file_change_plan block
    if echo "$fcp_line" | grep -qE '^file_change_plan:'; then
      FCP_IN_PLAN=1
      FCP_PATH=""
      continue
    fi
    # Exit on any other top-level (non-indented, non-empty) key
    if [[ $FCP_IN_PLAN -eq 1 ]] && echo "$fcp_line" | grep -qE '^[a-zA-Z_][a-zA-Z0-9_]*:'; then
      FCP_IN_PLAN=0
      FCP_PATH=""
    fi

    if [[ $FCP_IN_PLAN -eq 1 ]]; then
      # Capture path value
      if echo "$fcp_line" | grep -qE '^\s+path:\s+'; then
        FCP_PATH=$(echo "$fcp_line" | sed "s/.*path:[[:space:]]*//" | tr -d '"' | tr -d "'" | sed 's/[[:space:]]*$//')
      fi
      # On action line: check existence for modify/delete entries
      if echo "$fcp_line" | grep -qE '^\s+action:\s+' && [[ -n "$FCP_PATH" ]]; then
        FCP_ACTION=$(echo "$fcp_line" | sed "s/.*action:[[:space:]]*//" | tr -d '"' | tr -d "'" | tr -d ' ')
        FCP_FOUND_ANY=1
        if [[ "$FCP_ACTION" == "modify" || "$FCP_ACTION" == "delete" ]]; then
          if [[ ! -f "$REPO_ROOT/$FCP_PATH" ]]; then
            fail "file_change_plan '$FCP_PATH' (action: $FCP_ACTION) does not exist at $REPO_ROOT/$FCP_PATH"
          else
            ok "file_change_plan: $FCP_PATH exists"
          fi
        elif [[ "$FCP_ACTION" == "create" ]]; then
          ok "file_change_plan: $FCP_PATH (create — existence not required)"
        fi
        FCP_PATH=""
      fi
    fi
  done < "$SPEC_DIR/03_execution.spec.yaml"

  if [[ $FCP_FOUND_ANY -eq 0 ]]; then
    warn "No file_change_plan entries found in 03_execution.spec.yaml — verify it is filled in"
  fi
fi

# ═══════════════════════════════════════════════════════════════
# CHECK 7: risk_level + blast_radius coherence
# ═══════════════════════════════════════════════════════════════
header "Risk Coherence"

if [[ -f "$SPEC_DIR/01_task.spec.yaml" ]]; then
  RISK=$(grep 'risk_level:' "$SPEC_DIR/01_task.spec.yaml" | head -1 | sed 's/.*risk_level: *//' | tr -d ' "')
  BLAST=$(grep 'blast_radius:' "$SPEC_DIR/01_task.spec.yaml" | head -1 | sed 's/.*blast_radius: *//' | tr -d ' "')
  AUTONOMY=$(grep '^autonomy:' "$SPEC_DIR/01_task.spec.yaml" | head -1 | sed 's/.*autonomy: *//' | tr -d ' "')
  # Exclude comment lines to avoid false positives from commented-out example blocks
  OVERRIDE=$(grep -v '^\s*#' "$SPEC_DIR/01_task.spec.yaml" \
    | grep 'risk_override:' \
    | grep -v 'risk_override_reason\|risk_override_approved_by\|risk_override_date' \
    | head -1 | sed 's/.*risk_override: *//' | tr -d ' "')

  if [[ "$RISK" == "high" && "$AUTONOMY" != "human-in-loop" && "$OVERRIDE" != "justified" ]]; then
    fail "risk_level=high but autonomy=$AUTONOMY — must be human-in-loop (or declare risk_override: justified)"
  else
    ok "Risk coherence: risk_level=$RISK, blast_radius=$BLAST, autonomy=$AUTONOMY"
  fi

  if [[ "$BLAST" == "core" && "$AUTONOMY" == "fully-autonomous" && "$OVERRIDE" != "justified" ]]; then
    fail "blast_radius=core with fully-autonomous autonomy — must be plan-then-confirm or human-in-loop"
  fi

  # If risk_override is declared, all three companion fields are required
  if [[ "$OVERRIDE" == "justified" ]]; then
    OVERRIDE_BY=$(grep -v '^\s*#' "$SPEC_DIR/01_task.spec.yaml" \
      | grep 'risk_override_approved_by:' | head -1 \
      | sed 's/.*risk_override_approved_by: *//' | tr -d ' "')
    OVERRIDE_DATE=$(grep -v '^\s*#' "$SPEC_DIR/01_task.spec.yaml" \
      | grep 'risk_override_date:' | head -1 \
      | sed 's/.*risk_override_date: *//' | tr -d ' "')
    if [[ -z "$OVERRIDE_BY" ]] || echo "$OVERRIDE_BY" | grep -qE 'TODO|<'; then
      fail "risk_override: justified requires risk_override_approved_by to be set (not TODO)"
    else
      ok "risk_override_approved_by: $OVERRIDE_BY"
    fi
    if [[ -z "$OVERRIDE_DATE" ]] || echo "$OVERRIDE_DATE" | grep -qE 'TODO|YYYY'; then
      fail "risk_override: justified requires risk_override_date to be set (not YYYY-MM-DD)"
    else
      ok "risk_override_date: $OVERRIDE_DATE"
    fi
  fi
fi

# ═══════════════════════════════════════════════════════════════
# CHECK 8: Security reviewer gate + npm audit gate
# ═══════════════════════════════════════════════════════════════
header "Security Reviewer Gate"

if [[ -f "$SPEC_DIR/01_task.spec.yaml" && -f "$SPEC_DIR/03_execution.spec.yaml" ]]; then
  # Read security_reviewer (exclude comment lines)
  SEC_REVIEWER=$(grep -v '^\s*#' "$SPEC_DIR/01_task.spec.yaml" \
    | grep 'security_reviewer:' | head -1 \
    | sed 's/.*security_reviewer: *//' | tr -d ' "')

  # Scan file_change_plan paths for risk-trigger matches
  TRIGGER_PATHS=()
  HAS_DEP_MANIFEST=0
  SEC_IN_PLAN=0
  SEC_PATH=""

  while IFS= read -r sec_line; do
    if echo "$sec_line" | grep -qE '^file_change_plan:'; then
      SEC_IN_PLAN=1; SEC_PATH=""; continue
    fi
    if [[ $SEC_IN_PLAN -eq 1 ]] && echo "$sec_line" | grep -qE '^[a-zA-Z_][a-zA-Z0-9_]*:'; then
      SEC_IN_PLAN=0; SEC_PATH=""
    fi
    if [[ $SEC_IN_PLAN -eq 1 ]]; then
      if echo "$sec_line" | grep -qE '^\s+path:\s+'; then
        SEC_PATH=$(echo "$sec_line" | sed "s/.*path:[[:space:]]*//" | tr -d '"' | tr -d "'" | sed 's/[[:space:]]*$//')
        SEC_BASE="${SEC_PATH##*/}"
        # Track dependency manifest presence for npm audit check
        if [[ "$SEC_BASE" == "package.json" || "$SEC_BASE" == "package-lock.json" || "$SEC_BASE" == "yarn.lock" ]]; then
          HAS_DEP_MANIFEST=1
        fi
        if is_risk_trigger_path "$SEC_PATH"; then
          TRIGGER_PATHS+=("$SEC_PATH")
        fi
      fi
    fi
  done < "$SPEC_DIR/03_execution.spec.yaml"

  # Enforce security reviewer when risk-trigger paths are present
  if [[ ${#TRIGGER_PATHS[@]} -gt 0 ]]; then
    if [[ -z "$SEC_REVIEWER" ]]; then
      fail "Risk-trigger path(s) detected — security_reviewer must be set in 01_task.spec.yaml"
      for tp in "${TRIGGER_PATHS[@]}"; do
        fail "  Trigger path: $tp"
      done
    else
      ok "Security reviewer: $SEC_REVIEWER (covers ${#TRIGGER_PATHS[@]} trigger path(s))"
      for tp in "${TRIGGER_PATHS[@]}"; do
        ok "  Trigger path covered: $tp"
      done
    fi
  else
    ok "No risk-trigger paths in file_change_plan — security_reviewer not required"
  fi

  # Enforce npm audit check when dependency manifests are in file_change_plan
  if [[ $HAS_DEP_MANIFEST -eq 1 ]]; then
    if grep -q 'npm audit' "$SPEC_DIR/03_execution.spec.yaml" 2>/dev/null; then
      ok "npm audit check present (dependency manifest in file_change_plan)"
    else
      fail "Dependency manifest (package.json/yarn.lock) in file_change_plan but no 'npm audit --audit-level=high' check found in 03_execution.spec.yaml"
    fi
  fi
fi

# ═══════════════════════════════════════════════════════════════
# CHECK 9: acceptance_criteria — test_names present for each criterion
# ═══════════════════════════════════════════════════════════════
header "Acceptance Criteria — test_names"

if [[ -f "$SPEC_DIR/01_task.spec.yaml" ]]; then
  AC_IN_BLOCK=0
  AC_HAS_TEST_NAMES=0
  AC_CRITERION_COUNT=0
  AC_MISSING_COUNT=0

  while IFS= read -r ac_line; do
    # Skip comment lines
    echo "$ac_line" | grep -qE '^\s*#' && continue

    # Enter acceptance_criteria block
    if echo "$ac_line" | grep -qE '^acceptance_criteria:'; then
      AC_IN_BLOCK=1
      continue
    fi

    # Exit on any other top-level key
    if [[ $AC_IN_BLOCK -eq 1 ]] && echo "$ac_line" | grep -qE '^[a-zA-Z_][a-zA-Z0-9_]*:'; then
      # Check last criterion before leaving block
      if [[ $AC_CRITERION_COUNT -gt 0 && $AC_HAS_TEST_NAMES -eq 0 ]]; then
        fail "acceptance_criteria item #$AC_CRITERION_COUNT is missing test_names"
        ((AC_MISSING_COUNT++))
      fi
      AC_IN_BLOCK=0
    fi

    if [[ $AC_IN_BLOCK -eq 1 ]]; then
      # New criterion item (starts with "  - criterion:")
      if echo "$ac_line" | grep -qE '^\s+-\s+criterion:'; then
        # Check previous criterion had test_names
        if [[ $AC_CRITERION_COUNT -gt 0 && $AC_HAS_TEST_NAMES -eq 0 ]]; then
          fail "acceptance_criteria item #$AC_CRITERION_COUNT is missing test_names"
          ((AC_MISSING_COUNT++))
        fi
        ((AC_CRITERION_COUNT++))
        AC_HAS_TEST_NAMES=0
      fi
      # Detect test_names key
      if echo "$ac_line" | grep -qE '^\s+test_names:'; then
        AC_HAS_TEST_NAMES=1
      fi
    fi
  done < "$SPEC_DIR/01_task.spec.yaml"

  # Check last criterion after EOF
  if [[ $AC_IN_BLOCK -eq 1 && $AC_CRITERION_COUNT -gt 0 && $AC_HAS_TEST_NAMES -eq 0 ]]; then
    fail "acceptance_criteria item #$AC_CRITERION_COUNT is missing test_names"
    ((AC_MISSING_COUNT++))
  fi

  if [[ $AC_CRITERION_COUNT -eq 0 ]]; then
    warn "No structured acceptance_criteria items found — ensure criteria use 'criterion:' + 'test_names:' format"
  elif [[ $AC_MISSING_COUNT -eq 0 ]]; then
    ok "All $AC_CRITERION_COUNT acceptance criteria have test_names"
  fi
fi

# ═══════════════════════════════════════════════════════════════
# CHECK 10: depends_on_tasks — verify dependencies are archived
# ═══════════════════════════════════════════════════════════════
header "Cross-Task Dependencies"

if [[ -f "$SPEC_DIR/01_task.spec.yaml" ]]; then
  ARCHIVE_ROOT="$(dirname "$SPEC_DIR")/specs/archive"
  DEP_IN_BLOCK=0
  DEP_COUNT=0
  DEP_MISSING=0

  while IFS= read -r dep_line; do
    # Skip comments
    echo "$dep_line" | grep -qE '^\s*#' && continue

    # Enter depends_on_tasks block
    if echo "$dep_line" | grep -qE '^depends_on_tasks:'; then
      # Check for inline empty array: depends_on_tasks: []
      if echo "$dep_line" | grep -qE '\[\]'; then
        break  # no dependencies
      fi
      DEP_IN_BLOCK=1
      continue
    fi

    # Exit on any other top-level key
    if [[ $DEP_IN_BLOCK -eq 1 ]] && echo "$dep_line" | grep -qE '^[a-zA-Z_][a-zA-Z0-9_]*:'; then
      DEP_IN_BLOCK=0
    fi

    if [[ $DEP_IN_BLOCK -eq 1 ]]; then
      # Parse list items (  - "T-20260220-add-types")
      if echo "$dep_line" | grep -qE '^\s+-\s+'; then
        DEP_TASK_ID=$(echo "$dep_line" | sed 's/^\s*-\s*//' | tr -d '"' | tr -d "'" | sed 's/[[:space:]]*$//' | sed 's/#.*//' | tr -d '[:space:]')
        if [[ -n "$DEP_TASK_ID" ]]; then
          ((DEP_COUNT++))
          if [[ -d "$ARCHIVE_ROOT/$DEP_TASK_ID" ]]; then
            ok "Dependency $DEP_TASK_ID has archived handoff"
          else
            fail "Dependency $DEP_TASK_ID has no archived handoff at $ARCHIVE_ROOT/$DEP_TASK_ID"
            ((DEP_MISSING++))
          fi
        fi
      fi
    fi
  done < "$SPEC_DIR/01_task.spec.yaml"

  if [[ $DEP_COUNT -eq 0 ]]; then
    ok "No cross-task dependencies declared"
  elif [[ $DEP_MISSING -gt 0 ]]; then
    fail "$DEP_MISSING of $DEP_COUNT declared dependencies are not archived — complete them first"
  fi
fi

# ═══════════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════════
echo ""
echo "════════════════════════════════════════════════"
if [[ $ERRORS -gt 0 ]]; then
  echo -e "${RED}${BOLD}  RESULT: BLOCKED — $ERRORS error(s) found${NC}"
  echo -e "${RED}  Do not run the agent until all errors are resolved.${NC}"
  echo "════════════════════════════════════════════════"
  exit 1
elif [[ $WARNINGS -gt 0 ]]; then
  echo -e "${YELLOW}${BOLD}  RESULT: PASS WITH WARNINGS — $WARNINGS warning(s)${NC}"
  echo -e "${YELLOW}  Review warnings before running the agent.${NC}"
  echo "════════════════════════════════════════════════"
  exit 0
else
  echo -e "${GREEN}${BOLD}  RESULT: PASS — all checks clean${NC}"
  echo -e "${GREEN}  Safe to run agent.${NC}"
  echo "════════════════════════════════════════════════"
  exit 0
fi
