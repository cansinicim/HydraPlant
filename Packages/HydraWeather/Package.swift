// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "HydraWeather",
    platforms: [.iOS(.v18), .watchOS(.v11)],
    products: [.library(name: "HydraWeather", targets: ["HydraWeather"])],
    dependencies: [.package(path: "../HydraCore")],
    targets: [
        .target(name: "HydraWeather", dependencies: ["HydraCore"],
                swiftSettings: [.swiftLanguageMode(.v6)])
    ]
)
