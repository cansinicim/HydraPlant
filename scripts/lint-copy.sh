#!/usr/bin/env bash
# Scans Swift + xcstrings for banned user-facing words. docs/07 §Ses tonu.
# Banned: fail, missed, forgot, only, just. Suppress a legit hit with // copy-lint:allow
set -uo pipefail
cd "$(dirname "$0")/.."

BANNED='fail|failed|missed|forgot|forget|only|just'
FOUND=0

# Only scan user-facing string literals and the string catalog.
FILES=$(find Features Packages Widgets Watch App -name "*.swift" 2>/dev/null; find . -name "*.xcstrings" 2>/dev/null)
[ -z "$FILES" ] && { echo "lint-copy: no source files yet"; exit 0; }

while IFS= read -r file; do
  [ -f "$file" ] || continue
  while IFS=: read -r lineno line; do
    [ -z "$lineno" ] && continue
    printf '%s' "$line" | grep -q 'copy-lint:allow' && continue
    # Heuristic: only flag words inside quotes (user-facing copy).
    if printf '%s' "$line" | grep -qiE "\"[^\"]*\b($BANNED)\b[^\"]*\""; then
      echo "$file:$lineno: banned copy word -> $line"
      FOUND=1
    fi
  done < <(grep -inE "\b($BANNED)\b" "$file" 2>/dev/null)
done <<< "$FILES"

[ "$FOUND" -eq 0 ] && echo "lint-copy: OK"
# Warning-only in CI per docs/07; do not fail the gate.
exit 0
