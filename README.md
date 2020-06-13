# Framework component
[![Swift](https://img.shields.io/badge/swift-5.1-brightgreen.svg)](https://swift.org/download/#releases) [![MIT License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](https://github.com/chaqmoq/chaqmoq/blob/master/LICENSE/) [![Actions Status](https://github.com/chaqmoq/chaqmoq/workflows/development/badge.svg)](https://github.com/chaqmoq/chaqmoq/actions) [![Codacy Badge](https://app.codacy.com/project/badge/Grade/b8dc8bdc13c94054911da004037776f4)](https://www.codacy.com/gh/chaqmoq/chaqmoq?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=chaqmoq/chaqmoq&amp;utm_campaign=Badge_Grade) [![Contributing](https://img.shields.io/badge/contributing-guide-brightgreen.svg)](https://github.com/chaqmoq/chaqmoq/blob/master/CONTRIBUTING.md) [![Twitter](https://img.shields.io/badge/twitter-chaqmoqdev-brightgreen.svg)](https://twitter.com/chaqmoqdev)

## Installation

### Package.swift
```swift
let package = Package(
    // ...
    dependencies: [
        // Other packages...
        .package(url: "https://github.com/chaqmoq/chaqmoq.git", .branch("master"))
    ],
    targets: [
        // Other targets...
        .target(name: "...", dependencies: ["Chaqmoq"])
    ]
)
```
