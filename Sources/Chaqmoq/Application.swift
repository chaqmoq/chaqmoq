import HTTP
import Routing

public final class Application {
    public var routes: RouteCollection { router.routes }

    let server: Server
    let router: Router

    public init() {
        self.server = Server()
        self.router = Router()

        server.onReceive = { [weak self] request, eventLoop in
            guard
                let uri = request.uri.string,
                let route = self?.router.resolveRouteBy(method: request.method, uri: uri) else {
                    return Response(status: .notFound)
            }

            return route.requestHandler(request)
        }
    }

    public func start() throws {
        try server.start()
    }

    public func stop() throws {
        try server.stop()
    }
}
