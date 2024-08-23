import Foundation

/// Manages an application's `Environment` such as `.production`, `.development`, and `.testing`.Enables to create a
/// custom `Environment` and provides access to `Environment` variables.
public struct Environment {
    /// The name of an `Environment`.
    public let name: String

    /// Initializes a new instance of `Environment` with a name.
    ///
    /// - Parameter name: The name for a new `Environment`. Defaults to the `Environment` variable with the
    /// `CHAQMOQ_ENV` key or falls back to the `development` `Environment` if it doesn't exist or not provided.
    public init(name: String = Environment.get("CHAQMOQ_ENV") ?? "") {
        self.name = name.isEmpty ? Environment.development.name : name
    }

    /// Gets an `Environment` variable by key.
    ///
    /// - Parameter key: A key for an `Environment` variable.
    /// - Returns: An `Environment` variable if it exists or `nil` if it doesn't.
    public static func get(_ key: String) -> String? {
        ProcessInfo.processInfo.environment[key]
    }
}

extension Environment {
    /// An `Environment` for deploying an application.
    public static let production = Environment(name: "production")

    /// An `Environment` for developing an application.
    public static let development = Environment(name: "development")

    /// An `Environment` for testing an application.
    public static let testing = Environment(name: "testing")
}

extension Environment: Equatable {
    /// See `Equatable`.
    public static func == (lhs: Environment, rhs: Environment) -> Bool {
        lhs.name == rhs.name
    }
}
