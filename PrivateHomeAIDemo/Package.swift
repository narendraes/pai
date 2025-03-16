// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "PrivateHomeAIDemo",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    dependencies: [
        .package(path: "../"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.1"),
    ],
    targets: [
        .executableTarget(
            name: "PrivateHomeAIDemo",
            dependencies: [
                .product(name: "PrivateHomeAI", package: "pai"),
                "Alamofire"
            ]),
    ]
) 