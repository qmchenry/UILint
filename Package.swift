// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UILint",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_14)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "UILint",
            targets: ["UILint"]),
    ],
    dependencies: [
        .package(url: "https://github.com/qmchenry/SimplePDF", .branch("master")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "UILint",
            dependencies: []),
        .testTarget(
            name: "UILintTests",
            dependencies: ["UILint"]),
    ]
)
