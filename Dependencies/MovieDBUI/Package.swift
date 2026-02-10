// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MovieDBUI",
    platforms: [.macOS(.v12), .iOS(.v17)],
    products: [
        .library(
            name: "MovieDBUI",
            targets: ["MovieDBUI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "8.0.0")),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.12.0")
    ],
    targets: [
        .target(
            name: "MovieDBUI",
            dependencies: ["Kingfisher"],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "MovieDBUITests",
            dependencies: ["MovieDBUI", .product(name: "SnapshotTesting", package: "swift-snapshot-testing")]
        ),
    ]
)
