import HTTP
import Resolver
import Routing

public struct RoutingMiddleware: Middleware {
    @Injected private var router: Router

    public func handle(request: Request, nextHandler: @escaping (Request) -> Response) -> Response {
        var request = request

        if let uri = request.uri.string, let route = router.resolveRouteBy(method: request.method, uri: uri) {
            if let parameters = route.parameters {
                for parameter in parameters {
                    request.uri.parameters[parameter.name] = parameter.value
                }
            }

            let result = route.handler(request)
            if let response = result as? Response { return response }
            return Response("\(result)")
        }

        return Response(status: .notFound)
    }
}
