// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription



let package = Package(
    name: "ContentstackSwift",
    platforms: [.macOS(.v10_15),
                .iOS(.v13),
                .tvOS(.v13),
                .watchOS(.v6)],

    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "ContentstackSwift",
            targets: ["ContentstackSwift"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/contentstack/contentstack-utils-swift.git", from: "1.3.0"),
        // Dev dependencies
        .package(url: "https://github.com/contentstack/contentstack-swift-dvr.git", .branch("master"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package,
        //and on products in packages which this package depends on.
        .target(
            name: "ContentstackSwift",
            dependencies: ["ContentstackUtils"],
            path: "Sources"),
        .testTarget(
            name: "ContentstackTests",
            dependencies: ["ContentstackSwift", "DVR"],
            path: "Tests")
    ]
)
