import ProjectDescription

public extension SettingsDictionary {
    func bundleId(_ value: String) -> SettingsDictionary {
        merging(["WALLET_BUNDLE_ID": SettingValue(stringLiteral: value)])
    }
}
