// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "YouTubePlayerKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "YouTubePlayerKit",
            targets: ["YouTubePlayerKit"]
        )
    ],
    targets: [
        .target(
            name: "YouTubePlayerKit",
            path: "Sources",
            resources: [
                .copy("./Resources/YouTubePlayer.html")
            ]
        ),
        .testTarget(
            name: "YouTubePlayerKitTests",
            dependencies: ["YouTubePlayerKit"],
            path: "Tests"
        )
    ]
)
