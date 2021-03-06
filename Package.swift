// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "chaqmoq",
    products: [
        .library(name: "Chaqmoq", targets: ["Chaqmoq"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.4.0"),
        .package(name: "chaqmoq-http", url: "https://github.com/chaqmoq/http.git", .branch("master")),
        .package(name: "chaqmoq-mime", url: "https://github.com/chaqmoq/mime.git", .branch("master")),
        .package(name: "chaqmoq-routing", url: "https://github.com/chaqmoq/routing.git", .branch("master")),
        .package(name: "chaqmoq-validation", url: "https://github.com/chaqmoq/validation.git", .branch("master")),
        .package(name: "yaproq", url: "https://github.com/yaproq/yaproq.git", .branch("master"))
    ],
    targets: [
        .target(name: "Chaqmoq", dependencies: [
            .product(name: "Logging", package: "swift-log"),
            .product(name: "HTTP", package: "chaqmoq-http"),
            .product(name: "MIME", package: "chaqmoq-mime"),
            .product(name: "Routing", package: "chaqmoq-routing"),
            .product(name: "Validation", package: "chaqmoq-validation"),
            .product(name: "Yaproq", package: "yaproq")
        ]),
        .testTarget(name: "ChaqmoqTests", dependencies: [
            .target(name: "Chaqmoq")
        ])
    ],
    swiftLanguageVersions: [.v5]
)
