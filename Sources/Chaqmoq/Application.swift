import HTTP
import Routing

public final class Application {
    private let server: Server
    public let router: Router

    public init() {
        self.server = Server()
        self.router = Router()

        server.onReceive = { [weak self] request, eventLoop in
            if let uri = request.uri.string, let route = self?.router.resolveRouteBy(method: request.method, uri: uri) {
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
