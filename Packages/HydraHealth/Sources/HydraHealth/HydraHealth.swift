// HydraHealth — HealthKit read/write wrapper. See docs/02 §4.
//
// SKELETON. Depends on HealthKit (iOS SDK), does not build on CLT-only host.
// Public contract is authoritative (docs/02 §4).

import Foundation
import HydraCore

public protocol HealthService: Sendable {
    var isAvailable: Bool { get }

    /// Shows the permission dialog. Does NOT throw on denial — HealthKit does not
    /// reveal "denied" for privacy; authorizationStatus only separates "not asked"
    /// from "asked".
    func requestAuthorization() async throws

    /// Returns nil if no permission. App must fully work in that case.
    func activitySnapshot(for day: Date) async -> ActivitySnapshot?
    func bodyMassKG() async -> Double?
    func sleepWindow(for day: Date) async -> DateInterval?

    /// Writes `dietaryWater` to Apple Health. Silently no-ops without write permission.
    func writeWater(volumeML: Milliliters, at: Date) async throws

    /// Fires when active energy changes. Called at most every 30 min.
    func observeActiveEnergy(_ onChange: @escaping @Sendable (ActivitySnapshot) async -> Void)
    func stopObserving()
}

public enum HealthError: LocalizedError, Sendable {
    case notAvailableOnDevice        // iPad has no HealthKit
    case authorizationFailed(String)
    case writeFailed(String)
}

/// All tests and SwiftUI Previews use this. docs/02 §Dependency injection.
public struct StubHealthService: HealthService {
    public var isAvailable: Bool
    private let snapshot: ActivitySnapshot?

    public init(isAvailable: Bool = true, snapshot: ActivitySnapshot? = nil) {
        self.isAvailable = isAvailable
        self.snapshot = snapshot
    }

    public func requestAuthorization() async throws {}
    public func activitySnapshot(for day: Date) async -> ActivitySnapshot? { snapshot }
    public func bodyMassKG() async -> Double? { nil }
    public func sleepWindow(for day: Date) async -> DateInterval? { nil }
    public func writeWater(volumeML: Milliliters, at: Date) async throws {}
    public func observeActiveEnergy(_ onChange: @escaping @Sendable (ActivitySnapshot) async -> Void) {}
    public func stopObserving() {}
}
