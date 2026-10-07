// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PKpowerlines",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "PKpowerlines", targets: ["PKpowerlines"])
    ],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.7.0")
    ],
    targets: [
        .executableTarget(
            name: "PKpowerlines",
            dependencies: [
                .product(name: "Sparkle", package: "Sparkle")
            ],
            path: "src/macos",
            exclude: [
                // Copiés dans le .app par build_app.sh (chargés via Bundle.main, pas le bundle SwiftPM)
                "Resources/ProjectIcons",
                "Resources/ProjectScreenshots"
            ],
            resources: [
                .process("Resources")
            ],
            linkerSettings: [
                .linkedFramework("IOKit")
            ]
        )
    ]
)
