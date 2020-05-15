// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "chaqmoq",
    products: [
        .library(name: "Chaqmoq", targets: ["Chaqmoq"])
    ],
    dependencies: [
        .package(url: "https://github.com/chaqmoq/http.git", .branch("master")),
        .package(url: "https://github.com/chaqmoq/routing.git", .branch("master")),
        .package(url: "https://github.com/chaqmoq/validation.git", .branch("master"))
    ],
    targets: [
        .target(name: "Chaqmoq", dependencies: ["HTTP", "Routing", "Validation"]),
        .testTarget(name: "ChaqmoqTests", dependencies: ["Chaqmoq"])
    ],
    swiftLanguageVersions: [.v5]
)
