#!/usr/bin/env bash
# ============================================================
# hooks/check-conventions-version.sh
# Pre-commit hook: fails if CONVENTIONS.md:conventions_version
# does not match 02_context.spec.md:conventions_version
#
# Install: copy to .git/hooks/pre-commit and chmod +x
# Bypass: git commit --no-verify (emergency only)
# ============================================================

set -euo pipefail

SPEC_DIR="agent-specs"
CONVENTIONS="$SPEC_DIR/CONVENTIONS.md"
CONTEXT="$SPEC_DIR/02_context.spec.md"

# Only run if both files are tracked/modified in this commit
if [[ ! -f "$CONVENTIONS" || ! -f "$CONTEXT" ]]; then
  exit 0  # files don't exist, not applicable
fi

CONV_VERSION=$(grep 'conventions_version:' "$CONVENTIONS" | head -1 \
  | sed 's/.*conventions_version: *"\(.*\)".*/\1/' | tr -d ' ')
CTX_VERSION=$(grep 'conventions_version:' "$CONTEXT" | head -1 \
  | sed 's/.*conventions_version: *"\(.*\)".*/\1/' | tr -d ' ')

# Check for un-stamped conventions_version
if [[ -z "$CONV_VERSION" ]]; then
  echo "❌  COMMIT BLOCKED: CONVENTIONS.md has no conventions_version field"
  echo "    Add: conventions_version: \"x.x.x\""
  exit 1
fi

if [[ -z "$CTX_VERSION" ]]; then
  echo "❌  COMMIT BLOCKED: 02_context.spec.md has no conventions_version field"
  echo "    Add: conventions_version: \"$CONV_VERSION\""
  exit 1
fi

if [[ "$CONV_VERSION" != "$CTX_VERSION" ]]; then
  echo "❌  COMMIT BLOCKED: conventions_version mismatch"
  echo "    CONVENTIONS.md:     $CONV_VERSION"
  echo "    02_context.spec.md: $CTX_VERSION"
  echo ""
  echo "    Fix: update 02_context.spec.md:conventions_version to \"$CONV_VERSION\""
  exit 1
fi

exit 0
