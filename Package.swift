// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MacLocalTranslator",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "MacLocalTranslator",
            targets: ["MacLocalTranslator"]
        ),
    ],
    dependencies: [
        // Only keep swift-algorithms as it's fetching correctly
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
        
        // Remove problematic dependencies:
        // - whisper.cpp
        // - swift-libre-translate
    ],
    targets: [
        .executableTarget(
            name: "MacLocalTranslator",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                // Remove references to external dependencies
                // Replace with stub implementations
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "MacLocalTranslatorTests",
            dependencies: ["MacLocalTranslator"],
            path: "Tests"
        ),
    ]
)
