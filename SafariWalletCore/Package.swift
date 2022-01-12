// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SafariWalletCore",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
    ],
    products: [
        .library(
            name: "SafariWalletCore",
            targets: ["SafariWalletCore"]),
    ],
    dependencies: [
        .package(name: "MEWwalletKit", url: "https://github.com/MyEtherWallet/mew-wallet-ios-kit", .upToNextMajor(from: "1.4.13")),
        .package(name: "SocketIO", url: "https://github.com/socketio/socket.io-client-swift", .revision("a1ed825835a2d8c2555938e96557ccc05e4bebf3")),
    ],
    targets: [
        .target(
            name: "SafariWalletCore",
            dependencies: ["MEWwalletKit", "SocketIO"],
            path: "Source"),
        .testTarget(
            name: "SafariWalletCoreTests",
            dependencies: ["SafariWalletCore", "MEWwalletKit"],
            path: "Tests"),
    ]
)
