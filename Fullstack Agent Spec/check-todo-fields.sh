#!/usr/bin/env bash
# ============================================================
# hooks/check-todo-fields.sh
# Pre-push hook: fails if any agent spec file contains
# unresolved TODO markers, un-stamped dates, or angle-bracket placeholders
#
# Install: copy to .git/hooks/pre-push and chmod +x
# Bypass: git push --no-verify (emergency only)
# ============================================================

set -euo pipefail

SPEC_DIR="agent-specs"
ERRORS=0

check_file() {
  local file="$1"
  [[ ! -f "$file" ]] && return 0

  while IFS= read -r line; do
    lineno=$((lineno + 1))
    # Skip comment-only lines
    if echo "$line" | grep -qE '^\s*#'; then continue; fi

    # TODO in value position
    if echo "$line" | grep -qE ':\s+"?TODO[:"< ]|:\s+TODO$'; then
      echo "❌  Unresolved TODO in $file:$lineno"
      echo "    $line"
      ERRORS=$((ERRORS + 1))
    fi

    # Un-stamped date
    if echo "$line" | grep -qE ':\s+YYYY-MM-DD\b'; then
      echo "❌  Un-stamped date in $file:$lineno"
      echo "    $line"
      ERRORS=$((ERRORS + 1))
    fi

    # Angle-bracket placeholder in value
    if echo "$line" | grep -qE ':\s+<[a-zA-Z][^>]*>'; then
      echo "❌  Placeholder in $file:$lineno"
      echo "    $line"
      ERRORS=$((ERRORS + 1))
    fi
  done < "$file"
}

# Only check the active task spec files (not templates)
for f in \
  "$SPEC_DIR/01_task.spec.yaml" \
  "$SPEC_DIR/02_context.spec.md" \
  "$SPEC_DIR/03_execution.spec.yaml"; do
  lineno=0
  check_file "$f"
done

if [[ $ERRORS -gt 0 ]]; then
  echo ""
  echo "❌  PUSH BLOCKED: $ERRORS unresolved placeholder(s) found in spec files."
  echo "    Fill in all TODO markers before pushing to a shared branch."
  echo "    Bypass (emergency only): git push --no-verify"
  exit 1
fi

exit 0
