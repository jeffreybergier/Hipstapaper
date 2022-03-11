// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Browse",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Browse",
            targets: ["Browse"]),
    ],
    dependencies: [
        .package(path: "../Stylize"),
        .package(url: "https://github.com/jeffreybergier/Umbrella.git", .branchItem("main"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Browse",
            dependencies: [
                .byNameItem(name: "Stylize", condition: nil),
                .byNameItem(name: "Umbrella", condition: nil),
            ]),
        .testTarget(
            name: "BrowseTests",
            dependencies: ["Browse"]),
    ]
)
