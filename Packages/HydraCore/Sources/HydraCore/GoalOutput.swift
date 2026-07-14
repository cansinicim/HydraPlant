import Foundation

/// A single reason explaining why the goal is this number.
/// UI shows these directly; text comes from docs/07-metin-katalogu.md.
public struct GoalReason: Sendable, Equatable, Identifiable {
    public enum Kind: String, Sendable, Codable {
        case base, weather, activity, caffeine, alcohol, medicalCaution, safetyCeiling, safetyFloor
    }
    public let id: UUID
    public let kind: Kind
    public let deltaML: Milliliters        // positive or negative
    /// Key the UI uses to find localized text. Engine produces no text.
    public let localizationKey: String
    /// Values to embed into the text. e.g. ["tempC": "38"]
    public let arguments: [String: String]

    public init(
        id: UUID = UUID(),
        kind: Kind,
        deltaML: Milliliters,
        localizationKey: String,
        arguments: [String: String] = [:]
    ) {
        self.id = id
        self.kind = kind
        self.deltaML = deltaML
        self.localizationKey = localizationKey
        self.arguments = arguments
    }

    // Equatable ignores the random id so results stay comparable in tests.
    public static func == (lhs: GoalReason, rhs: GoalReason) -> Bool {
        lhs.kind == rhs.kind
            && lhs.deltaML == rhs.deltaML
            && lhs.localizationKey == rhs.localizationKey
            && lhs.arguments == rhs.arguments
    }
}

public struct GoalBreakdown: Sendable, Equatable {
    public let baseML: Milliliters
    public let weatherML: Milliliters
    public let activityML: Milliliters
    public let stimulantML: Milliliters    // caffeine + alcohol
    public let finalML: Milliliters
    public let reasons: [GoalReason]
    public let computedAt: Date

    public init(
        baseML: Milliliters,
        weatherML: Milliliters,
        activityML: Milliliters,
        stimulantML: Milliliters,
        finalML: Milliliters,
        reasons: [GoalReason],
        computedAt: Date
    ) {
        self.baseML = baseML
        self.weatherML = weatherML
        self.activityML = activityML
        self.stimulantML = stimulantML
        self.finalML = finalML
        self.reasons = reasons
        self.computedAt = computedAt
    }

    /// `true` if the safety ceiling/floor kicked in. UI may show extra info.
    public var wasClamped: Bool {
        reasons.contains { $0.kind == .safetyCeiling || $0.kind == .safetyFloor }
    }
}

public struct ElectrolyteRecommendation: Sendable, Equatable {
    public let estimatedSweatLossML: Milliliters
    public let sodiumRangeMG: ClosedRange<Double>
    public let potassiumRangeMG: ClosedRange<Double>

    public init(
        estimatedSweatLossML: Milliliters,
        sodiumRangeMG: ClosedRange<Double>,
        potassiumRangeMG: ClosedRange<Double>
    ) {
        self.estimatedSweatLossML = estimatedSweatLossML
        self.sodiumRangeMG = sodiumRangeMG
        self.potassiumRangeMG = potassiumRangeMG
    }

    /// `nil` means no suggestion is shown (below threshold or SG-03 gate).
    public static let suppressed: ElectrolyteRecommendation? = nil
}

public struct StreakResult: Sendable, Equatable {
    public let count: Int
    public let forgivenessUsed: Bool
    public let forgivenessTokensRemaining: Int
    public let celebrateRestart: Bool

    public init(count: Int, forgivenessUsed: Bool, forgivenessTokensRemaining: Int, celebrateRestart: Bool) {
        self.count = count
        self.forgivenessUsed = forgivenessUsed
        self.forgivenessTokensRemaining = forgivenessTokensRemaining
        self.celebrateRestart = celebrateRestart
    }
}
