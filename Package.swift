// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
let package = Package(
    name: "keying",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v12),
    ],
    products: [
        .library(
            name: "keying",
            type: .dynamic,
            targets: ["keying"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/jedisct1/swift-sodium.git", .upToNextMajor(from: "0.9.1")),
        .package(url: "https://github.com/evgenyneu/keychain-swift.git", .upToNextMajor(from: "20.0.0")),
    ],
    targets: [
        .target(
            name: "keying",
            dependencies: [
                .product(name: "Sodium", package: "swift-sodium"),
                .product(name: "KeychainSwift", package: "keychain-swift"),
            ]
        ),
        .testTarget(
            name: "keyingTests",
            dependencies: ["keying"]
        ),
    ]
)
