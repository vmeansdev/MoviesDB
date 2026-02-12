// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "PlistReader",
    products: [
        .library(
            name: "PlistReader",
            targets: ["PlistReader"]),
    ],
    targets: [
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PlistReader"),
        .testTarget(
            name: "PlistReaderTests",
            dependencies: ["PlistReader"]
        ),
    ]
)
