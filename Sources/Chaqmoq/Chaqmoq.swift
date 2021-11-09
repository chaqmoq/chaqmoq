import Foundation
import HTTP
import Resolver
import Routing

/// Helps to create, run, and shutdown `Chaqmoq` applications.
public final class Chaqmoq: RouteCollection.Builder {
    public let environment: Environment
    public let configuration: Configuration
    public let resolver: Resolver
    let server: Server

    public var eventLoopGroup: EventLoopGroup { server.eventLoopGroup }
    public var middleware: [Middleware] {
        get { server.middleware }
        set { server.middleware = newValue }
    }

    /// Initializes a new instance of `Chaqmoq` application.
    ///
    /// - Parameters:
    ///   - configuration: An application's `Configuration`.
    ///   - environment: An application's `Environment`. Defaults to `.development`.
    ///   - resolver: An instance of dependency injection container. Defaults to `.main`.
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

        middleware = [RoutingMiddleware()]
        resolver.register(scoped: .singleton) { [self] _ in Router(routes: routes) }
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
    public struct Configuration {
        public let identifier: String
        public let publicDirectory: String
        public var server: Server.Configuration

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
