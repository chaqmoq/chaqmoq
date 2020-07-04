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

            if let result = weakSelf.execute(request: request, on: route.middleware) {
                return result
            }

            return route.handler(request)
        }
    }

    private func execute(request: Request, on middleware: [Middleware]) -> Any? {
        var index = 0
        let count = middleware.count

        while index < count {
            let oneMiddleware = middleware[index]
            let nextIndex = index + 1
            var nextMiddleware: Middleware?

            if nextIndex < count {
                nextMiddleware = middleware[nextIndex]
            }

            if let nextMiddleware = nextMiddleware {
                let result = oneMiddleware.handle(request: request, next: nextMiddleware)

                if !(result is Middleware) {
                    return result
                }
            } else {
                return nil
            }

            index = nextIndex
        }

        return nil
    }
}
