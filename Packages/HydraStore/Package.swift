// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "HydraStore",
    platforms: [.iOS(.v18), .watchOS(.v11)],
    products: [.library(name: "HydraStore", targets: ["HydraStore"])],
    dependencies: [.package(path: "../HydraCore")],
    targets: [
        .target(name: "HydraStore", dependencies: ["HydraCore"],
                swiftSettings: [.swiftLanguageMode(.v6)])
    ]
)
