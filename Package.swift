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
    targets: [
        .executableTarget(
            name: "PKpowerlines",
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
