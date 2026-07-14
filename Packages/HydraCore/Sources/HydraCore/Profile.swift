import Foundation

public enum ActivityLevel: String, Sendable, Codable, CaseIterable {
    case sedentary, light, moderate, active, athlete

    /// SPEC: docs/01 §6.1 — base need coefficient ml/kg.
    public var mlPerKG: Double {
        switch self {
        case .sedentary: 30
        case .light:     32
        case .moderate:  33
        case .active:    35
        case .athlete:   38
        }
    }
}

public enum ClimateProfile: String, Sendable, Codable, CaseIterable {
    case cold, temperate, hot, extremeHeat
}

public enum BiologicalSex: String, Sendable, Codable {
    case female, male, unspecified
}

/// Frozen profile snapshot handed to the engine.
public struct ProfileSnapshot: Sendable, Codable, Equatable {
    public let weightKG: Double
    public let birthYear: Int
    public let biologicalSex: BiologicalSex
    public let activityLevel: ActivityLevel
    /// If `true`, engine returns fixed 2000 ml, no electrolytes. (SG-03)
    public let hasMedicalCaution: Bool

    public init(
        weightKG: Double,
        birthYear: Int,
        biologicalSex: BiologicalSex,
        activityLevel: ActivityLevel,
        hasMedicalCaution: Bool
    ) {
        self.weightKG = weightKG
        self.birthYear = birthYear
        self.biologicalSex = biologicalSex
        self.activityLevel = activityLevel
        self.hasMedicalCaution = hasMedicalCaution
    }
}

public struct WeatherSnapshot: Sendable, Codable, Equatable {
    public let maxTempC: Double
    public let meanHumidity: Double        // 0 ... 100
    public let observedAt: Date
    public let isStale: Bool               // > 6 hours old

    public init(maxTempC: Double, meanHumidity: Double, observedAt: Date, isStale: Bool) {
        self.maxTempC = maxTempC
        self.meanHumidity = meanHumidity
        self.observedAt = observedAt
        self.isStale = isStale
    }
}

public struct ActivitySnapshot: Sendable, Codable, Equatable {
    public let activeEnergyKcal: Double
    public let workoutMinutes: Double
    public let observedAt: Date

    public init(activeEnergyKcal: Double, workoutMinutes: Double, observedAt: Date) {
        self.activeEnergyKcal = activeEnergyKcal
        self.workoutMinutes = workoutMinutes
        self.observedAt = observedAt
    }
}
