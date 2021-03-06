// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MakeColors",
    platforms: [
        .macOS("10.15.4"),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.3.1")),
        .package(url: "https://github.com/robb/RBBJSON", .branch("main")),
    ],
    targets: [
        .target(
            name: "MakeColors",
            dependencies: [
                "LibMakeColors",
            ]
        ),
        .target(
            name: "LibMakeColors",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .testTarget(
            name: "MakeColorsTests",
            dependencies: [
                "LibMakeColors",
                .product(name: "RBBJSON", package: "RBBJSON"),
            ]
        ),
    ]
)
