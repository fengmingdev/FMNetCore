// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ExampleApp",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .watchOS(.v6),
        .tvOS(.v13)
    ],
    dependencies: [
        .package(path: "../../")
    ],
    targets: [
        .target(
            name: "ExampleApp",
            dependencies: ["FMNetCore"])
    ]
)