import HTTP
import Resolver
import Routing

struct RoutingMiddleware: Middleware {
    @Injected private(set) var router: Router

    init() {}

    func handle(
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
