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
// 由于iOSExample现在使用CocoaPods管理依赖，此文件不再需要
// 请使用Podfile来管理依赖关系
//
// 要安装依赖，请在终端中运行：
// cd Examples/iOSExample
// pod install
//
// 然后打开iOSExample.xcworkspace而不是iOSExample.xcodeproj
