#!/usr/bin/env bash
# ============================================================
# hooks/install.sh — Install git hooks for agent-spec enforcement
# Usage: ./hooks/install.sh
# ============================================================

set -euo pipefail

HOOKS_DIR="$(dirname "$0")"
GIT_HOOKS_DIR="$(git rev-parse --show-toplevel)/.git/hooks"

RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

if [[ ! -d "$GIT_HOOKS_DIR" ]]; then
  echo -e "${RED}❌  Not a git repo or .git/hooks not found.${NC}"
  exit 1
fi

# Install pre-commit hook (conventions version sync)
cp "$HOOKS_DIR/check-conventions-version.sh" "$GIT_HOOKS_DIR/pre-commit"
chmod +x "$GIT_HOOKS_DIR/pre-commit"
echo -e "${GREEN}✅  Installed: .git/hooks/pre-commit (conventions version sync)${NC}"

# Install pre-push hook (TODO field scan)
cp "$HOOKS_DIR/check-todo-fields.sh" "$GIT_HOOKS_DIR/pre-push"
chmod +x "$GIT_HOOKS_DIR/pre-push"
echo -e "${GREEN}✅  Installed: .git/hooks/pre-push (TODO field scan)${NC}"

echo ""
echo "Hooks installed. They will run automatically on commit and push."
echo "To bypass in an emergency: git commit --no-verify"
