// swift-tools-version: 5.8.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "myndsmith",
    products: [
        .library(name: "SDL2",
                 targets: ["SDL2"]),
        .library(name: "SDL2_Image",
                 targets: ["SDL2_Image"]),
        .library(name: "SDL2_Mixer",
                 targets: ["SDL2_Mixer"]),
        .library(name: "SDL2_TTF",
                 targets: ["SDL2_TTF"]),
        .library(name: "BGFX",
                 targets: ["BGFX"]),
    ],
    targets: [
        .target(name: "SDL2",
                dependencies: [
                    .target(name: "RAW_SDL2", condition: .when(platforms: [.windows])),
                ],
                path: "Sources/SDL2"),
        .target(name: "SDL2_Image",
                dependencies: [
                    .target(name: "RAW_SDL2_IMAGE", condition: .when(platforms: [.windows])),
                    .target(name: "RAW_SDL2", condition: .when(platforms: [.windows])),
                ],
                path: "Sources/SDL2_IMAGE"),
        .target(name: "SDL2_Mixer",
                dependencies: [
                    .target(name: "RAW_SDL2_MIXER", condition: .when(platforms: [.windows])),
                ],
                path: "Sources/SDL2_MIXER"),
        .target(name: "SDL2_TTF",
                dependencies: [
                    .target(name: "RAW_SDL2_TTF", condition: .when(platforms: [.windows])),
                    .target(name: "RAW_SDL2", condition: .when(platforms: [.windows])),
                ],
                path: "Sources/SDL2_TTF"),
        .target(name: "BGFX",
                dependencies: [
                    .target(name: "RAW_BGFX", condition: .when(platforms: [.windows])),
                ],
                path: "Sources/BGFX",
                linkerSettings: [
                    .linkedLibrary("BX"),
                    .linkedLibrary("BIMG"),
                    .linkedLibrary("BIMG_ENCODE"),
                    .linkedLibrary("BIMG_DECODE")

                ]),
        .testTarget(name: "TestSDL", dependencies: ["SDL2","SDL2_Image","SDL2_Mixer","SDL2_TTF", "BGFX"], path: "Tests/"),
        .systemLibrary(
            name: "RAW_SDL2"
        ),
        .systemLibrary(
            name: "RAW_SDL2_IMAGE"
        ),
        .systemLibrary(
            name: "RAW_SDL2_MIXER"
        ),
        .systemLibrary(
            name: "RAW_SDL2_TTF"
        ),
        .systemLibrary(
            name: "RAW_BGFX"
        ),
        .executableTarget(
            name: "SampleSDL2", dependencies: ["SDL2","SDL2_Image","SDL2_Mixer","SDL2_TTF","BGFX"], path: "Sources/SampleSDL2"),
        .executableTarget(
            name: "SampleBGFX", dependencies: ["SDL2","SDL2_Image","SDL2_Mixer","SDL2_TTF","BGFX"], path: "Sources/SampleBGFX"),

    ]
)
