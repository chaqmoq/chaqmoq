import HTTP
import Resolver
import Routing

public struct RoutingMiddleware: Middleware {
    @Injected private var router: Router

    public func handle(request: Request, nextHandler: @escaping (Request) -> Response) -> Response {
        if let route = router.resolveRoute(for: request) {
            var request = request
            request.setAttribute("_route", value: route)

            let result = route.handler(request)
            if let response = result as? Response { return response }

            return Response("\(result)")
        }

        return Response(status: .notFound)
    }
}
