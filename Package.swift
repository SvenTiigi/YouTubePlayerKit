// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "YouTubePlayerKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
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
