// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HMic",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "HMic", targets: ["HMic"])
    ],
    targets: [
        .executableTarget(
            name: "HMic",
            path: "Sources/HMic",
            resources: [],
            linkerSettings: [
                .linkedFramework("Carbon"),
                .linkedFramework("CoreAudio"),
                .linkedFramework("AVFoundation"),
                .linkedFramework("AppKit"),
                .linkedFramework("SwiftUI")
            ]
        )
    ]
)
