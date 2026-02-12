// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "AppHttpKit",
    platforms: [.iOS(.v18), .macOS(.v12)],
    products: [
        .library(
            name: "AppHttpKit",
            targets: ["AppHttpKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Flight-School/AnyCodable", from: "0.6.0")
    ],
    targets: [
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "AppHttpKit",
            dependencies: ["AnyCodable"],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "AppHttpKitTests",
            dependencies: ["AppHttpKit"]
        ),
    ]
)
