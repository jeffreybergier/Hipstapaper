// swift-tools-version:5.7

//
//  Created by Jeffrey Bergier on 2022/07/01.
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
    name: "V3WebsiteEdit",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(
            name: "V3WebsiteEdit",
            targets: ["V3WebsiteEdit"]),
    ],
    dependencies: [
        .package(path: "../V3Model"),
        .package(path: "../V3Localize"),
        .package(path: "../V3Style"),
        .package(path: "../V3Store"),
        .package(path: "../V3Errors"),
        .package(url: "https://github.com/jeffreybergier/Umbrella.git", branch: "v3"),
    ],
    targets: [
        .target(
            name: "V3WebsiteEdit",
            dependencies: [
                .byNameItem(name: "V3Model", condition: nil),
                .byNameItem(name: "V3Localize", condition: nil),
                .byNameItem(name: "V3Style", condition: nil),
                .byNameItem(name: "V3Store", condition: nil),
                .byNameItem(name: "V3Errors", condition: nil),
                .byNameItem(name: "Umbrella", condition: nil),
            ]),
    ]
)
