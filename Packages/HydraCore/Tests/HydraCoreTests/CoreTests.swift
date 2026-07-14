import Testing
import Foundation
@testable import HydraCore

struct BeverageCatalogTests {
    @Test func catalogHasFourteenBeverages() {
        #expect(Beverage.catalog.count == 14)
    }

    @Test func waterIsNeutralHydration() {
        #expect(Beverage.water.hydrationFactor == 1.00)
        #expect(Beverage.water.id == "water")
    }

    @Test func namedReturnsNilForUnknownID() {
        #expect(Beverage.named("nonexistent") == nil)
        #expect(Beverage.named("coffee")?.caffeineMGPer100ML == 40)
    }

    @Test func activityCoefficientsMatchSpec() {
        #expect(ActivityLevel.sedentary.mlPerKG == 30)
        #expect(ActivityLevel.athlete.mlPerKG == 38)
    }

    @Test func plantStageIsComparable() {
        #expect(PlantStage.seed < PlantStage.flowering)
        #expect(PlantStage.allCases.count == 6)
    }
}
