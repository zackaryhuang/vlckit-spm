// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "VLCKitSPM",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
        .tvOS(.v13),
        .watchOS(.v9),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "VLCKitSPM",
            targets: ["VLCKitSPM"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "VLCKitXC",
            url: "https://github.com/zackaryhuang/vlckit-spm/releases/download/3.7.2/VLCKit.xcframework.zip",
            checksum: "ef0752f8c2f50f9023655f4b32168053020b48219413931b7020cbf3d150dc7b"
        ),
        .binaryTarget(
            name: "MobileVLCKitXC",
            url: "https://github.com/zackaryhuang/vlckit-spm/releases/download/3.7.2/MobileVLCKit.xcframework.zip",
            checksum: "103cd4ecd3d74f056fa54e6b5295723be55d5a35c9b45f9c93632d269f34c96c"
        ),
        .binaryTarget(
            name: "TVVLCKitXC",
            url: "https://github.com/zackaryhuang/vlckit-spm/releases/download/3.7.2/TVVLCKit.xcframework.zip",
            checksum: "7b3462d0d5a6da3fea75adc8a2b69741ed235aea34159cdb8b5209fb8cfdcec4"
        ),
        .target(
            name: "VLCKitSPM",
            dependencies: [
                .target(name: "VLCKitXC", condition: .when(platforms: [.macOS])),
                .target(
                    name: "MobileVLCKitXC",
                    condition: .when(platforms: [.iOS, .watchOS, .visionOS])),
                .target(name: "TVVLCKitXC", condition: .when(platforms: [.tvOS])),
            ],
            linkerSettings: [
                .linkedFramework("QuartzCore", .when(platforms: [.iOS, .tvOS, .visionOS])),
                .linkedFramework("CoreText", .when(platforms: [.iOS, .tvOS, .watchOS, .visionOS])),
                .linkedFramework(
                    "AVFoundation", .when(platforms: [.iOS, .tvOS, .watchOS, .visionOS])),
                .linkedFramework("Security", .when(platforms: [.iOS, .watchOS, .visionOS])),
                .linkedFramework("CFNetwork", .when(platforms: [.iOS, .watchOS, .visionOS])),
                .linkedFramework("AudioToolbox", .when(platforms: [.iOS, .tvOS, .visionOS])),
                .linkedFramework("OpenGLES", .when(platforms: [.iOS, .tvOS])),
                .linkedFramework("CoreGraphics", .when(platforms: [.iOS, .watchOS, .visionOS])),
                .linkedFramework("VideoToolbox", .when(platforms: [.iOS, .tvOS, .visionOS])),
                .linkedFramework(
                    "CoreMedia", .when(platforms: [.iOS, .tvOS, .watchOS, .visionOS])),
                .linkedLibrary("c++", .when(platforms: [.iOS, .tvOS, .watchOS, .visionOS])),
                .linkedLibrary("xml2", .when(platforms: [.iOS, .tvOS, .watchOS, .visionOS])),
                .linkedLibrary("z", .when(platforms: [.iOS, .tvOS, .watchOS, .visionOS])),
                .linkedLibrary("bz2", .when(platforms: [.iOS, .tvOS, .watchOS, .visionOS])),
                .linkedFramework("Foundation", .when(platforms: [.macOS])),
                .linkedLibrary("iconv"),
            ]
        ),
    ]
)
