// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "chaqmoq",
    platforms: [
        .iOS(.v13),
        .macOS(.v12),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(name: "Chaqmoq", targets: ["Chaqmoq"])
    ],
    dependencies: [
        .package(name: "chaqmoq-http", url: "https://github.com/chaqmoq/http.git", .branch("master")),
        .package(name: "chaqmoq-resolver", url: "https://github.com/chaqmoq/resolver.git", .branch("master")),
        .package(name: "chaqmoq-routing", url: "https://github.com/chaqmoq/routing.git", .branch("master"))
    ],
    targets: [
        .target(name: "Chaqmoq", dependencies: [
            .product(name: "HTTP", package: "chaqmoq-http"),
            .product(name: "Resolver", package: "chaqmoq-resolver"),
            .product(name: "Routing", package: "chaqmoq-routing")
        ]),
        .testTarget(name: "ChaqmoqTests", dependencies: [
            .target(name: "Chaqmoq")
        ])
    ],
    swiftLanguageVersions: [.v5]
)
