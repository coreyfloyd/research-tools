// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "transcribe",
    platforms: [.macOS(.v26)],
    products: [
        .library(name: "TranscribeKit", targets: ["TranscribeKit"]),
        .executable(name: "transcribe", targets: ["transcribe"]),
    ],
    targets: [
        .target(name: "TranscribeKit"),
        .executableTarget(name: "transcribe", dependencies: ["TranscribeKit"]),
        .testTarget(name: "TranscribeKitTests", dependencies: ["TranscribeKit"]),
    ]
)
