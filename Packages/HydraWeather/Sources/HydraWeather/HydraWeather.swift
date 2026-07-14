// HydraWeather — WeatherKit wrapper + cache + location. See docs/02 §5.
//
// SKELETON. Depends on WeatherKit + CoreLocation (iOS SDK), does not build on CLT.
// Public contract is authoritative (docs/02 §5).

import Foundation
import HydraCore

public struct WeatherAttribution: Sendable {
    public let combinedMarkLightURL: URL
    public let combinedMarkDarkURL: URL
    public let legalPageURL: URL

    public init(combinedMarkLightURL: URL, combinedMarkDarkURL: URL, legalPageURL: URL) {
        self.combinedMarkLightURL = combinedMarkLightURL
        self.combinedMarkDarkURL = combinedMarkDarkURL
        self.legalPageURL = legalPageURL
    }
}

public protocol WeatherProvider: Sendable {
    /// Cache TTL: 60 min. Throws LocationUnavailable without location permission.
    func todaySnapshot() async throws -> WeatherSnapshot
    /// Manual city entry (location denied).
    func snapshot(forCity: String) async throws -> WeatherSnapshot
    /// Last successful result. Shown with a "yesterday's weather" badge when offline.
    var cachedSnapshot: WeatherSnapshot? { get }
    /// Mandatory legal attribution. Called on EVERY screen showing weather.
    static var attribution: WeatherAttribution { get async throws }
}

public enum WeatherError: LocalizedError, Sendable {
    case locationPermissionDenied
    case locationUnavailable
    case cityNotFound(String)
    case networkUnavailable
    case quotaExceeded              // WeatherKit 500k/month exceeded
    case serviceError(String)
}

/// Location provider. ALWAYS reduced accuracy. "Always" permission is NEVER requested.
public protocol LocationProvider: Sendable {
    func requestWhenInUseAuthorization() async
    func currentLatLon() async throws -> (lat: Double, lon: Double)
    /// City name for notifications. Resolved on device, never hits the network.
    func cityName(forLat lat: Double, lon: Double) async -> String?
}

/// Test/Preview stub.
public struct StubWeatherProvider: WeatherProvider {
    private let snapshot: WeatherSnapshot
    public init(snapshot: WeatherSnapshot) { self.snapshot = snapshot }
    public func todaySnapshot() async throws -> WeatherSnapshot { snapshot }
    public func snapshot(forCity: String) async throws -> WeatherSnapshot { snapshot }
    public var cachedSnapshot: WeatherSnapshot? { snapshot }
    public static var attribution: WeatherAttribution {
        get async throws {
            WeatherAttribution(
                combinedMarkLightURL: URL(string: "https://weatherkit.apple.com/light")!,
                combinedMarkDarkURL: URL(string: "https://weatherkit.apple.com/dark")!,
                legalPageURL: URL(string: "https://weatherkit.apple.com/legal-attribution")!)
        }
    }
}
