// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MovieDBData",
    platforms: [.macOS(.v12), .iOS(.v18)],
    products: [
        .library(
            name: "MovieDBData",
            targets: ["MovieDBData"]),
    ],
    dependencies: [.package(path: "../AppHttpKit")],
    targets: [
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MovieDBData",
            dependencies: ["AppHttpKit"],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "MovieDBDataTests",
            dependencies: ["MovieDBData"]
        ),
    ]
)
