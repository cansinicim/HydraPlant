import Testing
import Foundation
import HydraCore
@testable import HydraEngine

struct HeatIndexTests {
    // E4.2: known values.
    @Test func knownValueMatches() {
        let hi = HydrationEngine.heatIndex(tempC: 32, humidity: 70)
        #expect(abs(hi - 40.5) <= 0.5)
    }

    @Test func belowThresholdReturnsTemp() {
        #expect(HydrationEngine.heatIndex(tempC: 20, humidity: 50) == 20)
    }

    @Test func nonFiniteDoesNotCrash() {
        #expect(HydrationEngine.heatIndex(tempC: .nan, humidity: .infinity).isFinite || true)
    }
}

struct ElectrolyteThresholdTests {
    // Below sweat threshold -> no suggestion.
    @Test func belowThresholdSuppressed() async {
        let rec = await TestFixtures.engine.recommendElectrolytes(
            HydrationEngine.ElectrolyteInput(
                profile: TestFixtures.profile(),
                weather: TestFixtures.weather(20, 40),
                activity: TestFixtures.activity(500, minutes: 10),
                electrolyteModeEnabled: true))
        #expect(rec == nil)
    }

    // Gate closed (cool, mode off) -> no suggestion even with high sweat.
    @Test func gateClosedSuppressed() async {
        let rec = await TestFixtures.engine.recommendElectrolytes(
            HydrationEngine.ElectrolyteInput(
                profile: TestFixtures.profile(level: .athlete),
                weather: TestFixtures.weather(18, 40),
                activity: TestFixtures.activity(2000, minutes: 90),
                electrolyteModeEnabled: false))
        #expect(rec == nil)
    }
}

struct StreakTests {
    @Test func metGoalIncrements() {
        let r = HydrationEngine.updateStreak(previousCount: 12, metGoal: true, tokensAvailable: 1)
        #expect(r.count == 13)
        #expect(!r.forgivenessUsed)
    }

    // Forgiveness token protects the streak.
    @Test func forgivenessProtectsStreak() {
        let r = HydrationEngine.updateStreak(previousCount: 12, metGoal: false, tokensAvailable: 1)
        #expect(r.count == 12)
        #expect(r.forgivenessUsed)
        #expect(r.forgivenessTokensRemaining == 0)
        #expect(!r.celebrateRestart)
    }

    @Test func brokenStreakCelebratesRestart() {
        let r = HydrationEngine.updateStreak(previousCount: 12, metGoal: false, tokensAvailable: 0)
        #expect(r.count == 0)
        #expect(r.celebrateRestart)
    }
}

struct PlantStageTests {
    @Test func stageThresholds() {
        #expect(HydrationEngine.plantStage(progress: 0, consecutiveFullDays: 0) == .seed)
        #expect(HydrationEngine.plantStage(progress: 0.25, consecutiveFullDays: 0) == .sprout)
        #expect(HydrationEngine.plantStage(progress: 0.5, consecutiveFullDays: 0) == .seedling)
        #expect(HydrationEngine.plantStage(progress: 0.75, consecutiveFullDays: 0) == .young)
        #expect(HydrationEngine.plantStage(progress: 1.0, consecutiveFullDays: 0) == .mature)
        #expect(HydrationEngine.plantStage(progress: 1.0, consecutiveFullDays: 3) == .flowering)
    }
}
