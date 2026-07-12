// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Maram",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "Maram", targets: ["Maram"])
    ],
    targets: [
        .executableTarget(
            name: "Maram",
            path: "src/macos/Maram",
            linkerSettings: [
                .linkedFramework("IOKit")
            ]
        )
    ]
)
