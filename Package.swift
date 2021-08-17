// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "dsymrename",
    platforms: [
        .macOS(.v10_11)
    ],
    products: [
        .executable(name: "dsymrename", targets: ["dsymrename"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kylef/Commander.git", from: "0.9.1"),
    ],
    targets: [
        .target(name: "dsymrename", dependencies: ["Commander"]),
    ]
)
