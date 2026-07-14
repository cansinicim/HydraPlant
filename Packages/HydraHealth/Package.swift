// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "HydraHealth",
    platforms: [.iOS(.v18), .watchOS(.v11)],
    products: [.library(name: "HydraHealth", targets: ["HydraHealth"])],
    dependencies: [.package(path: "../HydraCore")],
    targets: [
        .target(name: "HydraHealth", dependencies: ["HydraCore"],
                swiftSettings: [.swiftLanguageMode(.v6)])
    ]
)
