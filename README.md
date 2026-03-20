<div align="center">
    <h1><a href="https://chaqmoq.dev"><img src="https://chaqmoq.dev/logo.png" /></a></h1>
    <p>
        <a href="https://swift.org/download/#releases"><img src="https://img.shields.io/badge/swift-5.10+-brightgreen.svg" /></a>
        <a href="https://github.com/chaqmoq/chaqmoq/blob/master/LICENSE/"><img src="https://img.shields.io/badge/license-MIT-brightgreen.svg" /></a>
        <a href="https://github.com/chaqmoq/chaqmoq/actions"><img src="https://github.com/chaqmoq/chaqmoq/workflows/ci/badge.svg" /></a>
        <a href="https://www.codacy.com/gh/chaqmoq/chaqmoq/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=chaqmoq/chaqmoq&amp;utm_campaign=Badge_Grade"><img src="https://app.codacy.com/project/badge/Grade/b8dc8bdc13c94054911da004037776f4" /></a>
        <a href="https://codecov.io/gh/chaqmoq/chaqmoq"><img src="https://codecov.io/gh/chaqmoq/chaqmoq/branch/master/graph/badge.svg?token=9462JYGK4B" /></a>
        <a href="https://sonarcloud.io/project/overview?id=chaqmoq_chaqmoq"><img src="https://sonarcloud.io/api/project_badges/measure?project=chaqmoq_chaqmoq&metric=alert_status" /></a>
        <a href="https://chaqmoq.dev/chaqmoq/"><img src="https://github.com/chaqmoq/chaqmoq/raw/gh-pages/badge.svg" /></a>
        <a href="https://github.com/chaqmoq/chaqmoq/blob/master/CONTRIBUTING.md"><img src="https://img.shields.io/badge/contributing-guide-brightgreen.svg" /></a>
        <a href="https://t.me/chaqmoqdev"><img src="https://img.shields.io/badge/telegram-chaqmoqdev-brightgreen.svg" /></a>
    </p>
    <p><a href="https://chaqmoq.dev">Chaqmoq</a> is a non-blocking server-side web framework consisting of a set of reusable standalone packages and powered by fast, secure, and powerful <a href="https://swift.org">Swift</a> language and <a href="https://github.com/apple/swift-nio">SwiftNIO</a>. Read the <a href="https://docs.chaqmoq.dev">documentation</a> for more info.</p>
</div>

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Environments](#environments)
- [Routing](#routing)
- [Route Groups](#route-groups)
- [Middleware](#middleware)
- [Error Handling](#error-handling)
- [Request](#request)
- [Response](#response)
- [Running and Shutting Down](#running-and-shutting-down)
- [Testing](#testing)
- [Contributing](#contributing)
- [License](#license)

## Features

- **Non-blocking I/O** — built on [SwiftNIO](https://github.com/apple/swift-nio) for high-throughput, event-driven networking
- **Trie-based router** — fast route resolution with support for dynamic parameters
- **Flexible middleware** — composable app-level and route-level middleware pipelines
- **Ergonomic handlers** — return any `Encodable` value and the framework wraps it in a `200 OK` response automatically, or return an explicit `Response` for full control
- **Environment-aware** — built-in `production`, `development`, and `testing` environments configurable via a process variable
- **Modular architecture** — HTTP and routing are standalone packages that can be used independently

## Requirements

| Chaqmoq | Swift | Platforms |
|---|---|---|
| `master` | 5.10+ | macOS 12+, iOS 13+, tvOS 13+, watchOS 6+ |

## Installation

Add Chaqmoq to your `Package.swift`:

```swift
// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "MyApp",
    dependencies: [
        .package(url: "https://github.com/chaqmoq/chaqmoq.git", .branch("master"))
    ],
    targets: [
        .executableTarget(
            name: "MyApp",
            dependencies: [
                .product(name: "Chaqmoq", package: "chaqmoq")
            ]
        )
    ]
)
```

Then import the framework in your source files:

```swift
import Chaqmoq
```

## Getting Started

The following is a minimal application that starts an HTTP server and responds to `GET /`:

```swift
import Chaqmoq

let app = Chaqmoq()

app.get { _ in
    "Hello, World!"
}

try app.run()
```

`run()` blocks the calling thread until the server stops. Call `shutdown()` from another thread or signal handler to stop it gracefully.

## Configuration

`Chaqmoq` accepts a `Configuration` value that controls the application identifier, the static files directory, and the underlying server settings.

```swift
let configuration = Chaqmoq.Configuration(
    identifier: "com.myapp",
    publicDirectory: "Public",
    server: .init()
)

let app = Chaqmoq(configuration: configuration)
```

| Parameter | Type | Default | Description |
|---|---|---|---|
| `identifier` | `String` | `"dev.chaqmoq"` | A unique identifier for the application, such as a reverse domain name |
| `publicDirectory` | `String` | `"Public"` | Path to the static files directory, relative to the working directory |
| `server` | `Server.Configuration` | `.init()` | Configuration for the underlying HTTP server (port, TLS, etc.) |

## Environments

Chaqmoq supports runtime environments to vary behaviour across development, testing, and production without code changes.

```swift
// Use a built-in preset
let app = Chaqmoq(environment: .production)

// Use a custom environment
let app = Chaqmoq(environment: Environment(name: "staging"))
```

The environment defaults to the value of the `CHAQMOQ_ENV` process variable, falling back to `.development` if the variable is absent or empty:

```sh
CHAQMOQ_ENV=production swift run
```

**Built-in presets:**

| Preset | Name | Intended use |
|---|---|---|
| `.development` | `"development"` | Local development (default) |
| `.production` | `"production"` | Live deployments |
| `.testing` | `"testing"` | Automated test runs |

Read any process environment variable at runtime using:

```swift
let region = Environment.get("AWS_REGION")  // String? — nil if not set
```

Two `Environment` values are equal when their names match:

```swift
Environment(name: "staging") == Environment(name: "staging")  // true
```

## Routing

Routes are registered directly on the `Chaqmoq` instance. Handlers receive a `Request` and return any `Encodable` value or an explicit `Response`.

```swift
// Return a plain value — automatically wrapped in a 200 OK response
app.get { _ in
    "Hello, World!"
}

// Return a Codable struct
app.get("users") { _ in
    [User(id: 1, name: "Alice"), User(id: 2, name: "Bob")]
}

// Return an explicit Response for full control over status and headers
app.post("users") { request in
    let user = try request.body.decode(User.self)
    return Response(status: .created)
}
```

**Route parameters:**

Parameters use curly brace notation and support several forms:

| Syntax | Description |
|---|---|
| `{id}` | Captures any string |
| `{id<\\d+>}` | Captures a value matching a regex |
| `{page?1}` | Optional — falls back to `1` if omitted |
| `{id!1}` | Forced default — must be explicitly provided, defaults to `1` |
| `{id<\\d+>?1}` | Regex constraint combined with optional default |

```swift
app.get("users/{id<\\d+>}") { request in
    let id = request.route?[parameter: "id"] as? Int
    return "User \(id ?? 0)"
}

app.get("posts/{page?1}") { request in
    let page = request.route?[parameter: "page"] as? Int
    return "Page \(page ?? 1)"
}
```

Typed parameter extraction is available via subscript — `route?[parameter: "id"]` can be cast to `Int?`, `String?`, `UUID?`, or `Date?` depending on the captured value.

Constant segments always take priority over parameters at the same position, so `GET /posts/latest` and `GET /posts/{id<\\d+>}` can coexist without conflict.

**Supported HTTP methods:** `GET`, `POST`, `PUT`, `PATCH`, `DELETE`, `HEAD`, `OPTIONS`

## Route Groups

Route groups let you share a common path prefix and optional name prefix across multiple related routes, keeping registration concise and organised.

### Closure-based groups

`group(_:name:_:)` takes a path prefix, an optional name prefix, and a closure that receives a group object for registering nested routes:

```swift
app.group("/api/v1", name: "api.v1.") { v1 in
    v1.get("/users", name: "users.index") { _ in ... } // GET /api/v1/users
    v1.post("/users", name: "users.create") { _ in ... } // POST /api/v1/users
    v1.get("/users/{id}", name: "users.show") { _ in ... } // GET /api/v1/users/{id}
    v1.put("/users/{id}", name: "users.update") { _ in ... } // PUT /api/v1/users/{id}
    v1.delete("/users/{id}", name: "users.delete") { _ in ... } // DELETE /api/v1/users/{id}
}
```

The name prefix is composed automatically, so `name: "users.index"` inside a `"api.v1."` group becomes the full route name `"api.v1.users.index"`.

### Group middleware

Groups also accept a `middleware` parameter. The group-level middleware is prepended to any route-level middleware defined inside the group:

```swift
app.group("/admin", middleware: [AuthMiddleware()]) { admin in
    admin.get("/dashboard") { _ in ... } // AuthMiddleware runs first
    admin.get("/users", middleware: [LoggingMiddleware()]) { _ in ... } // AuthMiddleware, then LoggingMiddleware
}
```

### Value-returning groups

`grouped(_:name:)` returns a group object for use outside a closure:

```swift
let v2 = app.grouped("/api/v2", name: "api.v2.")
v2.get("/posts") { _ in ... }  // GET /api/v2/posts
```

### Nested groups

Groups can be nested to any depth — path and name prefixes compose automatically at each level:

```swift
app.group("/api") { api in
    api.group("/v1") { v1 in
        v1.get("/posts") { _ in ... }  // GET /api/v1/posts
    }
    api.group("/v2") { v2 in
        v2.get("/posts") { _ in ... }  // GET /api/v2/posts
    }
}
```

## Middleware

Middleware intercepts requests before they reach a route handler. It can inspect or modify the request, short-circuit with a response, or pass control to the next step in the pipeline.

### App-level middleware

App-level middleware runs for every request. Assign an array to `app.middleware` — `RoutingMiddleware` is always appended last automatically and should not be included manually.

```swift
app.middleware = [
    LoggingMiddleware(),
    CORSMiddleware(),
    AuthMiddleware()
]
```

Middleware executes in array order. In the example above, `LoggingMiddleware` runs first, then `CORSMiddleware`, then `AuthMiddleware`, and finally routing resolves the request to its handler.

### Route-level middleware

Route-level middleware runs only for a specific route, after app-level middleware:

```swift
app.get("admin", middleware: [RequireAdminMiddleware()]) { request in
    "Admin panel"
}
```

Multiple route-level middleware are applied in order:

```swift
app.post("upload", middleware: [AuthMiddleware(), RateLimitMiddleware()]) { request in
    // handle upload
}
```

### Writing middleware

Conform to the `Middleware` protocol and implement `handle(request:responder:)`. Call `responder(request)` to pass control to the next middleware or the route handler.

```swift
struct LoggingMiddleware: Middleware {
    func handle(request: Request, responder: @escaping Responder) async throws -> Encodable {
        print("→ \(request.method) \(request.url.path)")
        let response = try await responder(request)
        print("← \(response)")
        return response
    }
}
```

## Error Handling

Assign `ErrorMiddleware` conformers to `app.errorMiddleware` to handle errors thrown anywhere in the middleware pipeline or route handlers:

```swift
struct AppErrorMiddleware: ErrorMiddleware {
    func handle(error: Error, for request: Request) async -> Response {
        switch error {
        case let abort as AbortError:
            return Response(status: abort.status)
        default:
            return Response(status: .internalServerError)
        }
    }
}

app.errorMiddleware = [AppErrorMiddleware()]
```

Multiple error middleware are applied in order, giving each a chance to handle the error.

## Request

The `Request` object is passed to every middleware and route handler, exposing headers, body, URL, and route parameters.

```swift
app.get("greet/{name}") { request in
    let name = request.route?[parameter: "name"] as? String ?? "stranger"
    return "Hello, \(name)!"
}
```

Typed parameter extraction is done via `request.route?[parameter:]`, which returns `String?`, `Int?`, `UUID?`, or `Date?` depending on the captured value:

```swift
app.get("users/{id<\\d+>}") { request in
    let id = request.route?[parameter: "id"] as? Int
    return "User \(id ?? 0)"
}
```

**Matched route:** Once routing resolves, the matched `Route` is available via `request.route`. This property is `nil` in app-level middleware, since routing has not yet run at that point.

```swift
struct LoggingMiddleware: Middleware {
    func handle(request: Request, responder: @escaping Responder) async throws -> Encodable {
        // request.route is nil here — routing resolves after app-level middleware
        let response = try await responder(request)
        return response
    }
}

app.get("hello") { request in
    // request.route is set here
    print(request.route?.path ?? "unknown")
    return "Hello!"
}
```

## Response

Return any `Encodable` value from a route handler and the framework serialises it and wraps it in a `200 OK` response:

```swift
app.get { _ in "Hello" } // 200 OK, body: "Hello"
app.get("count") { _ in 1 } // 200 OK, body: 1
app.get("user") { _ in // 200 OK, body: JSON-encoded User
    User(id: 1, name: "Alice")
}
```

Return an explicit `Response` when you need control over the status code or headers:

```swift
app.post("users") { request in
    return Response(status: .created)
}

app.delete("users/{id}") { request in
    return Response(status: .noContent)
}
```

## Running and Shutting Down

`run()` starts the server and blocks the calling thread. It throws if the server fails to start:

```swift
try app.run()
```

`shutdown()` stops the server and releases its resources. Because `run()` blocks, `shutdown()` must be called from a different thread — for example, from a signal handler:

```swift
let source = DispatchSource.makeSignalSource(signal: SIGTERM, queue: .global())
source.setEventHandler { try? app.shutdown() }
source.resume()

try app.run()
```

A `DispatchSemaphore` can guarantee that `shutdown()` is called only after the server is fully started:

```swift
let semaphore = DispatchSemaphore(value: 0)
app.server.onStart = { _ in semaphore.signal() }

DispatchQueue.global().async {
    semaphore.wait()
    try? app.shutdown()
}

try app.run()
```

## Testing

Run the full test suite with:

```sh
swift test
```

When writing tests for your own routes, use `Environment.testing` and `EmbeddedEventLoop` from SwiftNIO for a lightweight, synchronous event loop:

```swift
import XCTest
@testable import Chaqmoq

final class MyRouteTests: XCTestCase {
    func testGreetRoute() async throws {
        // Arrange
        let app = Chaqmoq(environment: .testing)
        let middleware = RoutingMiddleware(router: app)
        let request = Request(eventLoop: EmbeddedEventLoop())
        app.get { _ in "Hello, World!" }

        // Act
        let result = try await middleware.handle(request: request) { _ in fatalError() }
        let response = try XCTUnwrap(result as? Response)

        // Assert
        XCTAssertEqual(response.status, .ok)
    }
}
```

## Contributing

Contributions are welcome. Please read the [Contributing Guide](CONTRIBUTING.md) before opening a pull request:

1. Fork the repository and create a branch from `master`
2. Add tests for any new behaviour
3. Update documentation for any API changes
4. Ensure `swift test` passes and the code lints cleanly
5. Open a pull request

Bug reports and feature requests go through [GitHub Issues](https://github.com/chaqmoq/chaqmoq/issues). The project follows [Swift's API Design Guidelines](https://swift.org/documentation/api-design-guidelines/) and enforces style via [SwiftLint](https://github.com/realm/SwiftLint) (4-space indentation, 120-character line limit).

## License

Chaqmoq is released under the [MIT License](LICENSE).
