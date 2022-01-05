import ProjectDescription

extension Path {
    public static func entitlements(folder: String) -> Path {
        return .init(stringLiteral: "\(folder)/Entitlements.entitlements")
    }
}

extension MaybeCrossPlatform {
    public static func entitlements(_ folder: CrossPlatformValue<String>) -> MaybeCrossPlatform<Path> {
        return .crossPlatform(CrossPlatformValue<Path>(
            iOS: .entitlements(folder: folder.iOS),
            macOS: .entitlements(folder: folder.macOS)
        ))
    }
}
