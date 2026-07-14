#!/usr/bin/env bash
# Enforces the dependency rules in docs/02 §Zorunlu kısıtlar.
# HydraEngine must stay pure (ADR-001); HydraUI must not touch data/service frameworks.
set -uo pipefail
cd "$(dirname "$0")/.."
FAIL=0

check() {
  local pkg="$1" pattern="$2"
  local dir="Packages/$pkg/Sources"
  [ -d "$dir" ] || return 0
  local hits
  hits=$(grep -rnE "^\s*import ($pattern)" "$dir" 2>/dev/null)
  if [ -n "$hits" ]; then
    echo "FORBIDDEN import in $pkg:" >&2
    echo "$hits" >&2
    FAIL=1
  fi
}

# HydraEngine: only HydraCore + Foundation allowed.
check HydraEngine "SwiftUI|HealthKit|WeatherKit|CloudKit|SwiftData|StoreKit|CoreLocation"
# HydraUI: design system, no data/service frameworks.
check HydraUI "HealthKit|WeatherKit|SwiftData|StoreKit"
# HydraCore: pure, nothing but Foundation.
check HydraCore "SwiftUI|HealthKit|WeatherKit|CloudKit|SwiftData|StoreKit|CoreLocation|UIKit"

[ "$FAIL" -eq 0 ] && echo "verify-imports: OK"
exit $FAIL
