// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "HydraCore",
    platforms: [.iOS(.v18), .watchOS(.v11), .macOS(.v14)],
    products: [
        .library(name: "HydraCore", targets: ["HydraCore"])
    ],
    targets: [
        .target(
            name: "HydraCore",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "HydraCoreTests",
            dependencies: ["HydraCore"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        )
    ]
)
