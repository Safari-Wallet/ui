import ProjectDescription

let urlName = "com.safari.wallet"
let urlScheme = "safari-wallet"

let sharedResources: [ResourceFileElement] = [
    "Shared (App)/**/*.{xcassets}",
]

public enum Constants {
    public static let deploymentTarget = MaybeCrossPlatform.crossPlatform(CrossPlatformValue(
        iOS: DeploymentTarget.iOS(targetVersion: "15.0", devices: [.iphone, .ipad]),
        macOS: DeploymentTarget.macOS(targetVersion: "11.0")
    ))
    
    public static let source = CrossPlatformValue(
        iOS: "iOS (App)",
        macOS: "macOS (App)"
    )
    public static let extensionSource = CrossPlatformValue(
        iOS: "iOS (Extension)",
        macOS: "macOS (Extension)"
    )
    
    public static let name = CrossPlatformValue(
        iOS: "App (iOS)",
        macOS: "App (macOS)"
    )
    public static let extensionName = CrossPlatformValue(
        iOS: "Extension (iOS)",
        macOS: "Extension (macOS)"
    )
    public static let testsName = CrossPlatformValue(
        iOS: "Tests (iOS)",
        macOS: "Tests (macOS)"
    )
    
    
    public static let sharedExtensionResources = ResourceFileElements(resources: [
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

    public static let resources = CrossPlatformValue(
        iOS: ResourceFileElements(resources: sharedResources),
        macOS: ResourceFileElements(resources: [
            "macOS (App)/**/*.{storyboard}",
        ] + sharedResources)
    )
    
    // CFBundleURLTypes
    public static let urlTypes = InfoPlist.Value.array([
        .dictionary([
            "CFBundleTypeRole": .string("Editor"),
            "CFBundleURLName": .string(urlName),
            "CFBundleURLSchemes": .array([
                .string(urlScheme),
            ]),
        ]),
    ])
    
    public static let extensionPlist = InfoPlist.extendingDefault(with: [
        "CFBundleDisplayName": "Extension",
        "NSExtension": .dictionary([
            "NSExtensionPointIdentifier": .string("com.apple.Safari.web-extension"),
            "NSExtensionPrincipalClass": .string("$(PRODUCT_MODULE_NAME).SafariWebExtensionHandler"),
        ]),
    ])
}
