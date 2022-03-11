// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Datum",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Datum",
            targets: ["Datum"]),
    ],
    dependencies: [
        .package(path: "../Localize"),
        .package(url: "https://github.com/jeffreybergier/Umbrella.git", .branch("main"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Datum",
            dependencies: [
                .byNameItem(name: "Localize", condition: nil),
                .byNameItem(name: "Umbrella", condition: nil),
            ]
        ),
        .testTarget(
            name: "DatumTests",
            dependencies: [
                .byNameItem(name: "Datum", condition: nil),
//                .byNameItem(name: "TestUmbrella", condition: nil), // TODO: Why doesn't this work?
            ]
        ),
    ]
)
