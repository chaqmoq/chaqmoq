import HTTP
import Routing

extension Application {
    @discardableResult
    public func delete(_ path: String = "/", name: String? = nil, handler: @escaping Route.RequestHandler) -> Route? {
        request(methods: [.DELETE], path: path, name: name, handler: handler).first
    }

    @discardableResult
    public func get(_ path: String = "/", name: String? = nil, handler: @escaping Route.RequestHandler) -> Route? {
        request(methods: [.GET], path: path, name: name, handler: handler).first
    }

    @discardableResult
    public func head(_ path: String = "/", name: String? = nil, handler: @escaping Route.RequestHandler) -> Route? {
        request(methods: [.HEAD], path: path, name: name, handler: handler).first
    }

    @discardableResult
    public func options(_ path: String = "/", name: String? = nil, handler: @escaping Route.RequestHandler) -> Route? {
        request(methods: [.OPTIONS], path: path, name: name, handler: handler).first
    }

    @discardableResult
    public func patch(_ path: String = "/", name: String? = nil, handler: @escaping Route.RequestHandler) -> Route? {
        request(methods: [.PATCH], path: path, name: name, handler: handler).first
    }

    @discardableResult
    public func post(_ path: String = "/", name: String? = nil, handler: @escaping Route.RequestHandler) -> Route? {
        request(methods: [.POST], path: path, name: name, handler: handler).first
    }

    @discardableResult
    public func put(_ path: String = "/", name: String? = nil, handler: @escaping Route.RequestHandler) -> Route? {
        request(methods: [.PUT], path: path, name: name, handler: handler).first
    }

    @discardableResult
    public func request(
        methods: Set<Request.Method>? = nil,
        path: String = "/",
        name: String? = nil,
        handler: @escaping Route.RequestHandler
    ) -> Set<Route> {
        let methods = methods ?? Set(Request.Method.allCases)
        var routes: Set<Route> = []

        for method in methods {
            if let route = Route(method: method, path: path, name: name, requestHandler: handler) {
                router.routes.insert(route)
                routes.insert(route)
            }
        }

        return routes
    }
}
