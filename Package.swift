// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "YouTubePlayerKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "YouTubePlayerKit",
            targets: [
                "YouTubePlayerKit"
            ]
        )
    ],
    targets: [
        .target(
            name: "YouTubePlayerKit",
            path: "Sources"
        ),
        .testTarget(
            name: "YouTubePlayerKitTests",
            dependencies: [
                "YouTubePlayerKit"
            ],
            path: "Tests"
        )
    ]
)
