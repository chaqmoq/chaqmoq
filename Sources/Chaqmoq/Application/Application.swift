import HTTP
import Routing

public final class Application {
    let server: Server
    var router: Router

    public var routes: RouteCollection { router.routes }

    public init() {
        self.server = Server()
        self.router = DefaultRouter()

        server.onReceive = { [weak self] request, eventLoop in
            if let route = self?.router.resolveRouteBy(method: request.method, uri: request.uri.string ?? "/") {
                return route.requestHandler(request)
            }

            return Response(status: .notFound)
        }
    }

    public func start() throws {
        try server.start()
    }

    public func stop() throws {
        try server.stop()
    }
}
