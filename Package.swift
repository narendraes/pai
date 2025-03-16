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
        .package(url: "https://github.com/SVGKit/SVGKit.git", from: "3.0.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.1"),
        .package(url: "https://github.com/gaetanzanella/swift-ssh-client.git", from: "0.1.4"),
    ],
    targets: [
        .target(
            name: "PrivateHomeAI",
            dependencies: ["CryptoSwift", "SVGKit", "Alamofire", 
                           .product(name: "SSHClient", package: "swift-ssh-client")],
            resources: [
                .process("Resources")
            ]),
        .testTarget(
            name: "PrivateHomeAITests",
            dependencies: ["PrivateHomeAI"]),
    ]
)
