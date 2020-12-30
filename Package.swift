// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MakeColors",
    platforms: [
        .macOS(.v10_15),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.3.1")),
    ],
    targets: [
        .target(
            name: "MakeColors",
            dependencies: [
                "LibMakeColors"
            ]),
        .target(
            name: "LibMakeColors",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
        .testTarget(
            name: "MakeColorsTests",
            dependencies: ["LibMakeColors"]),
    ]
)
