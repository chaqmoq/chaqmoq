@testable import Chaqmoq
import XCTest

final class ChaqmoqTests: XCTestCase {
    func testInit() throws {
        // Arrange
        let configuration = Chaqmoq.Configuration()
        let environment = Environment.testing

        // Act
        let app = Chaqmoq(
            configuration: configuration,
            environment: environment
        )
        app.errorMiddleware = [CustomErrorMiddleware()]

        // Assert
        XCTAssertEqual(app.configuration, configuration)
        XCTAssertEqual(app.environment, environment)
        XCTAssertTrue(app.eventLoopGroup === app.server.eventLoopGroup)
        XCTAssertEqual(app.middleware.count, 1)
        XCTAssertEqual(app.errorMiddleware.count, 1)
        let lastMiddleware = try XCTUnwrap(app.middleware.last)
        XCTAssertTrue(type(of: lastMiddleware) == RoutingMiddleware.self)
    }

    func testDefaultInit() throws {
        // Act
        let app = Chaqmoq()

        // Assert
        XCTAssertEqual(app.configuration, .init())
        XCTAssertEqual(app.environment, .development)
        XCTAssertTrue(app.errorMiddleware.isEmpty)
        XCTAssertEqual(app.middleware.count, 1)
        let lastMiddleware = try XCTUnwrap(app.middleware.last)
        XCTAssertTrue(type(of: lastMiddleware) == RoutingMiddleware.self)
    }

    func testMiddlewareFiltersRoutingMiddleware() throws {
        // Arrange
        let app = Chaqmoq()

        // Act — re-assigning app.middleware (which already contains RoutingMiddleware) must not duplicate it
        app.middleware = app.middleware

        // Assert
        XCTAssertEqual(app.middleware.count, 1)
        let lastMiddleware = try XCTUnwrap(app.middleware.last)
        XCTAssertTrue(type(of: lastMiddleware) == RoutingMiddleware.self)
    }

    func testMiddlewareOrder() throws {
        // Arrange
        let app = Chaqmoq()

        // Act
        app.middleware = [CustomMiddleware()]

        // Assert — custom middleware comes before RoutingMiddleware
        XCTAssertEqual(app.middleware.count, 2)
        XCTAssertTrue(type(of: app.middleware[0]) == CustomMiddleware.self)
        let lastMiddleware = try XCTUnwrap(app.middleware.last)
        XCTAssertTrue(type(of: lastMiddleware) == RoutingMiddleware.self)
    }

    func testRunShutdown() throws {
        let app = Chaqmoq()
        let semaphore = DispatchSemaphore(value: 0)
        app.server.onStart = { _ in semaphore.signal() }
        DispatchQueue.global().async {
            semaphore.wait()
            do {
                try app.shutdown()
            } catch {
                XCTFail("Failed to shut down app: \(error)")
            }
        }
        try app.run()
    }
}

final class ChaqmoqConfigurationTests: XCTestCase {
    let identifier = "com.mydomain"
    let publicDirectory = "/Public"

    func testInit() {
        // Arrange
        let serverConfiguration = Server.Configuration()

        // Act
        let configuration = Chaqmoq.Configuration(
            identifier: identifier,
            publicDirectory: publicDirectory,
            server: serverConfiguration
        )

        // Assert
        XCTAssertEqual(configuration.identifier, identifier)
        XCTAssertEqual(configuration.publicDirectory, publicDirectory)
        XCTAssertEqual(configuration.server, serverConfiguration)
    }

    func testDefaultInit() {
        // Act
        let configuration = Chaqmoq.Configuration()

        // Assert
        XCTAssertEqual(configuration.identifier, "dev.chaqmoq")
        XCTAssertEqual(configuration.publicDirectory, "Public")
        XCTAssertEqual(configuration.server, Server.Configuration())
    }

    func testEquality() {
        // Assert
        XCTAssertEqual(
            Chaqmoq.Configuration(identifier: identifier, publicDirectory: publicDirectory),
            Chaqmoq.Configuration(identifier: identifier, publicDirectory: publicDirectory)
        )
    }

    func testInequality() {
        // Assert
        XCTAssertNotEqual(
            Chaqmoq.Configuration(identifier: "com.one"),
            Chaqmoq.Configuration(identifier: "com.two")
        )
    }
}

extension ChaqmoqTests {
    struct CustomErrorMiddleware: ErrorMiddleware {}

    struct CustomMiddleware: Middleware {
        func handle(request: Request, responder: @escaping Responder) async throws -> Encodable {
            try await responder(request)
        }
    }
}
