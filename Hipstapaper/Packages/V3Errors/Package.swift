// swift-tools-version: 5.10

//
//  Created by Jeffrey Bergier on 2022/07/02.
//
//  MIT License
//
//  Copyright (c) 2021 Jeffrey Bergier
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import PackageDescription

let package = Package(
    name: "V3Errors",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "V3Errors",
            targets: ["V3Errors"]),
    ],
    dependencies: [
        .package(path: "../V3Model"),
        .package(path: "../V3Store"),
        .package(path: "../V3Localize"),
        .package(url: "https://github.com/jeffreybergier/Umbrella.git", branch: "waterme3-wOS10-Swift6"),
    ],
    targets: [
        .target(
            name: "V3Errors",
            dependencies: [
                .byNameItem(name: "V3Model", condition: nil),
                .byNameItem(name: "V3Store", condition: nil),
                .byNameItem(name: "V3Localize", condition: nil),
                .byNameItem(name: "Umbrella", condition: nil),
            ],
            swiftSettings: [
              .enableExperimentalFeature("StrictConcurrency"),
              .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
    ],
    swiftLanguageVersions: [.version("5")]
)
