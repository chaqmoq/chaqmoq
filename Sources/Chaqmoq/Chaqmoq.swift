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
    private var middleware: [Middleware] = .init()

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
        onReceive()
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
    public func addMiddleware(_ middleware: Middleware...) {
        self.middleware = middleware
    }

    public func addMiddleware(_ middleware: [Middleware]) {
        self.middleware = middleware
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

extension Chaqmoq {
    private func onReceive() {
        server.onReceive = { [self] request, _ in
            handle(request: request, lastIndex: middleware.count - 1)
        }
    }

    private func handle(
        request: Request,
        response: Response = .init(),
        nextIndex index: Int = 0,
        lastIndex: Int
    ) -> Response {
        if index <= lastIndex {
            return middleware[index].handle(request: request) { [self] request in
                handle(request: request, response: response, nextIndex: index + 1, lastIndex: lastIndex)
            }
        }

        return response
    }
}
