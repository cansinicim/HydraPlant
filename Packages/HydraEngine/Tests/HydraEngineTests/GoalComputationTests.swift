import Testing
import Foundation
import HydraCore
@testable import HydraEngine

/// Table-driven tests. These tables are also the spec for the Android port. docs/01 §13.2.
struct GoalComputationTests {

    struct Case: Sendable {
        let name: String
        let input: HydrationEngine.GoalInput
        let expected: ClosedRange<Double>
    }

    static let cases: [Case] = [
        Case(name: "Desk worker, mild, no caffeine",
             input: TestFixtures.seattleDeskWorker, expected: 2100...2100),
        Case(name: "Phoenix construction worker, 43C",
             input: TestFixtures.phoenixConstructionWorker, expected: 4900...5100),
        Case(name: "Marathon runner, extreme values",
             input: TestFixtures.marathonRunner, expected: 4600...4900),
        Case(name: "SAFETY: broken weight input 700 kg",
             input: TestFixtures.corruptedWeightInput, expected: 6000...6000),
        Case(name: "SAFETY: negative/zero inputs",
             input: TestFixtures.negativeInput, expected: 1600...1600)
    ]

    @Test(arguments: cases)
    func computesWithinExpectedRange(_ c: Case) async {
        let result = await TestFixtures.engine.computeGoal(c.input)
        #expect(c.expected.contains(result.finalML),
                "\(c.name): \(result.finalML) not in \(c.expected)")
    }

    @Test func computesBaseGoalForSedentaryAdult() async {
        let result = await TestFixtures.engine.computeGoal(
            HydrationEngine.GoalInput(profile: TestFixtures.profile(weightKG: 70, level: .sedentary),
                                      weather: nil, activity: nil, caffeineMG: 0, alcoholUnits: 0))
        #expect(result.baseML == 2100)
        #expect(result.finalML == 2100)
    }

    @Test func elderlyGetsReducedBase() async {
        let engine = TestFixtures.engine
        let young = await engine.computeGoal(
            HydrationEngine.GoalInput(profile: TestFixtures.profile(weightKG: 90, birthYear: 1990, level: .sedentary),
                                      weather: nil, activity: nil, caffeineMG: 0, alcoholUnits: 0))
        let old = await engine.computeGoal(
            HydrationEngine.GoalInput(profile: TestFixtures.profile(weightKG: 90, birthYear: 1940, level: .sedentary),
                                      weather: nil, activity: nil, caffeineMG: 0, alcoholUnits: 0))
        #expect(old.baseML < young.baseML)
    }

    @Test func caffeineUnder300HasNoPenalty() async {
        let result = await TestFixtures.engine.computeGoal(
            HydrationEngine.GoalInput(profile: TestFixtures.profile(level: .sedentary),
                                      weather: nil, activity: nil, caffeineMG: 250, alcoholUnits: 0))
        #expect(result.stimulantML == 0)
    }

    @Test func caffeineOver300AddsPenalty() async {
        let result = await TestFixtures.engine.computeGoal(
            HydrationEngine.GoalInput(profile: TestFixtures.profile(level: .sedentary),
                                      weather: nil, activity: nil, caffeineMG: 400, alcoholUnits: 0))
        #expect(result.stimulantML == 100)
    }

    @Test func goalBreakdownReasonsIncludeBase() async {
        let result = await TestFixtures.engine.computeGoal(TestFixtures.phoenixConstructionWorker)
        #expect(result.reasons.contains { $0.kind == .base })
        #expect(result.reasons.contains { $0.kind == .weather })
        #expect(result.reasons.contains { $0.kind == .activity })
    }
}
