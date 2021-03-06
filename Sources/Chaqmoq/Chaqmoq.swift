import Foundation
import HTTP
import Logging
import Routing
import Yaproq

/// Helps to create, run and shutdown `Chaqmoq` applications.
public final class Chaqmoq: RouteCollection.Builder {
    public let configuration: Configuration
    public let logger: Logger
    public let router: Router
    public let server: Server
    public let templating: Yaproq

    public var eventLoopGroup: EventLoopGroup { server.eventLoopGroup }

    /// Initializes a new instance of `Chaqmoq` application with the default `Configuration`.
    /// - Parameters:
    ///   - configuration: An app `Configuration`.
    public init(configuration: Configuration = .init()) {
        self.configuration = configuration
        logger = Logger(label: configuration.identifier)
        router = Router()
        server = Server(configuration: configuration.server)
        templating = Yaproq(configuration: configuration.templating)

        super.init()

        router.routes = routes
        onReceive()
    }

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
        public var templating: Yaproq.Configuration

        public init(
            identifier: String = "dev.chaqmoq.chaqmoq",
            publicDirectory: String = "/",
            server: Server.Configuration = .init(),
            templating: Yaproq.Configuration = .init()
        ) {
            self.identifier = identifier
            self.publicDirectory = publicDirectory
            self.server = server
            self.templating = templating
        }
    }
}

extension Chaqmoq {
    /// Generates a URL for `Route` by name, path's parameters and query strings.
    ///
    /// - Parameters:
    ///   - name: A unique name for `Route`.
    ///   - parameters: A `Route`'s path parameters. Defaults to `nil`.
    ///   - query: A dictionary of query strings. Defaults to `nil`.
    /// - Returns: A generated URL or `nil`.
    public func generateURLForRoute(
        named name: String,
        parameters: Parameters<String, String>? = nil,
        query: Parameters<String, String>? = nil
    ) -> URL? {
        router.generateURLForRoute(named: name, parameters: parameters, query: query)
    }
}

extension Chaqmoq {
    private func onReceive() {
        server.onReceive = { [weak self] request, eventLoop in
            guard
                let weakSelf = self,
                let uri = request.uri.string,
                let route = weakSelf.router.resolveRouteBy(method: request.method, uri: uri) else {
                    return Response(status: .notFound)
            }

            return weakSelf.handle(request: request, on: route)
        }
    }

    private func handle(request: Request, on route: Route) -> Any {
        var currentRequest = request

        for middleware in route.middleware {
            let result = middleware.handle(request: currentRequest) { request in currentRequest = request }
            if !(result is Void) { return result }
        }

        return route.handler(currentRequest)
    }
}
