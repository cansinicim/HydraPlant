import Foundation
import HydraCore
@testable import HydraEngine

/// Named, meaningful test data. docs/06 §Test kuralları.
enum TestFixtures {
    static let fixedDate = Date(timeIntervalSince1970: 1_780_000_000) // ~2026

    static func profile(
        weightKG: Double = 70,
        birthYear: Int = 1990,
        sex: BiologicalSex = .unspecified,
        level: ActivityLevel = .moderate,
        medical: Bool = false
    ) -> ProfileSnapshot {
        ProfileSnapshot(weightKG: weightKG, birthYear: birthYear, biologicalSex: sex,
                        activityLevel: level, hasMedicalCaution: medical)
    }

    static func weather(_ tempC: Double, _ humidity: Double) -> WeatherSnapshot {
        WeatherSnapshot(maxTempC: tempC, meanHumidity: humidity, observedAt: fixedDate, isStale: false)
    }

    static func activity(_ kcal: Double, minutes: Double = 42) -> ActivitySnapshot {
        ActivitySnapshot(activeEnergyKcal: kcal, workoutMinutes: minutes, observedAt: fixedDate)
    }

    static var engine: HydrationEngine { HydrationEngine(now: { fixedDate }) }

    // Named scenarios
    static let seattleDeskWorker = HydrationEngine.GoalInput(
        profile: profile(weightKG: 70, level: .sedentary),
        weather: weather(20, 50), activity: activity(0, minutes: 0),
        caffeineMG: 0, alcoholUnits: 0)

    static let phoenixConstructionWorker = HydrationEngine.GoalInput(
        profile: profile(weightKG: 85, level: .active),
        weather: weather(43, 20), activity: activity(900),
        caffeineMG: 0, alcoholUnits: 0)

    static let marathonRunner = HydrationEngine.GoalInput(
        profile: profile(weightKG: 60, level: .athlete),
        weather: weather(38, 80), activity: activity(3000, minutes: 180),
        caffeineMG: 400, alcoholUnits: 0)

    static let corruptedWeightInput = HydrationEngine.GoalInput(
        profile: profile(weightKG: 700, level: .athlete),
        weather: weather(45, 90), activity: activity(5000),
        caffeineMG: 900, alcoholUnits: 0)

    static let negativeInput = HydrationEngine.GoalInput(
        profile: profile(weightKG: 0, level: .sedentary),
        weather: weather(-40, 0), activity: activity(-100, minutes: 0),
        caffeineMG: -50, alcoholUnits: 0)

    static let nanInput = HydrationEngine.GoalInput(
        profile: profile(weightKG: .nan, level: .athlete),
        weather: weather(.infinity, .nan), activity: activity(.nan),
        caffeineMG: .nan, alcoholUnits: .infinity)
}
