import Foundation

public struct Beverage: Sendable, Codable, Equatable, Identifiable, Hashable {
    public let id: String                 // "water", "coffee", ...
    public let hydrationFactor: Double     // 0.0 ... 1.15
    public let caffeineMGPer100ML: Double
    public let alcoholUnitsPer100ML: Double
    public let symbolName: String          // SF Symbol

    public init(
        id: String,
        hydrationFactor: Double,
        caffeineMGPer100ML: Double,
        alcoholUnitsPer100ML: Double,
        symbolName: String
    ) {
        self.id = id
        self.hydrationFactor = hydrationFactor
        self.caffeineMGPer100ML = caffeineMGPer100ML
        self.alcoholUnitsPer100ML = alcoholUnitsPer100ML
        self.symbolName = symbolName
    }

    /// The full catalog. Not in the database, in code. Stable across versions.
    /// SPEC: docs/01 §5.2 — Beverage catalog, hydration factors from Beverage Hydration Index.
    public static let catalog: [Beverage] = [
        Beverage(id: "water",       hydrationFactor: 1.00, caffeineMGPer100ML:   0, alcoholUnitsPer100ML: 0.0,  symbolName: "drop.fill"),
        Beverage(id: "sparkling",   hydrationFactor: 1.00, caffeineMGPer100ML:   0, alcoholUnitsPer100ML: 0.0,  symbolName: "bubbles.and.sparkles"),
        Beverage(id: "coffee",      hydrationFactor: 0.85, caffeineMGPer100ML:  40, alcoholUnitsPer100ML: 0.0,  symbolName: "cup.and.saucer.fill"),
        Beverage(id: "espresso",    hydrationFactor: 0.80, caffeineMGPer100ML: 210, alcoholUnitsPer100ML: 0.0,  symbolName: "cup.and.saucer.fill"),
        Beverage(id: "tea_black",   hydrationFactor: 0.90, caffeineMGPer100ML:  20, alcoholUnitsPer100ML: 0.0,  symbolName: "mug.fill"),
        Beverage(id: "tea_green",   hydrationFactor: 0.92, caffeineMGPer100ML:  12, alcoholUnitsPer100ML: 0.0,  symbolName: "mug.fill"),
        Beverage(id: "soda",        hydrationFactor: 0.85, caffeineMGPer100ML:  10, alcoholUnitsPer100ML: 0.0,  symbolName: "takeoutbag.and.cup.and.straw.fill"),
        Beverage(id: "energy",      hydrationFactor: 0.80, caffeineMGPer100ML:  32, alcoholUnitsPer100ML: 0.0,  symbolName: "bolt.fill"),
        Beverage(id: "juice",       hydrationFactor: 0.95, caffeineMGPer100ML:   0, alcoholUnitsPer100ML: 0.0,  symbolName: "waterbottle.fill"),
        Beverage(id: "milk",        hydrationFactor: 1.10, caffeineMGPer100ML:   0, alcoholUnitsPer100ML: 0.0,  symbolName: "carton.fill"),
        Beverage(id: "electrolyte", hydrationFactor: 1.15, caffeineMGPer100ML:   0, alcoholUnitsPer100ML: 0.0,  symbolName: "bolt.heart.fill"),
        Beverage(id: "beer",        hydrationFactor: 0.60, caffeineMGPer100ML:   0, alcoholUnitsPer100ML: 0.28, symbolName: "mug.fill"),
        Beverage(id: "wine",        hydrationFactor: 0.30, caffeineMGPer100ML:   0, alcoholUnitsPer100ML: 0.40, symbolName: "wineglass.fill"),
        Beverage(id: "spirits",     hydrationFactor: 0.00, caffeineMGPer100ML:   0, alcoholUnitsPer100ML: 0.80, symbolName: "wineglass.fill")
    ]

    /// Unknown id returns nil.
    public static func named(_ id: String) -> Beverage? {
        catalog.first { $0.id == id }
    }

    public static let water: Beverage = catalog[0]
}

public enum EntrySource: String, Sendable, Codable, CaseIterable {
    case manual, widget, watch, liveActivity, siri, healthKitImport
}
