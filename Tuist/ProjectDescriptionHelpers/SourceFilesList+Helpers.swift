import ProjectDescription

let sharedAppFolders: [SourceFileGlob] = [
    "Shared (App)/**",
    "Shared (App and Extension)/**",
]

let sharedExtensionFolders: [SourceFileGlob] = [
    SourceFileGlob("Shared (Extension)/**", excluding: "Shared (Extension)/Resources/node_modules/**"),
    SourceFileGlob("Shared (App and Extension)/**"),
]

public enum TargetType {
    case app, `extension`
}

extension SourceFilesList {
    public static func source(_ source: String, withShared target: TargetType) -> SourceFilesList {
        return .init(globs: [
            "\(source)/**",
        ] + (target == .app ? sharedAppFolders : sharedExtensionFolders))
    }
}

extension MaybeCrossPlatform {
    public static func source(_ source: CrossPlatformValue<String>, withShared target: TargetType) -> MaybeCrossPlatform<SourceFilesList> {
        return .crossPlatform(CrossPlatformValue<SourceFilesList>(
            iOS: .source(source.iOS, withShared: target),
            macOS: .source(source.macOS, withShared: target)
        ))
    }
}
