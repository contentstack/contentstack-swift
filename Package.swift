// swift-tools-version:5.6
import PackageDescription



let package = Package(
    name: "ContentstackSwift",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
        name: "ContentstackSwift",
        targets: ["Contentstack"])
    ],
    dependencies: [
        .package(url: "https://github.com/contentstack/contentstack-utils-swift.git", from: "1.3.4"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package,
        //and on products in packages which this package depends on.
        .target(
            name: "Contentstack",
            dependencies: [.product(name: "ContentstackUtils", package: "contentstack-utils-swift")],
            path: "Sources"),
        .target(
            name: "DVR",
            path: "Utility/contentstack-swift-dvr/contentstack-swift-dvr-master.zip/Sources"),
        .testTarget(
            name: "ContentstackTests",
            dependencies: ["Contentstack", "DVR"],
            path: "Tests")
    ]
)
