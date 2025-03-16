// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "NookuRunner",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    dependencies: [
        .package(path: "../"),
    ],
    targets: [
        .executableTarget(
            name: "NookuRunner",
            dependencies: [
                .product(name: "Nooku", package: "pai")
            ]
        ),
    ]
)
