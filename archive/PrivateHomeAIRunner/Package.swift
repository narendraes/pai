// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "PrivateHomeAIRunner",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    dependencies: [
        .package(path: "../"),
    ],
    targets: [
        .executableTarget(
            name: "PrivateHomeAIRunner",
            dependencies: [
                .product(name: "PrivateHomeAI", package: "pai")
            ],
            resources: [
                .copy("Resources")
            ]
        ),
    ]
)
