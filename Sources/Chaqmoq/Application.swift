import HTTP
import Routing

public final class Application: RouteCollection.Builder {
    let server: Server
    let router: Router

    public init() {
        server = Server()
        router = Router()

        super.init()

        router.routes = routes
        onReceive()
    }

    public func start() throws {
        try server.start()
    }

    public func stop() throws {
        try server.stop()
    }
}

extension Application {
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
        var routeHandler = route.handler

        for middleware in route.middleware {
            let result = middleware.handle(request: request, nextHandler: routeHandler)

            if let result = result as? Route.Handler {
                routeHandler = result
            } else {
                return result
            }
        }

        return routeHandler(request)
    }
}
