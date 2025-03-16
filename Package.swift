// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Nooku",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "Nooku",
            targets: ["Nooku"]),
    ],
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.7.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.1"),
        .package(url: "https://github.com/gaetanzanella/swift-ssh-client.git", from: "0.1.4"),
    ],
    targets: [
        .target(
            name: "Nooku",
            dependencies: ["CryptoSwift", "Alamofire", 
                           .product(name: "SSHClient", package: "swift-ssh-client")],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .define("SWIFT_PACKAGE"),
                .define("USE_UNIFORM_TYPE_IDENTIFIERS", .when(platforms: [.iOS, .macOS])),
                .define("DISABLE_ALAMOFIRE_MULTIPART", .when(platforms: [.iOS, .macOS]))
            ]
        ),
        .testTarget(
            name: "NookuTests",
            dependencies: ["Nooku"]),
    ]
)
