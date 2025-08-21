// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AgentKit",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
    ],
    products: [
        .library(
            name: "AgentKit",
            targets: ["AgentKit"]
        ),
    ],
    targets: [
        .target(
            name: "AgentKit",
            path: "AgentKit",
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "AgentKitTests",
            dependencies: ["AgentKit"],
            path: "AgentKitTests"
        ),
    ]
)
