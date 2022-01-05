import ProjectDescription

let dependencies = Dependencies(
    swiftPackageManager: [
        .package(url: "https://github.com/Safari-Wallet/core", .branch("main")),
    ],
    platforms: [.iOS]
)
