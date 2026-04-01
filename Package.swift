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
            url: "https://github.com/zackaryhuang/vlckit-spm/releases/download/3.7.1/VLCKit.xcframework.zip",
            checksum: "9e6337c1f13481fb062724b0d76fd21aa9bf34ab5ab69b6730d2ca18c87717d5"
        ),
        .binaryTarget(
            name: "MobileVLCKitXC",
            url: "https://github.com/zackaryhuang/vlckit-spm/releases/download/3.7.1/MobileVLCKit.xcframework.zip",
            checksum: "98a63be030b8e6d076516f3e754a59ce144f9052100e4c542fc8f770543f616f"
        ),
        .binaryTarget(
            name: "TVVLCKitXC",
            url: "https://github.com/zackaryhuang/vlckit-spm/releases/download/3.7.1/TVVLCKit.xcframework.zip",
            checksum: "aa39aa6c1a9e594e0fa77494ffc423cbc53d0873adc984c3f5ea6664251c9107"
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
