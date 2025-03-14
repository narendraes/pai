// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "PrivateHomeAIDemo",
    platforms: [
        .iOS(.v15)
    ],
    dependencies: [
        .package(path: "../"),
    ],
    targets: [
        .executableTarget(
            name: "PrivateHomeAIDemo",
            dependencies: [
                .product(name: "PrivateHomeAI", package: "PrivateHomeAI")
            ]),
    ]
) 