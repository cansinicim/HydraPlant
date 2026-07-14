import Foundation
import HydraCore

/// The single implementation of the algorithm spec in docs/01 §6 and §7.
///
/// Pure: input struct in, output struct out. No network, no disk, no clock
/// (`Date` is injected). Actor only so the engine may hold internal cache later;
/// purity is preserved by never deriving internal state from input.
public actor HydrationEngine {

    private let now: @Sendable () -> Date

    /// Inject a fixed date in tests.
    public init(now: @escaping @Sendable () -> Date = { Date() }) {
        self.now = now
    }

    // MARK: - Goal

    public struct GoalInput: Sendable, Equatable {
        public let profile: ProfileSnapshot
        public let weather: WeatherSnapshot?      // nil -> weather adjustment 0
        public let activity: ActivitySnapshot?    // nil -> activity adjustment 0
        public let caffeineMG: Double
        public let alcoholUnits: Double

        public init(
            profile: ProfileSnapshot,
            weather: WeatherSnapshot?,
            activity: ActivitySnapshot?,
            caffeineMG: Double,
            alcoholUnits: Double
        ) {
            self.profile = profile
            self.weather = weather
            self.activity = activity
            self.caffeineMG = caffeineMG
            self.alcoholUnits = alcoholUnits
        }
    }

    /// The single implementation of docs/01 §6.
    ///
    /// GUARANTEES (verified by unit tests, violation is a release blocker):
    /// - Returned `finalML` is always in `1600...6000`. (SG-01)
    /// - `profile.hasMedicalCaution == true` -> `finalML == 2000`, reasons == [.medicalCaution]
    /// - Same input always yields same output (deterministic).
    /// - NaN/infinite input coerces to the floor, never crashes.
    public func computeGoal(_ input: GoalInput) -> GoalBreakdown {
        let computedAt = now()

        // SG-03: medical caution short-circuits to a fixed goal.
        if input.profile.hasMedicalCaution {
            return GoalBreakdown(
                baseML: EngineConstants.medicalCautionGoalML,
                weatherML: 0,
                activityML: 0,
                stimulantML: 0,
                finalML: EngineConstants.medicalCautionGoalML,
                reasons: [GoalReason(kind: .medicalCaution, deltaML: 0, localizationKey: "reason.medicalCaution")],
                computedAt: computedAt
            )
        }

        let base = baseNeed(profile: input.profile, at: computedAt)
        let weather = weatherAdjustment(input.weather, base: base)
        let activity = activityAdjustment(input.activity)
        let caffeine = caffeineAdjustment(input.caffeineMG)
        let alcohol = alcoholAdjustment(input.alcoholUnits)
        let stimulant = clamp(caffeine + alcohol, 0, EngineConstants.stimulantMaxML)

        let raw = base + weather + activity + stimulant
        // SAFETY-CRITICAL: docs/01 §6.6 (SG-01) — absolute ceiling and floor.
        let final = clamp(raw, EngineConstants.absoluteFloorML, EngineConstants.absoluteCeilingML)

        var reasons: [GoalReason] = [
            GoalReason(
                kind: .base,
                deltaML: base,
                localizationKey: "reason.base",
                arguments: [
                    "weight": String(Int(finite(input.profile.weightKG).rounded())),
                    "level": input.profile.activityLevel.rawValue
                ]
            )
        ]
        if weather > 0, let key = weatherReasonKey(input.weather) {
            reasons.append(GoalReason(kind: .weather, deltaML: weather, localizationKey: key,
                                      arguments: weatherArguments(input.weather, deltaML: weather)))
        }
        if activity > 0 {
            reasons.append(GoalReason(kind: .activity, deltaML: activity, localizationKey: "reason.activity",
                                      arguments: ["ml": String(Int(activity.rounded()))]))
        }
        if caffeine > 0 {
            reasons.append(GoalReason(kind: .caffeine, deltaML: caffeine, localizationKey: "reason.caffeine",
                                      arguments: ["ml": String(Int(caffeine.rounded()))]))
        }
        if alcohol > 0 {
            reasons.append(GoalReason(kind: .alcohol, deltaML: alcohol, localizationKey: "reason.alcohol",
                                      arguments: ["ml": String(Int(alcohol.rounded()))]))
        }
        if raw > EngineConstants.absoluteCeilingML {
            reasons.append(GoalReason(kind: .safetyCeiling, deltaML: 0, localizationKey: "reason.safetyCeiling"))
        } else if raw < EngineConstants.absoluteFloorML {
            reasons.append(GoalReason(kind: .safetyFloor, deltaML: 0, localizationKey: "reason.safetyFloor"))
        }

        return GoalBreakdown(
            baseML: base,
            weatherML: weather,
            activityML: activity,
            stimulantML: stimulant,
            finalML: final,
            reasons: reasons,
            computedAt: computedAt
        )
    }

    // MARK: - Electrolytes

    public struct ElectrolyteInput: Sendable, Equatable {
        public let profile: ProfileSnapshot
        public let weather: WeatherSnapshot?
        public let activity: ActivitySnapshot?
        public let electrolyteModeEnabled: Bool

        public init(
            profile: ProfileSnapshot,
            weather: WeatherSnapshot?,
            activity: ActivitySnapshot?,
            electrolyteModeEnabled: Bool
        ) {
            self.profile = profile
            self.weather = weather
            self.activity = activity
            self.electrolyteModeEnabled = electrolyteModeEnabled
        }
    }

    /// GUARANTEES:
    /// - `profile.hasMedicalCaution == true` -> always nil. (SG-03)
    /// - Estimated sweat loss < 1200 ml -> nil.
    /// - `sodiumRangeMG.upperBound <= 1500`. (SG-05)
    /// - `potassiumRangeMG.upperBound <= 700`.
    public func recommendElectrolytes(_ input: ElectrolyteInput) -> ElectrolyteRecommendation? {
        // SG-03: never for medically cautious users.
        guard !input.profile.hasMedicalCaution else { return .suppressed }

        let sweat = Self.estimatedSweatLoss(activity: input.activity, weather: input.weather)
        guard sweat >= EngineConstants.sweatThresholdML else { return .suppressed }

        let hi = input.weather.map { Self.heatIndex(tempC: $0.maxTempC, humidity: $0.meanHumidity) } ?? -.infinity
        let gateOpen = input.electrolyteModeEnabled || hi >= EngineConstants.electrolyteHeatIndexGateC
        guard gateOpen else { return .suppressed }

        let sweatL = sweat / 1000
        let sodiumMid = clamp(sweatL * EngineConstants.sodiumMGPerLiter, 0, EngineConstants.sodiumCeilingMG)
        let potassiumMid = clamp(sweatL * EngineConstants.potassiumMGPerLiter, 0, EngineConstants.potassiumCeilingMG)

        return ElectrolyteRecommendation(
            estimatedSweatLossML: sweat,
            sodiumRangeMG: range(mid: sodiumMid, ceiling: EngineConstants.sodiumCeilingMG),
            potassiumRangeMG: range(mid: potassiumMid, ceiling: EngineConstants.potassiumCeilingMG)
        )
    }

    // MARK: - Helpers (public: UI shows them in the "why" card)

    /// Rothfusz regression. Returns `tempC` for `tempC < 26.7`.
    /// SPEC: docs/01 §6.2.
    public nonisolated static func heatIndex(tempC: Double, humidity: Double) -> Double {
        let t = finite(tempC, or: -100)
        let r = clamp(humidity, 0, 100)
        guard t >= 26.7 else { return t }
        let tf = t * 9 / 5 + 32
        var hi = -42.379 + 2.04901523 * tf + 10.14333127 * r
            - 0.22475541 * tf * r - 0.00683783 * tf * tf
            - 0.05481717 * r * r + 0.00122874 * tf * tf * r
            + 0.00085282 * tf * r * r - 0.00000199 * tf * tf * r * r
        if r < 13 && tf >= 80 && tf <= 112 {
            hi -= ((13 - r) / 4) * ((17 - abs(tf - 95)) / 17).squareRoot()
        }
        return (hi - 32) * 5 / 9
    }

    /// SPEC: docs/01 §7.2.
    public nonisolated static func estimatedSweatLoss(
        activity: ActivitySnapshot?, weather: WeatherSnapshot?
    ) -> Milliliters {
        let kcal = finite(activity?.activeEnergyKcal ?? 0)
        let minutes = finite(activity?.workoutMinutes ?? 0)
        let hi = weather.map { heatIndex(tempC: $0.maxTempC, humidity: $0.meanHumidity) } ?? 0
        let heatAbove27 = Swift.max(0, hi - EngineConstants.sweatHeatBaselineC)
        let loss = kcal * EngineConstants.mlPerKcal + heatAbove27 * minutes * EngineConstants.sweatHeatFactor
        return Swift.max(0, loss)
    }

    // SPEC: docs/01 §8.3.
    public nonisolated static func updateStreak(
        previousCount: Int, metGoal: Bool, tokensAvailable: Int
    ) -> StreakResult {
        if metGoal {
            return StreakResult(count: previousCount + 1, forgivenessUsed: false,
                                forgivenessTokensRemaining: tokensAvailable, celebrateRestart: false)
        }
        if tokensAvailable > 0 {
            return StreakResult(count: previousCount, forgivenessUsed: true,
                                forgivenessTokensRemaining: tokensAvailable - 1, celebrateRestart: false)
        }
        return StreakResult(count: 0, forgivenessUsed: false,
                            forgivenessTokensRemaining: 0, celebrateRestart: true)
    }

    // SPEC: docs/01 §8.2.
    public nonisolated static func plantStage(progress: Double, consecutiveFullDays: Int) -> PlantStage {
        let p = finite(progress)
        if p >= 1.0 && consecutiveFullDays >= 3 { return .flowering }
        if p >= 1.0 { return .mature }
        if p >= 0.70 { return .young }
        if p >= 0.45 { return .seedling }
        if p >= 0.20 { return .sprout }
        return .seed
    }

    // MARK: - Private math

    private func baseNeed(profile: ProfileSnapshot, at date: Date) -> Milliliters {
        let raw = finite(profile.weightKG) * profile.activityLevel.mlPerKG
        let age = Calendar(identifier: .gregorian).component(.year, from: date) - profile.birthYear
        let aged = age > EngineConstants.elderlyAgeThreshold ? raw * EngineConstants.elderlyMultiplier : raw
        return clamp(aged, EngineConstants.baseFloorML, EngineConstants.baseCeilingML)
    }

    private func weatherAdjustment(_ weather: WeatherSnapshot?, base: Milliliters) -> Milliliters {
        guard let weather else { return 0 }
        let hi = Self.heatIndex(tempC: weather.maxTempC, humidity: weather.meanHumidity)
        let raw = weatherTier(hi)
        return Swift.min(raw, base * EngineConstants.weatherCapFraction)
    }

    // SPEC: docs/01 §6.2 — tiered heat adjustment.
    private func weatherTier(_ hi: Double) -> Milliliters {
        switch hi {
        case ..<24:      0
        case ..<27:      150
        case ..<32:      350
        case ..<39:      600
        case ..<51:      900
        default:         1100
        }
    }

    private func weatherReasonKey(_ weather: WeatherSnapshot?) -> String? {
        guard let weather else { return nil }
        let hi = Self.heatIndex(tempC: weather.maxTempC, humidity: weather.meanHumidity)
        switch hi {
        case ..<24:  return nil
        case ..<27:  return "reason.weather.mild"
        case ..<32:  return "reason.weather.hot"
        case ..<39:  return "reason.weather.veryHot"
        default:     return "reason.weather.extreme"
        }
    }

    private func weatherArguments(_ weather: WeatherSnapshot?, deltaML: Milliliters) -> [String: String] {
        var args = ["ml": String(Int(deltaML.rounded()))]
        if let weather {
            let hi = Self.heatIndex(tempC: weather.maxTempC, humidity: weather.meanHumidity)
            args["tempC"] = String(Int(hi.rounded()))
        }
        return args
    }

    private func activityAdjustment(_ activity: ActivitySnapshot?) -> Milliliters {
        guard let activity else { return 0 }
        let raw = finite(activity.activeEnergyKcal) * EngineConstants.mlPerKcal
        return clamp(raw, 0, EngineConstants.activityMaxML)
    }

    // SPEC: docs/01 §6.4 — only caffeine above 300 mg; hydration factor handles the rest.
    private func caffeineAdjustment(_ caffeineMG: Double) -> Milliliters {
        let c = finite(caffeineMG)
        return Swift.max(0, c - EngineConstants.caffeineThresholdMG) * EngineConstants.caffeineMLPerMG
    }

    private func alcoholAdjustment(_ alcoholUnits: Double) -> Milliliters {
        Swift.max(0, finite(alcoholUnits)) * EngineConstants.alcoholMLPerUnit
    }

    private func range(mid: Double, ceiling: Double) -> ClosedRange<Double> {
        let lower = Swift.max(0, mid * (1 - EngineConstants.rangeSpread))
        let upper = Swift.min(mid * (1 + EngineConstants.rangeSpread), ceiling)
        return lower...Swift.max(lower, upper)
    }
}
