#!/usr/bin/env bash
# Reports SAFETY-CRITICAL lines touched in the working tree / staged diff.
# docs/06 §Yorumlar — a PR touching these needs product owner sign-off.
set -uo pipefail
cd "$(dirname "$0")/.."

DIFF=$(git diff --unified=0 HEAD 2>/dev/null; git diff --cached --unified=0 2>/dev/null)
TOUCHED=$(printf '%s\n' "$DIFF" | grep -E '^[+-]' | grep -v '^[+-][+-]' | grep 'SAFETY-CRITICAL' || true)

if [ -n "$TOUCHED" ]; then
  echo "⚠ SAFETY-CRITICAL lines changed. Product owner sign-off required (docs/06):"
  printf '%s\n' "$TOUCHED"
  exit 1
fi
echo "check-safety-comments: no safety-critical lines touched"
exit 0
