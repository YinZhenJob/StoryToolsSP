// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StoryToolsSP",
    platforms: [.visionOS(.v26)],
    products: [
        .library(
            name: "StoryToolsSP",
            targets: ["StoryToolsSP"]
        ),
    ],
    targets: [
        .target(
            name: "StoryToolsSP",
            path: "Sources"
        )
    ]
)
