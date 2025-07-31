// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "SwiftInjectLite",
    platforms: [.iOS(.v14), .macOS(.v11), .watchOS(.v8), .tvOS(.v14)],
    products: [
        .library(
            name: "SwiftInjectLite",
            targets: ["SwiftInjectLite"]),
    ],
    targets: [
        .target(name: "SwiftInjectLite", path: "Sources/SwiftInjectLite"),
        .testTarget(name: "SwiftInjectLiteTests", dependencies: ["SwiftInjectLite"]
        ),
    ]
)
