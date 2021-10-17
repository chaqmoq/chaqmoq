import Foundation
import HTTP

public struct CORSMiddleware: Middleware {
    public var options: Options

    public init(options: Options = .init()) {
        self.options = options
    }

    public func handle(request: Request, nextHandler: @escaping (Request) -> Response) -> Response {
        guard request.headers.value(for: .origin) != nil else { return nextHandler(request) }
        var response = request.isPreflight ? Response(status: .noContent) : nextHandler(request)
        setAllowCredentialsHeader(response: &response)
        setAllowHeadersHeader(request: request, response: &response)
        setAllowMethodsHeader(response: &response)
        setAllowOriginHeader(request: request, response: &response)
        setExposeHeadersHeader(response: &response)
        setMaxAgeHeader(response: &response)

        return response
    }
}

extension CORSMiddleware {
    public struct Options {
        public var allowCredentials: Bool
        public var allowedHeaders: [String]?
        public var allowedMethods: [Request.Method]
        public var allowedOrigin: AllowedOrigin
        public var exposedHeaders: [String]?
        public var maxAge: Int?

        public init(
            allowCredentials: Bool = false,
            allowedHeaders: [String]? = nil,
            allowedMethods: [Request.Method] = [.DELETE, .GET, .HEAD, .PATCH, .POST, .PUT],
            allowedOrigin: AllowedOrigin = .all,
            exposedHeaders: [String]? = nil,
            maxAge: Int? = nil
        ) {
            self.allowCredentials = allowCredentials
            self.allowedHeaders = allowedHeaders
            self.allowedMethods = allowedMethods
            self.allowedOrigin = allowedOrigin
            self.exposedHeaders = exposedHeaders
            self.maxAge = maxAge
        }
    }
}

extension CORSMiddleware.Options {
    public enum AllowedOrigin {
        case all
        case none
        case origins(Set<String>)
        case regex(NSRegularExpression)
        case sameAsOrigin

        public func value(from request: Request) -> String {
            guard let origin = request.headers.value(for: .origin) else { return "" }

            switch self {
            case .all: return "*"
            case .none: return ""
            case .sameAsOrigin: return origin
            case .origins, .regex: return isAllowed(origin) ? origin : "false"
            }
        }

        private func isAllowed(_ origin: String) -> Bool {
            switch self {
            case .origins(let origins): return origins.contains(origin)
            case .regex(let regex):
                return regex.firstMatch(in: origin, range: NSRange(location: 0, length: origin.count)) != nil
            default: return false
            }
        }
    }
}

extension CORSMiddleware {
    private func setAllowCredentialsHeader(response: inout Response) {
        if options.allowCredentials {
            response.headers.set("true", for: .accessControlAllowCredentials)
        }
    }

    private func setAllowHeadersHeader(request: Request, response: inout Response) {
        if let allowedHeaders = options.allowedHeaders {
            response.headers.set(allowedHeaders.joined(separator: ","), for: .accessControlAllowHeaders)
        } else if let allowedHeaders = request.headers.value(for: .accessControlRequestHeaders) {
            response.headers.set(allowedHeaders, for: .accessControlAllowHeaders)
        }
    }

    private func setAllowMethodsHeader(response: inout Response) {
        let allowedMethods = options.allowedMethods.map { $0.rawValue }
        response.headers.set(allowedMethods.joined(separator: ","), for: .accessControlAllowMethods)
    }

    private func setAllowOriginHeader(request: Request, response: inout Response) {
        let value = options.allowedOrigin.value(from: request)
        response.headers.set(value, for: .accessControlAllowOrigin)

        if case .sameAsOrigin = options.allowedOrigin, !value.isEmpty {
            response.headers.set("origin", for: .vary)
        }
    }

    private func setExposeHeadersHeader(response: inout Response) {
        if let exposedHeaders = options.exposedHeaders {
            response.headers.set(exposedHeaders.joined(separator: ","), for: .accessControlExposeHeaders)
        }
    }

    private func setMaxAgeHeader(response: inout Response) {
        if let maxAge = options.maxAge {
            response.headers.set(String(maxAge), for: .accessControlMaxAge)
        }
    }
}

private extension Request {
    var isPreflight: Bool { method == .OPTIONS && headers.value(for: .accessControlRequestMethod) != nil }
}
