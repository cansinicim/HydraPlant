// swift-tools-version: 6.0
import PackageDescription

// HydraUI does NOT depend on HydraCore (docs/02): the design system is made of
// dumb components that know nothing about business logic. A ProgressRing takes a
// Double, not a DailyLog.
let package = Package(
    name: "HydraUI",
    platforms: [.iOS(.v18), .watchOS(.v11)],
    products: [.library(name: "HydraUI", targets: ["HydraUI"])],
    targets: [
        .target(name: "HydraUI", swiftSettings: [.swiftLanguageMode(.v6)])
    ]
)
