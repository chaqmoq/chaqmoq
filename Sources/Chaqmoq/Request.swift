public extension Request {
    /// The route matched to this request, or `nil` if routing has not yet resolved.
    var route: Route? { getAttribute("_route") }
}
