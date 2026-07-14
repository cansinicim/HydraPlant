#!/usr/bin/env bash
# PostToolUse hook. After a file write: format + quick feedback.
# Always exit 0: no blocking here, only fixing and warnings.
set -uo pipefail
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

case "$FILE" in
  *.swift) ;;
  *) exit 0 ;;
esac

command -v swift-format >/dev/null 2>&1 && swift-format format --in-place "$FILE" 2>/dev/null || true
command -v swiftlint >/dev/null 2>&1 && swiftlint lint --quiet --path "$FILE" || true

case "$FILE" in
  *HydraEngine*)
    echo "HydraEngine changed, running safety tests..."
    swift test --package-path Packages/HydraEngine --filter Safety 2>&1 | tail -5 || true
    ;;
esac

exit 0
