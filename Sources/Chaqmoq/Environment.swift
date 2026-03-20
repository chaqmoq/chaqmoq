import Foundation

/// Represents the runtime environment of a Chaqmoq application.
///
/// Use the built-in presets — `.production`, `.development`, `.testing` — or create a custom
/// environment by providing a name. The active environment can also be set via the `CHAQMOQ_ENV`
/// process variable.
public struct Environment {
    /// The name of the environment (e.g. `"development"`, `"production"`).
    public let name: String

    /// Creates an environment with the given name.
    ///
    /// - Parameter name: The environment name. Defaults to the value of the `CHAQMOQ_ENV` process
    ///   variable, or `"development"` if the variable is absent or empty.
    public init(name: String = Self.get("CHAQMOQ_ENV") ?? "") {
        self.name = name.isEmpty ? Self.development.name : name
    }

    /// Returns the value of a process environment variable.
    ///
    /// - Parameter key: The name of the environment variable.
    /// - Returns: The variable's value, or `nil` if it is not set.
    public static func get(_ key: String) -> String? {
        ProcessInfo.processInfo.environment[key]
    }
}

extension Environment {
    /// The production environment, intended for live deployments.
    public static let production = Self(name: "production")

    /// The development environment, intended for local development.
    public static let development = Self(name: "development")

    /// The testing environment, intended for automated tests.
    public static let testing = Self(name: "testing")
}

extension Environment: Equatable {
    /// Two environments are equal when their names are equal.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name
    }
}
