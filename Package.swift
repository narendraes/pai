// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "PrivateHomeAI",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "PrivateHomeAI",
            targets: ["PrivateHomeAI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.7.0"),
    ],
    targets: [
        .target(
            name: "PrivateHomeAI",
            dependencies: ["CryptoSwift"],
            resources: [
                .process("Resources")
            ]),
        .testTarget(
            name: "PrivateHomeAITests",
            dependencies: ["PrivateHomeAI"]),
    ]
)
