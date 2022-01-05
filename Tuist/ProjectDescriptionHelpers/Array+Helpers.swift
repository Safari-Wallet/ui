import ProjectDescription

extension Array {
    public static func crossPlatformSchemes(
        name: CrossPlatformValue<String>,
        buildAction: CrossPlatformValue<String>,
        testAction: CrossPlatformValue<String>
    ) -> [Scheme] {
        return [
            Scheme(
                name: name.iOS,
                buildAction: .buildAction(targets: [.string(buildAction.iOS)]),
                testAction: .targets([.string(testAction.iOS)])
            ),
            Scheme(
                name: name.macOS,
                buildAction: .buildAction(targets: [.string(buildAction.macOS)]),
                testAction: .targets([.string(testAction.macOS)])
            ),
        ]
    }
}
