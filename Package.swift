// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StoryToolsSP",
    platforms: [.visionOS(.v26)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "StoryToolsSP",
            targets: ["StoryToolsSP"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .binaryTarget(name: "StoryToolsBinary", url: "https://github.com/YinZhenJob/StoryToolsSP/releases/download/untagged-c0d78d3ab0941ab7bd4c/StoryTools.xcframework.zip", checksum: "a11850741a8d51c41056f4f130bf6d2294d3d0976421c53af1e6ec9c1ab4edc6"),
        .target(
            name: "StoryToolsSP",
            dependencies: ["StoryToolsBinary"],
            path: "Sources/StoryToolsSP",
            resources: []
        )
    ]
)
