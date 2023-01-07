// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ListDiffUI",
    platforms: [
        .iOS(.v8),
    ],
    products: [
        .library(name: "ListDiffUI", targets: ["ListDiffUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/lxcid/ListDiff.git", .revision("1390504170150f378aa1be17f92322e6d12533d8")),
    ],
    targets: [
        .target(
            name: "ListDiffUI",
            dependencies: ["ListDiff"],
            path: "Sources/"),
    ]
)
