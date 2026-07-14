import Testing
import Foundation
import HydraCore
@testable import HydraEngine

/// SAFETY-CRITICAL suite. These tests cannot be disabled. docs/01 §13.2, §7.4.
/// CI enforces them as a required gate (docs/06, docs/14).
struct SafetyTests {

    // SG-01: absolute ceiling and floor under 10k random inputs.
    @Test func neverExceedsSafetyCeiling() async {
        let engine = TestFixtures.engine
        var rng = SystemRandomNumberGenerator()
        for _ in 0..<10_000 {
            let input = Self.randomInput(&rng)
            let result = await engine.computeGoal(input)
            #expect(result.finalML <= 6000)
            #expect(result.finalML >= 1600)
        }
    }

    // SG-03: medical caution forces a fixed 2000 ml goal.
    @Test func medicalCautionForcesFixedGoal() async {
        let result = await TestFixtures.engine.computeGoal(
            HydrationEngine.GoalInput(
                profile: TestFixtures.profile(weightKG: 90, level: .athlete, medical: true),
                weather: TestFixtures.weather(45, 90),
                activity: TestFixtures.activity(3000),
                caffeineMG: 400, alcoholUnits: 2))
        #expect(result.finalML == 2000)
        #expect(result.reasons == [GoalReason(kind: .medicalCaution, deltaML: 0, localizationKey: "reason.medicalCaution")])
    }

    // NaN/infinite input coerces to the floor and never crashes.
    @Test func handlesCorruptedInput() async {
        let result = await TestFixtures.engine.computeGoal(TestFixtures.nanInput)
        #expect(result.finalML.isFinite)
        #expect(result.finalML >= 1600 && result.finalML <= 6000)
    }

    // Same input yields same output.
    @Test func isDeterministic() async {
        let engine = TestFixtures.engine
        let a = await engine.computeGoal(TestFixtures.marathonRunner)
        let b = await engine.computeGoal(TestFixtures.marathonRunner)
        #expect(a == b)
    }

    // SG-05: sodium suggestion upper bound never exceeds 1500 mg.
    @Test func sodiumNeverExceedsCeiling() async {
        let rec = await TestFixtures.engine.recommendElectrolytes(
            HydrationEngine.ElectrolyteInput(
                profile: TestFixtures.profile(level: .athlete),
                weather: TestFixtures.weather(40, 60),
                activity: TestFixtures.activity(5000, minutes: 120),
                electrolyteModeEnabled: true))
        let unwrapped = try! #require(rec)
        #expect(unwrapped.sodiumRangeMG.upperBound <= 1500)
        #expect(unwrapped.potassiumRangeMG.upperBound <= 700)
    }

    static func randomInput(_ rng: inout SystemRandomNumberGenerator) -> HydrationEngine.GoalInput {
        let levels = ActivityLevel.allCases
        let profile = ProfileSnapshot(
            weightKG: Double.random(in: -50...900, using: &rng),
            birthYear: Int.random(in: 1900...2020, using: &rng),
            biologicalSex: .unspecified,
            activityLevel: levels.randomElement(using: &rng)!,
            hasMedicalCaution: Bool.random(using: &rng))
        let weather = Bool.random(using: &rng) ? WeatherSnapshot(
            maxTempC: Double.random(in: -60...70, using: &rng),
            meanHumidity: Double.random(in: 0...100, using: &rng),
            observedAt: TestFixtures.fixedDate, isStale: false) : nil
        let activity = Bool.random(using: &rng) ? ActivitySnapshot(
            activeEnergyKcal: Double.random(in: -100...8000, using: &rng),
            workoutMinutes: Double.random(in: 0...400, using: &rng),
            observedAt: TestFixtures.fixedDate) : nil
        return HydrationEngine.GoalInput(
            profile: profile, weather: weather, activity: activity,
            caffeineMG: Double.random(in: -100...2000, using: &rng),
            alcoholUnits: Double.random(in: 0...20, using: &rng))
    }
}
