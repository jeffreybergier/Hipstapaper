// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Interface",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Interface",
            targets: ["Interface"]),
    ],
    dependencies: [
        .package(path: "../Datum"),
        .package(path: "../Browse"),
        .package(path: "../Snapshot"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Interface",
            dependencies: [
                .byNameItem(name: "Datum", condition: nil),
                .byNameItem(name: "Browse", condition: nil),
                .byNameItem(name: "Snapshot", condition: nil),
            ]
        ),
        .testTarget(
            name: "InterfaceTests",
            dependencies: ["Interface"]),
    ]
)
