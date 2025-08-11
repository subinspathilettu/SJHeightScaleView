// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HeightScaleView",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "HeightScaleView",
            targets: ["HeightScaleView"]),
    ],
    dependencies: [
        // TinyConstraints dependency
        .package(url: "https://github.com/roberthein/TinyConstraints.git", from: "4.0.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "HeightScaleView",
            path: "Sources/HeightScaleView"),
        .testTarget(
            name: "HeightScaleViewTests",
            dependencies: ["HeightScaleView"]
        ),
    ]
)
