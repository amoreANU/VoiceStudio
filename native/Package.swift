// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "OmniVoiceStudioNative",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .executable(name: "OmniVoice", targets: ["OmniVoiceStudioNative"])
    ],
    targets: [
        .executableTarget(
            name: "OmniVoiceStudioNative",
            path: "Sources/OmniVoiceStudio",
            swiftSettings: [.swiftLanguageMode(.v5)]
        )
    ]
)
