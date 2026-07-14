#!/usr/bin/env bash
# Single-command gate: import check + copy lint + swiftlint + pure-package tests.
# docs/06 §CI/CD, docs/08 PROMPT 1 (item 4).
set -uo pipefail
cd "$(dirname "$0")/.."
FAIL=0

echo "== verify-imports =="
./scripts/verify-imports.sh || FAIL=1

echo "== lint-copy =="
./scripts/lint-copy.sh || FAIL=1

if command -v swiftlint >/dev/null 2>&1; then
  echo "== swiftlint =="
  swiftlint lint --quiet --strict || FAIL=1
else
  echo "swiftlint not installed, skipping (brew install swiftlint)"
fi

# swift-testing lives in the Xcode/CLT developer frameworks. On a CLT-only host
# SwiftPM does not add them automatically, so we pass the paths explicitly.
DEV_FW="$(xcode-select -p)/Library/Developer/Frameworks"
DEV_LIB="$(xcode-select -p)/Library/Developer/usr/lib"
TEST_ARGS=()
if [ -d "$DEV_FW" ] && [ -f "$DEV_LIB/lib_TestingInterop.dylib" ]; then
  export DYLD_FRAMEWORK_PATH="$DEV_FW"
  export DYLD_LIBRARY_PATH="$DEV_LIB"
  TEST_ARGS=(-Xswiftc -F -Xswiftc "$DEV_FW"
             -Xlinker -rpath -Xlinker "$DEV_FW"
             -Xlinker -rpath -Xlinker "$DEV_LIB")
fi

# Only pure packages build without the iOS SDK. iOS-bound packages are verified in Xcode.
for pkg in HydraCore HydraEngine; do
  echo "== swift test: $pkg =="
  swift test --package-path "Packages/$pkg" "${TEST_ARGS[@]}" 2>&1 \
    | grep -E "Suite .* (passed|failed)|Test run|error:|failed after" || true
  [ "${PIPESTATUS[0]}" -eq 0 ] || FAIL=1
done

if [ "$FAIL" -eq 0 ]; then
  echo "verify: GREEN"
else
  echo "verify: RED" >&2
fi
exit $FAIL
