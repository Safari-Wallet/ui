import ProjectDescription
import ProjectDescriptionHelpers

let name = "Safari Wallet"
let bundleId = "com.safari-wallet"
let developmentTeam = "HHJXTX62XS"

let productName = name.replaceSpaceWithUnder

let appTargets = Target.crossPlatform(
    name: Constants.name,
    product: .app,
    productName: productName,
    bundleId: bundleId,
    deploymentTarget: Constants.deploymentTarget,
    infoPlist: .crossPlatformValue(
        iOS: .extendingDefault(with: [
            "CFBundleDisplayName": .string(name),
            "CFBundleURLTypes": Constants.urlTypes,
            "UIRequiresFullScreen": .boolean(true),
        ]),
        macOS: .default
    ),
    sources: .source(Constants.source, withShared: .app),
    resources: .crossPlatform(Constants.resources),
    entitlements: .entitlements(Constants.source),
    dependencies: .crossPlatformValue(
        iOS: [
            .core,
            .target(name: Constants.extensionName.iOS),
        ],
        macOS: [
            .target(name: Constants.extensionName.macOS),
        ]
    )
)

let extensionTargets = Target.crossPlatform(
    name: Constants.extensionName,
    product: .appExtension,
    productName: productName.under.Extension,
    bundleId: bundleId.dot.Extension,
    deploymentTarget: Constants.deploymentTarget,
    infoPlist: .direct(Constants.extensionPlist),
    sources: .source(Constants.extensionSource, withShared: .extension),
    resources: .direct(Constants.sharedExtensionResources),
    entitlements: .entitlements(Constants.extensionSource),
    dependencies: .crossPlatformValue(
        iOS: [
            .core,
        ],
        macOS: [
        ]
    )
)

let testsTargets = Target.crossPlatform(
    name: Constants.testsName,
    product: .unitTests,
    productName: productName.under.Tests,
    bundleId: bundleId.dot.Tests,
    sources: .direct([
        "Tests/**",
    ]),
    dependencies: .crossPlatformValue(
        iOS: [
            .target(name: Constants.name.iOS),
        ],
        macOS: [
            .target(name: Constants.name.macOS),
        ]
    )
)

let project = Project(
    name: name,
    organizationName: name,
    settings: .settings(base: SettingsDictionary()
                            .automaticCodeSigning(devTeam: developmentTeam)
                            .bundleId(bundleId)),
    targets: appTargets + extensionTargets + testsTargets,
    schemes: .crossPlatformSchemes(
        name: Constants.name,
        buildAction: Constants.name,
        testAction: Constants.testsName
    ),
    fileHeaderTemplate: "",
    additionalFiles: [
        "README.md",
        "Shared (Extension)/Resources/README.md",
    ]
)
