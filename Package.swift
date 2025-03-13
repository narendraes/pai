// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "PrivateHomeAI",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "PrivateHomeAI", targets: ["PrivateHomeAI"]),
    ],
    dependencies: [
        // Networking
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.6.4")),
        
        // SSH Connection
        .package(url: "https://github.com/NMSSH/NMSSH.git", .upToNextMajor(from: "2.3.1")),
        
        // Security
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMajor(from: "1.6.0")),
        
        // Image Processing
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", .upToNextMajor(from: "5.15.0")),
        
        // UI Components
        .package(url: "https://github.com/SwiftUIX/SwiftUIX.git", .upToNextMajor(from: "0.1.4")),
        
        // Testing
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", .upToNextMajor(from: "1.11.0")),
    ],
    targets: [
        .target(
            name: "PrivateHomeAI",
            dependencies: [
                "Alamofire",
                "NMSSH",
                "CryptoSwift",
                "SDWebImage",
                "SwiftUIX",
            ]
        ),
        .testTarget(
            name: "PrivateHomeAITests",
            dependencies: [
                "PrivateHomeAI",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
    ]
) 