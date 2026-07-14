// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "HydraEngine",
    platforms: [.iOS(.v18), .watchOS(.v11), .macOS(.v14)],
    products: [
        .library(name: "HydraEngine", targets: ["HydraEngine"])
    ],
    dependencies: [
        .package(path: "../HydraCore")
    ],
    targets: [
        .target(
            name: "HydraEngine",
            dependencies: ["HydraCore"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "HydraEngineTests",
            dependencies: ["HydraEngine", "HydraCore"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        )
    ]
)
