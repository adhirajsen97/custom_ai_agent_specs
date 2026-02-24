#!/usr/bin/env bash
# ============================================================
# stamp-context.sh — Stamp last_verified in 02_context.spec.md
# Usage: ./stamp-context.sh <your-name>
#
# Run this AFTER you have personally verified that
# 02_context.spec.md accurately reflects the current codebase.
#
# Do NOT run this automatically or as part of a script.
# The whole point is a human attesting to accuracy.
# ============================================================

set -euo pipefail

SPEC_DIR="$(dirname "$0")/agent-specs"
TODAY=$(date +%Y-%m-%d)
REVIEWER="${1:-}"

RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✅  $*${NC}"; }
warn() { echo -e "${YELLOW}⚠️   $*${NC}"; }
err()  { echo -e "${RED}❌  $*${NC}"; }

if [[ ! -f "$SPEC_DIR/02_context.spec.md" ]]; then
  err "02_context.spec.md not found at $SPEC_DIR/02_context.spec.md"
  err "Run new-task.sh first to scaffold the spec files."
  exit 1
fi

# Stamp last_verified
sed -i.bak "s|last_verified: .*|last_verified: ${TODAY}|g" "$SPEC_DIR/02_context.spec.md"
rm -f "$SPEC_DIR/02_context.spec.md.bak"
ok "Stamped: last_verified = ${TODAY}"

# Stamp verified_by if reviewer name provided
if [[ -n "$REVIEWER" ]]; then
  sed -i.bak "s|verified_by: .*|verified_by: ${REVIEWER}|g" "$SPEC_DIR/02_context.spec.md"
  rm -f "$SPEC_DIR/02_context.spec.md.bak"
  ok "Stamped: verified_by = ${REVIEWER}"
else
  warn "No reviewer name given — verified_by field still contains a placeholder"
  warn "Re-run with your name:  ./stamp-context.sh <your-name>"
fi

echo ""
echo "Context stamped. Run validate-task.sh to confirm all checks pass:"
echo "  → ./validate-task.sh"
