import Resolver

struct RoutingMiddleware: Middleware {
    @Injected private var router: Router

    func handle(
        request: Request,
        nextHandler: @escaping (Request) async -> Response
    ) async -> Response {
        if let route = router.resolve(request: request) {
            return await handle(
                request: request,
                route: route
            )
        }

        return .init(status: .notFound)
    }

    private func handle(
        request: Request,
        route: Route,
        next index: Int = 0
    ) async -> Response {
        if index > route.middleware.count - 1 {
            var request = request
            request.setAttribute("_route", value: route)

            do {
                let result = try await route.handler(request)
                return result as? Response ?? .init("\(result)")
            } catch {
                return Response(status: .internalServerError)
            }
        }

        return await route.middleware[index].handle(request: request) { request in
            await handle(
                request: request,
                route: route,
                next: index + 1
            )
        }
    }
}
