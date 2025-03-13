// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "PrivateHomeAI",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "PrivateHomeAI",
            targets: ["PrivateHomeAI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.6.0")),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMajor(from: "1.5.0")),
        .package(url: "https://github.com/NMSSH/NMSSH.git", .upToNextMajor(from: "2.3.0"))
    ],
    targets: [
        .target(
            name: "PrivateHomeAI",
            dependencies: [
                "Alamofire",
                "CryptoSwift",
                "NMSSH"
            ]),
        .testTarget(
            name: "PrivateHomeAITests",
            dependencies: ["PrivateHomeAI"]),
    ]
) 