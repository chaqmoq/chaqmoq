import Foundation
import HTTP
import Resolver
import Routing

/// Helps to create, run and shutdown `Chaqmoq` applications.
public final class Chaqmoq: RouteCollection.Builder {
    public let configuration: Configuration
    public let resolver: Resolver = .main
    let server: Server

    public var eventLoopGroup: EventLoopGroup { server.eventLoopGroup }
    public var middleware: [Middleware] {
        get { server.middleware }
        set { server.middleware = newValue }
    }

    /// Initializes a new instance of `Chaqmoq` application with the default `Configuration`.
    ///
    /// - Parameters:
    ///   - configuration: An app `Configuration`.
    public init(configuration: Configuration = .init()) {
        self.configuration = configuration
        server = Server(configuration: configuration.server)

        super.init()

        resolver.register(scoped: .singleton) { _ in Router() }
        let router: Router = resolver.resolve()!
        router.routes = routes
    }
}

extension Chaqmoq {
    /// Runs an application.
    ///
    /// - Throws: An error if an application can't be run.
    public func run() throws {
        try server.start()
    }

    /// Shutdowns an application.
    ///
    /// - Throws: An error if an application can't be shutdown.
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
