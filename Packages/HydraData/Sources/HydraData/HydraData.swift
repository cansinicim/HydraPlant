// HydraData — persistence, repositories, sync status. See docs/02 §3.
//
// SKELETON. This package depends on the iOS SDK (SwiftData) and does not build
// on a Command Line Tools-only host. Implement + test on a full Xcode machine.
// The public contract below is authoritative (docs/02 §3).

import Foundation
import HydraCore

// MARK: - DTOs (@Model classes never cross this boundary — docs/02 §Kritik kural)

public struct HydrationEntryDTO: Sendable, Identifiable, Equatable {
    public let id: UUID
    public let timestamp: Date
    public let volumeML: Milliliters
    public let effectiveML: Milliliters
    public let beverage: Beverage
    public let source: EntrySource

    public init(id: UUID, timestamp: Date, volumeML: Milliliters,
                effectiveML: Milliliters, beverage: Beverage, source: EntrySource) {
        self.id = id; self.timestamp = timestamp; self.volumeML = volumeML
        self.effectiveML = effectiveML; self.beverage = beverage; self.source = source
    }
}

public struct DailyLogDTO: Sendable, Identifiable, Equatable {
    public let id: UUID
    public let date: Date
    public let goal: GoalBreakdown?
    public let consumedML: Milliliters
    public let entries: [HydrationEntryDTO]
    public let plantSpeciesID: String
    public let plantStage: PlantStage
    public let streakCount: Int

    public init(id: UUID, date: Date, goal: GoalBreakdown?, consumedML: Milliliters,
                entries: [HydrationEntryDTO], plantSpeciesID: String,
                plantStage: PlantStage, streakCount: Int) {
        self.id = id; self.date = date; self.goal = goal; self.consumedML = consumedML
        self.entries = entries; self.plantSpeciesID = plantSpeciesID
        self.plantStage = plantStage; self.streakCount = streakCount
    }

    /// consumedML / finalML, not clamped at 1.5.
    public var progress: Double {
        guard let final = goal?.finalML, final > 0 else { return 0 }
        return consumedML / final
    }
}

public struct ProfileDraft: Sendable {
    public var weightKG: Double
    public var heightCM: Double
    public var birthYear: Int
    public var biologicalSex: BiologicalSex
    public var activityLevel: ActivityLevel
    public var climateProfile: ClimateProfile
    public var electrolyteModeEnabled: Bool
    public var usesMetric: Bool
    public var wakeTime: DateComponents
    public var sleepTime: DateComponents
}

// MARK: - Repository protocols

public protocol EntryRepository: Sendable {
    func log(volumeML: Milliliters, beverage: Beverage, at: Date, source: EntrySource) async throws -> UUID
    func delete(entryID: UUID) async throws
    func entries(on day: Date) async throws -> [HydrationEntryDTO]
    func entries(from: Date, to: Date) async throws -> [HydrationEntryDTO]
    func caffeineTotal(on day: Date) async throws -> Double
    func alcoholTotal(on day: Date) async throws -> Double
}

public protocol DailyLogRepository: Sendable {
    func log(for day: Date) async throws -> DailyLogDTO
    func upsertGoal(_ breakdown: GoalBreakdown, for day: Date) async throws
    func upsertPlant(species: String, stage: PlantStage, streak: Int, for day: Date) async throws
    func recentLogs(days: Int) async throws -> [DailyLogDTO]
}

public protocol ProfileRepository: Sendable {
    func profile() async throws -> ProfileSnapshot
    func update(_ mutate: @Sendable (inout ProfileDraft) -> Void) async throws
    /// SG-03: turning `true`→`false` requires an explicit Settings confirmation. UI enforces.
    func setMedicalCaution(_ value: Bool) async throws
}

// MARK: - Sync status

public enum SyncStatus: Sendable, Equatable {
    case synced(lastSyncedAt: Date)
    case pending(changeCount: Int)
    case iCloudUnavailable(reason: ICloudUnavailableReason)
    case error(String)
}

public enum ICloudUnavailableReason: Sendable, Equatable {
    case notSignedIn, restricted, networkUnavailable, quotaExceeded, unknown
}

// MARK: - Errors

public enum DataError: LocalizedError, Sendable, Equatable {
    case containerUnavailable
    case entryNotFound(UUID)
    case invalidVolume(Milliliters)       // <= 0 or > 5000
    case unknownBeverage(String)
    case profileMissing
    case cloudKitSchemaNotDeployed        // debug only
}

public enum SharedContainer {
    public static let appGroupID = "group.com.hydraplant.shared"
    // make(inMemory:) and initializeCloudKitSchema() require SwiftData — implement in Xcode.
}
