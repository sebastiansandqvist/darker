// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Darker",
    platforms: [.macOS(.v13)],
    products: [.executable(name: "Darker", targets: ["Darker"])],
    targets: [
        .executableTarget(name: "Darker"),
        .testTarget(name: "DarkerTests", dependencies: ["Darker"])
    ]
)
