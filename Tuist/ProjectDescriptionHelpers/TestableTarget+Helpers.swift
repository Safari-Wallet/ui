import ProjectDescription

extension TestableTarget {
    public static func string(_ string: String) -> TestableTarget {
        return .init(stringLiteral: string)
    }
}
