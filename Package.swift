// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StoryToolsSP",
    platforms: [.visionOS(.v26)],
    products: [
        .library(
            name: "StoryTools",
            targets: ["StoryTools"]
        ),
    ],
    targets: [
        .target(
            name: "StoryToolsSP",
            path: "Sources",
        ),
        .binaryTarget(name: "StoryTools", url: "https://github.com/YinZhenJob/StoryToolsSP/releases/download/v1.0.0/StoryTools.xcframework.zip", checksum: "a11850741a8d51c41056f4f130bf6d2294d3d0976421c53af1e6ec9c1ab4edc6")
    ]
)
