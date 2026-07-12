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
            path: "src/macos/PKpowerlines",
            linkerSettings: [
                .linkedFramework("IOKit")
            ]
        )
    ]
)
