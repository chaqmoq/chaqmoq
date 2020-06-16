import HTTP
import Routing

extension Application {
    @discardableResult
    public func delete(
        _ path: String = String(Route.pathComponentSeparator),
        name: String = "",
        handler: @escaping Route.RequestHandler
    ) -> Route? {
        router.routes.builder.delete(path, name: name, handler: handler)
    }

    @discardableResult
    public func get(
        _ path: String = String(Route.pathComponentSeparator),
        name: String = "",
        handler: @escaping Route.RequestHandler
    ) -> Route? {
        router.routes.builder.get(path, name: name, handler: handler)
    }

    @discardableResult
    public func head(
        _ path: String = String(Route.pathComponentSeparator),
        name: String = "",
        handler: @escaping Route.RequestHandler
    ) -> Route? {
        router.routes.builder.head(path, name: name, handler: handler)
    }

    @discardableResult
    public func options(
        _ path: String = String(Route.pathComponentSeparator),
        name: String = "",
        handler: @escaping Route.RequestHandler
    ) -> Route? {
        router.routes.builder.options(path, name: name, handler: handler)
    }

    @discardableResult
    public func patch(
        _ path: String = String(Route.pathComponentSeparator),
        name: String = "",
        handler: @escaping Route.RequestHandler
    ) -> Route? {
        router.routes.builder.patch(path, name: name, handler: handler)
    }

    @discardableResult
    public func post(
        _ path: String = String(Route.pathComponentSeparator),
        name: String = "",
        handler: @escaping Route.RequestHandler
    ) -> Route? {
        router.routes.builder.post(path, name: name, handler: handler)
    }

    @discardableResult
    public func put(
        _ path: String = String(Route.pathComponentSeparator),
        name: String = "",
        handler: @escaping Route.RequestHandler
    ) -> Route? {
        router.routes.builder.put(path, name: name, handler: handler)
    }

    @discardableResult
    public func request(
        _ path: String = String(Route.pathComponentSeparator),
        methods: Set<Request.Method> = Set(Request.Method.allCases),
        handler: @escaping Route.RequestHandler
    ) -> [Route] {
        router.routes.builder.request(path, methods: methods, handler: handler)
    }

    public func grouped(
        _ path: String = String(Route.pathComponentSeparator),
        name: String = ""
    ) -> RouteCollection.Builder? {
        router.routes.builder.grouped(path, name: name)
    }

    public func group(
        _ path: String = String(Route.pathComponentSeparator),
        name: String = "",
        handler: @escaping (RouteCollection.Builder) -> Void
    ) {
        router.routes.builder.group(path, name: name, handler: handler)
    }
}
