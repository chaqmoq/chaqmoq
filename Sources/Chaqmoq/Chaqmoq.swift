/// The entry point for a Chaqmoq application. Manages routing, middleware, and server lifecycle.
public final class Chaqmoq: TrieRouter {
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
    /// - Throws: An error if the server fails to start.
    public func run() throws {
        try server.start()
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
