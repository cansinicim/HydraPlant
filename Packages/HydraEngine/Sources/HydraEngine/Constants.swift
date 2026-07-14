import Foundation
import HydraCore

/// Engine constants. Every value carries a SPEC: reference to docs/01.
/// Safety limits carry SAFETY-CRITICAL and must not be changed without an ADR.
enum EngineConstants {

    // MARK: Base need

    // SPEC: docs/01 §6.1 — base clamp bounds ml.
    static let baseFloorML: Milliliters = 1600
    static let baseCeilingML: Milliliters = 4000

    // SPEC: docs/01 §6.1 — over 65 years old ×0.95 (thirst drops, kidney load rises).
    static let elderlyAgeThreshold = 65
    static let elderlyMultiplier = 0.95

    // MARK: Weather

    // SPEC: docs/01 §6.2 — heat adjustment cannot exceed base × 0.35.
    static let weatherCapFraction = 0.35

    // MARK: Activity

    // SPEC: docs/01 §6.3 — 1.2 ml/kcal; ~1 L/hour sweat and ~600 kcal/hour active burn.
    static let mlPerKcal = 1.2
    // SPEC: docs/01 §6.3 — activity clamp.
    static let activityMaxML: Milliliters = 1500

    // MARK: Stimulant

    // SPEC: docs/01 §6.4 — only caffeine above 300 mg counts; no double penalty.
    static let caffeineThresholdMG = 300.0
    static let caffeineMLPerMG = 1.0
    // SPEC: docs/01 §6.4 — 120 ml per alcohol unit.
    static let alcoholMLPerUnit = 120.0
    // SPEC: docs/01 §6.4 — caffeine + alcohol clamp.
    static let stimulantMaxML: Milliliters = 800

    // MARK: Absolute safety limits

    // SAFETY-CRITICAL: docs/01 §6.6 & §7.4 (SG-01) — final goal ceiling.
    // Overhydration can cause hyponatremia, fatal in athletes. A broken sensor or a
    // bad weight input must never push the user to a harmful goal.
    // Removing or raising this requires an ADR + product owner sign-off.
    static let absoluteCeilingML: Milliliters = 6000

    // SAFETY-CRITICAL: docs/01 §6.5 — absolute floor.
    static let absoluteFloorML: Milliliters = 1600

    // SAFETY-CRITICAL: docs/01 §7.4 (SG-03) — medical caution fixed goal.
    static let medicalCautionGoalML: Milliliters = 2000

    // MARK: Electrolytes

    // SPEC: docs/01 §7.1 — electrolyte suggestion threshold.
    static let sweatThresholdML: Milliliters = 1200
    // SPEC: docs/01 §7.1 — heat-index gate for electrolyte suggestion.
    static let electrolyteHeatIndexGateC = 32.0
    // SPEC: docs/01 §7.3 — sodium mg per liter of sweat.
    static let sodiumMGPerLiter = 800.0
    // SAFETY-CRITICAL: docs/01 §7.4 (SG-05) — sodium suggestion never exceeds 1500 mg.
    static let sodiumCeilingMG = 1500.0
    // SPEC: docs/01 §7.3 — potassium mg per liter of sweat.
    static let potassiumMGPerLiter = 200.0
    static let potassiumCeilingMG = 700.0
    // SPEC: docs/01 §7.3 — suggestion shown as ±30% range.
    static let rangeSpread = 0.30
    // SPEC: docs/01 §7.2 — sweat estimate heat term factor.
    static let sweatHeatFactor = 3.5
    static let sweatHeatBaselineC = 27.0
}

/// Clamps `value` into `low...high`. Non-finite input coerces to `low`.
@inline(__always)
func clamp(_ value: Double, _ low: Double, _ high: Double) -> Double {
    guard value.isFinite else { return low }
    return Swift.min(Swift.max(value, low), high)
}

/// Returns a finite value or the fallback for NaN/infinite input.
@inline(__always)
func finite(_ value: Double, or fallback: Double = 0) -> Double {
    value.isFinite ? value : fallback
}
