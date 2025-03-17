// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "MacServer",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "MacServer", targets: ["MacServer"]),
        .library(name: "MacServerLib", targets: ["MacServerLib"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.4.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.76.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.6.0"),
        .package(url: "https://github.com/swift-server/swift-service-lifecycle.git", from: "1.0.0-alpha")
    ],
    targets: [
        .executableTarget(
            name: "MacServer",
            dependencies: [
                "MacServerLib",
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Lifecycle", package: "swift-service-lifecycle")
            ]
        ),
        .target(
            name: "MacServerLib",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "CryptoSwift", package: "CryptoSwift")
            ]
        ),
        .testTarget(
            name: "MacServerTests",
            dependencies: ["MacServerLib"]
        )
    ]
) 