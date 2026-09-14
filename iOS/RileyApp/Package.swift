// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "RileyApp",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "RileyApp",
            targets: ["RileyApp"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "RileyApp",
            dependencies: [],
            path: "Sources",
            resources: [
                .process("../Assets.xcassets"),
                .process("../Resources")
            ]
        ),
    ]
)
