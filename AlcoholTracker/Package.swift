// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AlcoholTracker",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "AlcoholTracker",
            targets: ["AlcoholTracker"]
        ),
    ],
    targets: [
        .target(
            name: "AlcoholTracker",
            path: "AlcoholTracker"
        ),
        .testTarget(
            name: "AlcoholTrackerTests",
            dependencies: ["AlcoholTracker"],
            path: "AlcoholTrackerTests"
        ),
    ]
)
