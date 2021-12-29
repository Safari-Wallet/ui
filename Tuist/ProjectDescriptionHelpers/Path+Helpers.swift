import ProjectDescription

extension Path {
    public static func entitlements(folder: String) -> Path {
        return .init(stringLiteral: "\(folder)/Entitlements.entitlements")
    }
}
