// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Stylize",
    platforms: [.iOS(.v13), .macOS(.v11)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Stylize",
            targets: ["Stylize"]),
    ],
    dependencies: [
        .package(path: "../Localize"),
        .package(url: "https://github.com/jeffreybergier/XPList.git", .branchItem("main")),
        .package(url: "https://github.com/jeffreybergier/Umbrella.git", .branchItem("main"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Stylize",
            dependencies: [
                .byNameItem(name: "Localize", condition: nil),
                .byNameItem(name: "XPList", condition: nil),
                .byNameItem(name: "Umbrella", condition: nil),
            ]),
        .testTarget(
            name: "StylizeTests",
            dependencies: ["Stylize"]),
    ]
)
