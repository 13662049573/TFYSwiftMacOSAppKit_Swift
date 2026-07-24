// swift-tools-version: 5.9
// TFYSwiftMacOSAppKit 1.5.0 — version is published via git tag; keep aligned with podspec / README.

import PackageDescription

let package = Package(
    name: "TFYSwiftMacOSAppKit",
    platforms: [
        .macOS("13.5")
    ],
    products: [
        .library(
            name: "TFYSwiftMacOSAppKit",
            targets: ["TFYSwiftMacOSAppKit"]
        )
    ],
    targets: [
        .target(
            name: "TFYSwiftMacOSAppKit",
            path: "TFYSwiftMacOSAppKit_Swift/TFYSwiftMacOSAppKit"
        ),
        .executableTarget(
            name: "TFYSwiftMacOSAppKitSmoke",
            dependencies: ["TFYSwiftMacOSAppKit"],
            path: "SmokeTests/TFYSwiftMacOSAppKitSmoke"
        )
    ],
    swiftLanguageVersions: [.v5]
)
