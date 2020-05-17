import HTTP
import Routing

extension Application {
    @discardableResult
    public func delete(_ path: String, name: String? = nil, requestHandler: @escaping Route.RequestHandler) -> Route? {
        return request(methods: [.DELETE], path: path, name: name, requestHandler: requestHandler).first
    }

    @discardableResult
    public func get(_ path: String, name: String? = nil, requestHandler: @escaping Route.RequestHandler) -> Route? {
        return request(methods: [.GET], path: path, name: name, requestHandler: requestHandler).first
    }

    @discardableResult
    public func head(_ path: String, name: String? = nil, requestHandler: @escaping Route.RequestHandler) -> Route? {
        return request(methods: [.HEAD], path: path, name: name, requestHandler: requestHandler).first
    }

    @discardableResult
    public func options(_ path: String, name: String? = nil, requestHandler: @escaping Route.RequestHandler) -> Route? {
        return request(methods: [.OPTIONS], path: path, name: name, requestHandler: requestHandler).first
    }

    @discardableResult
    public func patch(_ path: String, name: String? = nil, requestHandler: @escaping Route.RequestHandler) -> Route? {
        return request(methods: [.PATCH], path: path, name: name, requestHandler: requestHandler).first
    }

    @discardableResult
    public func post(_ path: String, name: String? = nil, requestHandler: @escaping Route.RequestHandler) -> Route? {
        return request(methods: [.POST], path: path, name: name, requestHandler: requestHandler).first
    }

    @discardableResult
    public func put(_ path: String, name: String? = nil, requestHandler: @escaping Route.RequestHandler) -> Route? {
        return request(methods: [.PUT], path: path, name: name, requestHandler: requestHandler).first
    }

    @discardableResult
    public func request(
        methods: Set<Request.Method>? = nil,
        path: String,
        name: String? = nil,
        requestHandler: @escaping Route.RequestHandler
    ) -> Set<Route> {
        let methods = methods ?? Set(Request.Method.allCases)
        var routes: Set<Route> = []

        for method in methods {
            if let route = Route(method: method, path: path, name: name, requestHandler: requestHandler) {
                router.routeCollection.insert(route)
                routes.insert(route)
            }
        }

        return routes
    }
}
