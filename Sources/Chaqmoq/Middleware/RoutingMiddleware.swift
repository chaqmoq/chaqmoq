import HTTP
import Resolver
import Routing

public struct RoutingMiddleware: Middleware {
    @Injected private var router: Router

    public func handle(request: Request, nextHandler: @escaping (Request) -> Response) -> Response {
        var request = request

        if let route = router.resolveRoute(for: request) {
            request.uri.setParameter("_route", value: route)

            if let parameters = route.parameters {
                for parameter in parameters {
                    request.uri.setParameter(parameter.name, value: parameter.value)
                }
            }

            let result = route.handler(request)
            if let response = result as? Response { return response }
            return Response("\(result)")
        }

        return Response(status: .notFound)
    }
}
