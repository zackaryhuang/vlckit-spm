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
            url: "https://github.com/zackaryhuang/vlckit-spm/releases/download/3.7.0/VLCKit.xcframework.zip",
            checksum: "fae7204b226af2e4402e152962e963398d208d64131a52518508e4c7f66a6b1a"
        ),
        .binaryTarget(
            name: "MobileVLCKitXC",
            url: "https://github.com/zackaryhuang/vlckit-spm/releases/download/3.7.0/MobileVLCKit.xcframework.zip",
            checksum: "99f4534ce760a98693f283c05584dbbfd7974104a52ed2947dc3f8fe51ac6d34"
        ),
        .binaryTarget(
            name: "TVVLCKitXC",
            url: "https://github.com/zackaryhuang/vlckit-spm/releases/download/3.7.0/TVVLCKit.xcframework.zip",
            checksum: "23443ff83bef39f79a7bc0ef146c5bbf31e60fbcc9c77f49f248b8646e3925e0"
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
