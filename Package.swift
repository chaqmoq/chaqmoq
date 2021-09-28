// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "chaqmoq",
    products: [
        .library(name: "Chaqmoq", targets: ["Chaqmoq"])
    ],
    dependencies: [
        .package(name: "chaqmoq-http", url: "https://github.com/chaqmoq/http.git", .branch("master")),
        .package(name: "chaqmoq-routing", url: "https://github.com/chaqmoq/routing.git", .branch("master"))
    ],
    targets: [
        .target(name: "Chaqmoq", dependencies: [
            .product(name: "HTTP", package: "chaqmoq-http"),
            .product(name: "Routing", package: "chaqmoq-routing")
        ]),
        .testTarget(name: "ChaqmoqTests", dependencies: [
            .target(name: "Chaqmoq")
        ])
    ],
    swiftLanguageVersions: [.v5]
)
