import Foundation

public struct Environment {
    public let name: String

    public init(name: String = Environment.get("CHAQMOQ_ENV") ?? "") {
        switch name {
        case "production":
            self = .production
        case "development", "":
            self = .development
        case "testing":
            self = .testing
        default:
            self.name = name
        }
    }

    public static func get(_ key: String) -> String? {
        ProcessInfo.processInfo.environment[key]
    }
}

extension Environment {
    public static let production = Environment(name: "production")
    public static let development = Environment(name: "development")
    public static let testing = Environment(name: "testing")
}

extension Environment: Equatable {
    public static func == (lhs: Environment, rhs: Environment) -> Bool {
        lhs.name == rhs.name
    }
}
