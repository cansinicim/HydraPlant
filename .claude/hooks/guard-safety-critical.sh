#!/usr/bin/env bash
# PreToolUse hook. Exit 2 = BLOCK the action.
# This is the only way to get a hard (deterministic) guarantee in Claude Code.
# Writing "don't do this" in CLAUDE.md is NOT enough: the model follows instructions
# most of the time, but may not in long sessions or ambiguous situations.
#
# Protects:
#   1. SAFETY-CRITICAL comment blocks
#   2. Disabling safety tests
#   3. Forbidden third-party SDKs (ADR-002)
#   4. HydraEngine purity (ADR-001)

set -uo pipefail
INPUT=$(cat)

FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
NEW=$(echo "$INPUT"  | jq -r '.tool_input.new_string // .tool_input.content // empty')
OLD=$(echo "$INPUT"  | jq -r '.tool_input.old_string // empty')

block() { echo "$1" >&2; exit 2; }

# 1. Do not touch SAFETY-CRITICAL blocks.
if [ -n "$OLD" ] && printf '%s' "$OLD" | grep -q "SAFETY-CRITICAL"; then
  block "BLOCKED: You are editing a SAFETY-CRITICAL block.
These lines guard against hyponatremia risk (docs/01 §6.6 and §7.4).
Changing them requires an ADR + product owner sign-off.
Ask the user. Do not proceed on your own."
fi

# 2. Do not disable or comment out a safety test.
if printf '%s' "$NEW" | grep -Eq "neverExceedsSafetyCeiling|medicalCautionForcesFixedGoal|doesNotCelebrateOverHydration|sodiumNeverExceedsCeiling"; then
  if printf '%s' "$NEW" | grep -Eq "\.disabled\(|// *@Test|/\* *@Test"; then
    block "BLOCKED: A safety test cannot be disabled or commented out.
These tests are a required CI gate per docs/06."
  fi
fi

# 3. Forbidden SDKs (ADR-002).
if printf '%s' "$NEW" | grep -Eiq "import (Firebase|FirebaseCrashlytics|Sentry|Amplitude|Mixpanel|RevenueCat|AppsFlyer|Adjust|Segment)"; then
  block "BLOCKED: A third-party analytics/crash SDK is being added.
Per ADR-002 no user data goes to any server.
The 'Data Not Collected' privacy label is this product's core marketing asset.
Use MetricKit for crash reporting."
fi

# 4. HydraEngine purity (ADR-001).
case "$FILE" in
  *Packages/HydraEngine/*)
    if printf '%s' "$NEW" | grep -Eq "^\s*import (SwiftUI|HealthKit|WeatherKit|CloudKit|SwiftData|StoreKit|CoreLocation)"; then
      block "BLOCKED: HydraEngine must stay pure (ADR-001).
This package will be ported to Android and must be 100% testable.
Take input as a struct from outside; do not depend on a framework."
    fi
    ;;
esac

exit 0
