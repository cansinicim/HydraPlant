// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "HydraData",
    platforms: [.iOS(.v18), .watchOS(.v11)],
    products: [.library(name: "HydraData", targets: ["HydraData"])],
    dependencies: [.package(path: "../HydraCore")],
    targets: [
        .target(name: "HydraData", dependencies: ["HydraCore"],
                swiftSettings: [.swiftLanguageMode(.v6)])
    ]
)
