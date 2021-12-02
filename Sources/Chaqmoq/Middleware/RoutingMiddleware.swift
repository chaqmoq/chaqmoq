import HTTP
import Resolver
import Routing

/// Resolves a `Route` for a `Request` and calls its handler method. Returns a `.notFound` `Response` if it can't match any `Route`s. By default, the
/// `RoutingMiddleware` is already registered for `Chaqmoq` applications. If you override the `middleware` property, make sure you add it explicitly.
/// Keep in mind that it is almost always better to register the `RoutingMiddleware` at the end of `Middleware` stack.
public struct RoutingMiddleware: Middleware {
    /// The current application's `Router`.
    @Injected public private(set) var router: Router

    /// Initializes a new instance of `RoutingMiddleware`.
    public init() {}

    /// See `Middleware`.
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
