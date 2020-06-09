// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UILint",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "UILint",
            targets: ["UILint"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "UILint",
            dependencies: []),
        .testTarget(
            name: "UILintTests",
            dependencies: ["UILint"])
    ]
)
