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
        // Dépendance pour Whisper.cpp (reconnaissance vocale)
        .package(url: "https://github.com/ggerganov/whisper.cpp", from: "1.0.0"),
        
        // Dépendance pour l'interface utilisateur
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
        
        // Dépendance pour la traduction (LibreTranslate API client)
        .package(url: "https://github.com/LibreTranslate/swift-libre-translate", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "MacLocalTranslator",
            dependencies: [
                .product(name: "whisper", package: "whisper.cpp"),
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "LibreTranslate", package: "swift-libre-translate"),
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
