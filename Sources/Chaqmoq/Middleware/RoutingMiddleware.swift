struct RoutingMiddleware: Middleware {
    private let router: Router

    init(router: Router) {
        self.router = router
    }

    func handle(
        request: Request,
        responder: @escaping Responder
    ) async throws -> Encodable {
        if let route = router.resolve(request: request) {
            return try await handle(
                request: request,
                route: route
            )
        }

        return Response(status: .notFound)
    }

    private func handle(
        request: Request,
        route: Route,
        next index: Int = 0
    ) async throws -> Encodable {
        if index > route.middleware.count - 1 {
            var request = request
            request.setAttribute(
                "_route",
                value: route
            )

            return try await route.handler(request)
        }

        return try await route.middleware[index].handle(request: request) { request in
            try await handle(
                request: request,
                route: route,
                next: index + 1
            )
        }
    }
}
