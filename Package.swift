// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "chaqmoq",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(name: "Chaqmoq", targets: ["Chaqmoq"])
    ],
    dependencies: [
        .package(url: "https://github.com/chaqmoq/http.git", branch: "master"),
        .package(url: "https://github.com/chaqmoq/routing.git", branch: "master")
    ],
    targets: [
        .target(name: "Chaqmoq", dependencies: [
            .product(name: "HTTP", package: "http"),
            .product(name: "Routing", package: "routing")
        ]),
        .testTarget(name: "ChaqmoqTests", dependencies: [
            .target(name: "Chaqmoq")
        ])
    ],
    swiftLanguageVersions: [.v5]
)
