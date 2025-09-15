// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FMNetCore",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .watchOS(.v6),
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "FMNetCore",
            targets: ["FMNetCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.4.0"),
        .package(url: "https://github.com/Moya/Moya.git", from: "15.0.0"),
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.26.0"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.5.0")
    ],
    targets: [
        .target(
            name: "FMNetCore",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "Moya", package: "Moya"),
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift")
            ],
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "FMNetCoreTests",
            dependencies: ["FMNetCore"],
            path: "Tests"
        ),
        .target(
            name: "iOSExample",
            dependencies: ["FMNetCore"],
            path: "Examples/iOSExample/iOSExample"
        )
    ]
)