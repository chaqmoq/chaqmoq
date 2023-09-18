import Foundation
import HTTP
import Resolver
import Routing

/// Helps to create, run, and shut down `Chaqmoq` applications.
public final class Chaqmoq: TrieRouter {
    /// The current application's `Configuration`.
    public let configuration: Configuration

    /// The current application's `Environment`.
    public let environment: Environment

    /// The current application's `EventLoopGroup`.
    public var eventLoopGroup: EventLoopGroup { server.eventLoopGroup }

    /// A list of registered `Middleware`.
    public var middleware: [Middleware] {
        get { server.middleware }
        set { server.middleware = newValue + [RoutingMiddleware()] }
    }

    /// The current application's dependency injection container for services.
    public let resolver: Resolver

    let server: Server

    /// Initializes a new instance of `Chaqmoq` application.
    ///
    /// - Parameters:
    ///   - configuration: A `Configuration` for an application.
    ///   - environment: An `Environment` for an application. Defaults to `.development`.
    ///   - resolver: An application's dependency injection container for services. Defaults to `.main`.
    public init(
        configuration: Configuration = .init(),
        environment: Environment = .init(),
        resolver: Resolver = .main
    ) {
        self.configuration = configuration
        self.environment = environment
        self.resolver = resolver
        server = Server(configuration: configuration.server)

        super.init()

        resolver.register(Router.self, scoped: .singleton) { [unowned self] _ in self }
        middleware = .init()
    }
}

extension Chaqmoq {
    /// Runs an application.
    ///
    /// - Throws: An error if an application can't be run.
    public func run() throws {
        try server.start()
    }

    /// Shuts down an application.
    ///
    /// - Throws: An error if an application can't be shut down.
    public func shutdown() throws {
        try server.stop()
    }
}

extension Chaqmoq {
    /// Manages an application's `Configuration`.
    public struct Configuration: Equatable {
        /// A unique identifier for an application. For example, a reverse domain name like `dev.chaqmoq`.
        public let identifier: String

        /// A path to a directory for public resource files like javascript, css, images, etc.
        public let publicDirectory: String

        /// A server configuration.
        public var server: Server.Configuration

        /// Initializes a new instance of `Configuration`.
        ///
        /// - Parameters:
        ///   - identifier: A unique identifier for an application. Defaults to `dev.chaqmoq`.
        ///   - publicDirectory: A path to a directory for public resource files like javascript, css, images, etc. Defaults to the root directory.
        ///   - server: A server configuration. Defaults to the default `Server.Configuration`.
        public init(
            identifier: String = "dev.chaqmoq",
            publicDirectory: String = "/",
            server: Server.Configuration = .init()
        ) {
            self.identifier = identifier
            self.publicDirectory = publicDirectory
            self.server = server
        }
    }
}
