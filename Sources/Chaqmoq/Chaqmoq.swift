/// The entry point for a Chaqmoq application. Manages routing, middleware, and server lifecycle.
public final class Chaqmoq: TrieRouter, @unchecked Sendable {
    /// The application's configuration.
    public let configuration: Configuration

    /// The environment the application is running in, such as `.development` or `.production`.
    public let environment: Environment

    /// The event loop group used by the underlying server.
    public var eventLoopGroup: EventLoopGroup { server.eventLoopGroup }

    /// The middleware pipeline. `RoutingMiddleware` is always the last entry and is added automatically —
    /// any `RoutingMiddleware` in the assigned value is removed before assignment to prevent duplication.
    public var middleware: [Middleware] {
        get { server.middleware }
        set { server.middleware = newValue.filter { !($0 is RoutingMiddleware) } + [RoutingMiddleware(router: self)] }
    }

    /// The error-handling middleware pipeline.
    public var errorMiddleware: [ErrorMiddleware] {
        get { server.errorMiddleware }
        set { server.errorMiddleware = newValue }
    }

    /// Called when an HTTP/1.1 connection is upgraded to WebSocket.
    ///
    /// Setting this to a non-`nil` value enables WebSocket upgrade support. Upgrade requests are
    /// intercepted by NIO's upgrade handler before they reach the routing middleware, so a WebSocket
    /// endpoint does not need — and will not match — a registered route.
    ///
    /// - Important: Set this before calling ``run()``.
    ///
    /// ```swift
    /// app.onUpgrade = { request, webSocket in
    ///     for await message in webSocket.messages {
    ///         if case .text(let text) = message { try await webSocket.send("echo: \(text)") }
    ///     }
    /// }
    /// ```
    public var onUpgrade: (@Sendable (Request, WebSocket) async throws -> Void)? {
        get { server.onUpgrade }
        set { server.onUpgrade = newValue }
    }

    /// Decides whether an HTTP/1.1 → WebSocket upgrade request is accepted.
    ///
    /// Returning `false` refuses the upgrade and lets the request continue through the normal HTTP
    /// pipeline. When `nil`, every upgrade request is accepted — validate the `Origin` header here to
    /// guard against cross-site WebSocket hijacking, since browsers attach cookies to the handshake
    /// but do not enforce CORS on it.
    ///
    /// - Important: This closure runs on the channel's event loop. Keep it fast and non-blocking.
    public var shouldUpgrade: ((Request) -> Bool)? {
        get { server.shouldUpgrade }
        set { server.shouldUpgrade = newValue }
    }

    let server: Server

    /// Creates a new Chaqmoq application.
    ///
    /// - Parameters:
    ///   - configuration: The application configuration. Defaults to `Configuration()`.
    ///   - environment: The environment to run in. Defaults to the `CHAQMOQ_ENV` process variable,
    ///     or `.development` if the variable is absent or empty.
    public init(
        configuration: Configuration = .init(),
        environment: Environment = .init()
    ) {
        self.configuration = configuration
        self.environment = environment
        server = Server(configuration: configuration.server)

        super.init()

        middleware = .init()
        errorMiddleware = .init()
    }
}

extension Chaqmoq {
    /// Starts the server and begins accepting incoming requests. Blocks until the server stops.
    ///
    /// Immediately before binding, the route trie is frozen (see ``freezeRoutes()``) so
    /// that request routing runs lock-free across every event-loop thread.
    ///
    /// - Important: Register all routes before calling `run()`. Routes added afterwards
    ///   are not served and registering concurrently with live traffic is unsafe.
    /// - Throws: An error if the server fails to start.
    public func run() throws {
        freezeRoutes()
        try server.start()
    }

    /// Replaces the request-routing middleware with one backed by a lock-free
    /// ``FrozenTrieRouter`` snapshot of the current routes.
    ///
    /// `TrieRouter.resolve` serialises every lookup on an internal lock, so under load
    /// all event-loop threads contend on a single mutex. Freezing produces an immutable
    /// router that resolves with zero synchronisation. Called automatically by ``run()``.
    ///
    /// The user middleware order is preserved; only the trailing ``RoutingMiddleware``
    /// is rebound from `self` (locked) to the frozen snapshot.
    public func freezeRoutes() {
        let frozen = build()
        let userMiddleware = server.middleware.filter { !($0 is RoutingMiddleware) }
        server.middleware = userMiddleware + [RoutingMiddleware(router: frozen)]
    }

    /// Stops the server and releases its resources.
    ///
    /// - Throws: An error if the server fails to stop.
    public func shutdown() throws {
        try server.stop()
    }
}

extension Chaqmoq {
    /// Holds configuration values for a Chaqmoq application.
    public struct Configuration: Equatable {
        /// A unique identifier for the application, such as a reverse domain name (e.g. `"dev.chaqmoq"`).
        public let identifier: String

        /// The path to the directory used to serve static files such as HTML, CSS, JavaScript, and images.
        /// Resolved relative to the working directory. Defaults to `"Public"`.
        public let publicDirectory: String

        /// The configuration for the underlying HTTP server.
        public var server: Server.Configuration

        /// Creates a new application configuration.
        ///
        /// - Parameters:
        ///   - identifier: A unique identifier for the application. Defaults to `"dev.chaqmoq"`.
        ///   - publicDirectory: Path to the static files directory, relative to the working directory.
        ///     Defaults to `"Public"`.
        ///   - server: The underlying server configuration. Defaults to `Server.Configuration()`.
        public init(
            identifier: String = "dev.chaqmoq",
            publicDirectory: String = "Public",
            server: Server.Configuration = .init()
        ) {
            self.identifier = identifier
            self.publicDirectory = publicDirectory
            self.server = server
        }
    }
}
