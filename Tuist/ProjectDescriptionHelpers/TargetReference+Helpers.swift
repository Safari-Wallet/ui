import ProjectDescription

extension TargetReference {
    public static func string(_ string: String) -> TargetReference {
        return .init(stringLiteral: string)
    }
}
