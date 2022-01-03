import ProjectDescription
import ProjectDescriptionHelpers

let name = "Safari Wallet"
let bundleId = "com.safari-wallet"
let developmentTeam = "HHJXTX62XS"
let urlName = "com.safari.wallet"
let urlScheme = "safari-wallet"

let productName = name.replacingOccurrences(of: " ", with: "_")
let productNameExtension = "\(productName)_Extension"
let productNameTests = "\(productName)_Tests"
let extensionBundleId = "\(bundleId).Extension"
let testsTargetName = "\(name) Tests"
let iosName = "App (iOS)"
let macosName = "App (macOS)"
let iosExtensionName = "Extension (iOS)"
let macosExtensionName = "Extension (macOS)"

let sharedAppFolders = [
    "Shared (App)/**",
    "Shared (App and Extension)/**",
]

let sharedExtensionFolders = [
    SourceFileGlob("Shared (Extension)/**", excluding: "Shared (Extension)/Resources/node_modules/**"),
    SourceFileGlob("Shared (App and Extension)/**"),
]

let sharedExtensionResources = ResourceFileElements(resources: [
    .folderReference(path: "Shared (Extension)/Resources/ethereum"),
    .folderReference(path: "Shared (Extension)/Resources/_locales"),
    .folderReference(path: "Shared (Extension)/Resources/images"),
    "Shared (Extension)/Resources/background.js",
    "Shared (Extension)/Resources/content.js",
    "Shared (Extension)/Resources/popup.js",
    "Shared (Extension)/Resources/popup.css",
    "Shared (Extension)/Resources/popup.html",
    "Shared (Extension)/Resources/manifest.json",
])

let resources = ResourceFileElements(resources: [
    "Shared (App)/**/*.{xcassets}",
])
let macosResources = ResourceFileElements(resources: [
    "macOS (App)/**/*.{storyboard}",
] + resources.resources)

let coreDependency = TargetDependency.external(name: "SafariWalletCore")

let baseSettings = SettingsDictionary()
    .automaticCodeSigning(devTeam: developmentTeam)
    .bundleId(bundleId)

let iosDeploymentTarget = DeploymentTarget.iOS(targetVersion: "15.0", devices: [.iphone, .ipad])
let macosDeploymentTarget = DeploymentTarget.macOS(targetVersion: "11.0")

let iosSource = "iOS (App)"
let macosSource = "macOS (App)"
let iosExtensionSource = "iOS (Extension)"
let macosExtensionSource = "macOS (Extension)"

let iosTarget = Target(
    name: iosName,
    platform: .iOS,
    product: .app,
    productName: productName,
    bundleId: bundleId,
    deploymentTarget: iosDeploymentTarget,
    infoPlist: .extendingDefault(with: [
        "CFBundleDisplayName": .string(name),
        "CFBundleURLTypes": .array([
            .dictionary([
                "CFBundleTypeRole": .string("Editor"),
                "CFBundleURLName": .string(urlName),
                "CFBundleURLSchemes": .array([
                    .string(urlScheme),
                ]),
            ]),
        ]),
    ]),
    sources: .init(globs: [
        "\(iosSource)/**",
    ] + sharedAppFolders),
    resources: resources,
    entitlements: .entitlements(folder: iosSource),
    dependencies: [
        coreDependency,
        .target(name: iosExtensionName),
    ]
)

let macosTarget = Target(
    name: macosName,
    platform: .macOS,
    product: .app,
    productName: productName,
    bundleId: bundleId,
    deploymentTarget: macosDeploymentTarget,
    sources: .init(globs: [
        "\(macosSource)/**",
    ] + sharedAppFolders),
    resources: macosResources,
    entitlements: .entitlements(folder: macosSource),
    dependencies: [
        .target(name: macosExtensionName),
    ]
)

let extensionPlist = InfoPlist.extendingDefault(with: [
    "NSExtension": .dictionary([
        "NSExtensionPointIdentifier": .string("com.apple.Safari.web-extension"),
        "NSExtensionPrincipalClass": .string("$(PRODUCT_MODULE_NAME).SafariWebExtensionHandler"),
    ]),
])

let iosExtensionTarget = Target(
    name: iosExtensionName,
    platform: .iOS,
    product: .appExtension,
    productName: productNameExtension,
    bundleId: extensionBundleId,
    deploymentTarget: iosDeploymentTarget,
    infoPlist: extensionPlist,
    sources: .init(globs: [
        "\(iosExtensionSource)/**",
    ] + sharedExtensionFolders),
    resources: sharedExtensionResources,
    entitlements: .entitlements(folder: iosExtensionSource),
    dependencies: [
        coreDependency,
    ]
)

let macosExtensionTarget = Target(
    name: macosExtensionName,
    platform: .macOS,
    product: .appExtension,
    productName: productNameExtension,
    bundleId: extensionBundleId,
    deploymentTarget: macosDeploymentTarget,
    infoPlist: extensionPlist,
    sources: .init(globs: [
        "\(macosExtensionSource)/**",
    ] + sharedExtensionFolders),
    resources: sharedExtensionResources,
    entitlements: .entitlements(folder: macosExtensionSource),
    dependencies: [
    ]
)

let testsTarget = Target(
    name: testsTargetName,
    platform: .iOS,
    product: .unitTests,
    productName: productNameTests,
    bundleId: "\(bundleId).Tests",
    sources: [
        "Tests/**",
    ],
    dependencies: [
        .target(name: iosName),
    ]
)

let project = Project(
    name: name,
    organizationName: name,
    settings: .settings(base: baseSettings),
    targets: [
        iosTarget,
        macosTarget,
        iosExtensionTarget,
        macosExtensionTarget,
        testsTarget,
    ],
    schemes: [
        Scheme(
            name: iosName,
            shared: true,
            buildAction: .buildAction(targets: ["\(iosName)"]),
            testAction: .targets(["\(testsTargetName)"])
        ),
        Scheme(
            name: macosName,
            shared: true,
            buildAction: .buildAction(targets: ["\(macosName)"])
        ),
    ],
    fileHeaderTemplate: "",
    additionalFiles: [
        "README.md",
        "Shared (Extension)/Resources/README.md",
    ]
)
