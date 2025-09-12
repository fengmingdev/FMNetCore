// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iOSExample",
    platforms: [
        .iOS(.v13),
    ],
    dependencies: [
        .package(path: "../../")
    ],
    targets: [
        .target(
            name: "iOSExample",
            dependencies: ["FMNetCore"])
    ]
)