import HTTP
import Resolver
import Routing

public struct RoutingMiddleware: Middleware {
    @Injected public private(set) var router: Router

    public func handle(request: Request, nextHandler: @escaping (Request) -> Response) -> Response {
        if let route = router.resolveRoute(for: request) {
            var request = request
            request.setAttribute("_route", value: route)

            return handle(request: request, route: route, middleware: route.middleware)
        }

        return Response(status: .notFound)
    }

    private func handle(request: Request, route: Route) -> Response {
        let result = route.handler(request)
        if let response = result as? Response { return response }

        return Response("\(result)")
    }

    private func handle(
        request: Request,
        route: Route,
        middleware: [Middleware],
        nextIndex index: Int = 0
    ) -> Response {
        let lastIndex = middleware.count - 1
        if index > lastIndex { return handle(request: request, route: route) }

        return middleware[index].handle(request: request) { [self] request in
            if index == lastIndex { return handle(request: request, route: route) }
            return handle(request: request, route: route, middleware: middleware, nextIndex: index + 1)
        }
    }
}
