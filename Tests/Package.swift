//
//  Package.swift
//  FMNetCoreTests
//
//  Created by Fengming on 2025/9/12.
//

import PackageDescription

let package = Package(
    name: "FMNetCoreTests",
    dependencies: [
        .package(path: "../")
    ],
    targets: [
        .testTarget(
            name: "FMNetCoreTests",
            dependencies: ["FMNetCore"])
    ]
)