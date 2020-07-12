# Chaqmoq - A server-side web framework in Swift
[![Swift](https://img.shields.io/badge/swift-5.1-brightgreen.svg)](https://swift.org/download/#releases) [![MIT License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](https://github.com/chaqmoq/chaqmoq/blob/master/LICENSE/) [![Actions Status](https://github.com/chaqmoq/chaqmoq/workflows/development/badge.svg)](https://github.com/chaqmoq/chaqmoq/actions) [![Codacy Badge](https://app.codacy.com/project/badge/Grade/b8dc8bdc13c94054911da004037776f4)](https://www.codacy.com/gh/chaqmoq/chaqmoq?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=chaqmoq/chaqmoq&amp;utm_campaign=Badge_Grade) [![Contributing](https://img.shields.io/badge/contributing-guide-brightgreen.svg)](https://github.com/chaqmoq/chaqmoq/blob/master/CONTRIBUTING.md) [![Twitter](https://img.shields.io/badge/twitter-chaqmoqdev-brightgreen.svg)](https://twitter.com/chaqmoqdev)

## Installation
### Swift
Download and install [Swift](https://swift.org/download)

### Swift Package
#### Shell
```shell
mkdir MyApp
cd MyApp
swift package init --type executable // Creates an executable app named "MyApp"
```

#### Package.swift
```swift
// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "MyApp",
    dependencies: [
        .package(url: "https://github.com/chaqmoq/chaqmoq.git", .branch("master"))
    ],
    targets: [
        .target(name: "MyApp", dependencies: ["Chaqmoq"]),
        .testTarget(name: "MyAppTests", dependencies: ["MyApp"])
    ]
)
```

## Usage
### main.swift
```swift
import Chaqmoq

let app = Chaqmoq()
app.get { _ in
    "Hello World"
}
try app.start()
```

### Shell
```shell
swift build -c release
swift run
```
