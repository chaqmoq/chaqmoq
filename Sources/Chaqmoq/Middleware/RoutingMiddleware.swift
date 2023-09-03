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
    public func handle(
        request: Request,
        nextHandler: @escaping (Request) async throws -> Response
    ) async throws -> Response {
        if let route = router.resolve(request: request) {
            return try await handle(request: request, route: route)
        }

        return .init(status: .notFound)
    }

    private func handle(request: Request, route: Route, next index: Int = 0) async throws -> Response {
        if index > route.middleware.count - 1 {
            var request = request
            request.setAttribute("_route", value: route)
            let result = try await route.handler(request)

            return result as? Response ?? .init("\(result)")
        }

        return try await route.middleware[index].handle(request: request) { request in
            try await handle(request: request, route: route, next: index + 1)
        }
    }
}
