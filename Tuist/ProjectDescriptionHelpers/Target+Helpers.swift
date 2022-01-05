import ProjectDescription

extension Target {
    public static func crossPlatform(
        name: CrossPlatformValue<String>,
        product: ProjectDescription.Product,
        productName: String,
        bundleId: String,
        deploymentTarget: MaybeCrossPlatform<DeploymentTarget>? = nil,
        infoPlist: MaybeCrossPlatform<InfoPlist> = .direct(.default),
        sources: MaybeCrossPlatform<SourceFilesList>,
        resources: MaybeCrossPlatform<ResourceFileElements>? = nil,
        entitlements: MaybeCrossPlatform<Path>? = nil,
        dependencies: MaybeCrossPlatform<[TargetDependency]>
    ) -> [ProjectDescription.Target] {
        return [
            Target(
                name: name.iOS,
                platform: .iOS,
                product: product,
                productName: productName,
                bundleId: bundleId,
                deploymentTarget: deploymentTarget?.crossPlatformValue.iOS,
                infoPlist: infoPlist.crossPlatformValue.iOS,
                sources: sources.crossPlatformValue.iOS,
                resources: resources?.crossPlatformValue.iOS,
                entitlements: entitlements?.crossPlatformValue.iOS,
                dependencies: dependencies.crossPlatformValue.iOS
            ),
            Target(
                name: name.macOS,
                platform: .macOS,
                product: product,
                productName: productName,
                bundleId: bundleId,
                deploymentTarget: deploymentTarget?.crossPlatformValue.macOS,
                infoPlist: infoPlist.crossPlatformValue.macOS,
                sources: sources.crossPlatformValue.macOS,
                resources: resources?.crossPlatformValue.macOS,
                entitlements: entitlements?.crossPlatformValue.macOS,
                dependencies: dependencies.crossPlatformValue.macOS
            )
        ]
    }
}
