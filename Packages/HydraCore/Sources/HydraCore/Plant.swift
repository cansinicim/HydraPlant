import Foundation

public enum PlantStage: Int, Sendable, Codable, CaseIterable, Comparable {
    case seed = 0, sprout, seedling, young, mature, flowering
    public static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }
}

public struct PlantSpecies: Sendable, Codable, Equatable, Identifiable {
    public let id: String                  // "aloe", "monstera", ...
    public let isPro: Bool
    public let unlockCondition: UnlockCondition

    public enum UnlockCondition: Sendable, Codable, Equatable {
        case free
        case pro
        case proAndStreak(days: Int)       // orchid: 30
        case proAndSeason(months: ClosedRange<Int>)  // sunflower: 6...8
    }

    public init(id: String, isPro: Bool, unlockCondition: UnlockCondition) {
        self.id = id
        self.isPro = isPro
        self.unlockCondition = unlockCondition
    }

    /// SPEC: docs/01 §8.4 — plant species catalog.
    public static let catalog: [PlantSpecies] = [
        PlantSpecies(id: "aloe",      isPro: false, unlockCondition: .free),
        PlantSpecies(id: "basil",     isPro: false, unlockCondition: .free),
        PlantSpecies(id: "monstera",  isPro: true,  unlockCondition: .pro),
        PlantSpecies(id: "cactus",    isPro: true,  unlockCondition: .pro),
        PlantSpecies(id: "lavender",  isPro: true,  unlockCondition: .pro),
        PlantSpecies(id: "bonsai",    isPro: true,  unlockCondition: .pro),
        PlantSpecies(id: "orchid",    isPro: true,  unlockCondition: .proAndStreak(days: 30)),
        PlantSpecies(id: "sunflower", isPro: true,  unlockCondition: .proAndSeason(months: 6...8))
    ]
}
