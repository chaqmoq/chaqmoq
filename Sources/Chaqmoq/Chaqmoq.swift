import HTTP
import Routing

/// Helps to create, start and stop `Chaqmoq` applications.
public final class Chaqmoq: RouteCollection.Builder {
    let server: Server
    let router: Router

    /// Initializes a new instance of `Chaqmoq` application with the default `Server` and `Router`.
    public init() {
        server = Server()
        router = Router()

        super.init()

        router.routes = routes
        onReceive()
    }

    /// Starts an application.
    ///
    /// - Throws: An error if an application can't be started.
    public func start() throws {
        try server.start()
    }

    /// Stops an application.
    ///
    /// - Throws: An error if an application can't be stopped.
    public func stop() throws {
        try server.stop()
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
            let result = middleware.handle(request: currentRequest) { request in
                currentRequest = request
            }

            if !(result is Void) {
                return result
            }
        }

        return route.handler(currentRequest)
    }
}