// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GPTApp",
    platforms: [.macOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "GPTApp",
            targets: ["GPTApp"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", exact: "0.52.0"),
        .package(url: "https://github.com/erikolsson/SwiftDown.git", branch: "develop"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", exact: "4.2.2"),
        .package(url: "https://github.com/smittytone/HighlighterSwift.git", exact: "1.1.2"),
        .package(url: "https://github.com/groue/GRDB.swift.git", revision: "ba68e3b02d9ed953a0c9ff43183f856f20c9b7ce"),
    ],
    targets: [
        .target(name: "Common",
               dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "KeychainAccess", package: "KeychainAccess"),
                .product(name: "GRDB", package: "GRDB.swift")
               ]),
        .target(name: "API",
               dependencies: [
                "Common"
               ]),
        .target(name: "Settings",
               dependencies: [
                "Common",
                "API",
               ]),
        .target(name: "Chat",
               dependencies: [
                "Common",
                "API",
                .product(name: "SwiftDown", package: "SwiftDown"),
                .product(name: "Highlighter", package: "HighlighterSwift")
               ]),
        .target(
            name: "GPTApp",
            dependencies: [
               "Chat",
               "Settings",
            ]),
        .testTarget(
            name: "GPTAppTests",
            dependencies: ["GPTApp"]),
    ]
)
