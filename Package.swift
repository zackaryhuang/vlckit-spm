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
            url: "https://github.com/zackaryhuang/vlckit-spm/releases/download/v3.7.3/VLCKit.xcframework.zip",
            checksum: "b97b21adcc0d13078f1958ac9bdd8b1057a8b14980bfbc9841a1435ebfd5ebde"
        ),
        .binaryTarget(
            name: "MobileVLCKitXC",
            url: "https://github.com/zackaryhuang/vlckit-spm/releases/download/v3.7.3/MobileVLCKit.xcframework.zip",
            checksum: "1a94ad0b3a74b1fbf116d3321aa98f79e726212b7888c4c85a2ae8c8d4fdc71e"
        ),
        .binaryTarget(
            name: "TVVLCKitXC",
            url: "https://github.com/zackaryhuang/vlckit-spm/releases/download/v3.7.3/TVVLCKit.xcframework.zip",
            checksum: "f38ffd85741463eca27eb178017b3a4d8080ff8fb18781f163df3f7ca761cb53"
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
