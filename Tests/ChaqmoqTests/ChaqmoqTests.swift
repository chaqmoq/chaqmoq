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

    func testFreezeRoutesPreservesPipelineAndStillRoutes() async throws {
        // Arrange
        let app = Chaqmoq()
        let expected = Response(status: .accepted)
        app.get("/posts") { _ in expected }
        app.middleware = [CustomMiddleware()] // user middleware ahead of routing

        // Act
        app.freezeRoutes()

        // Assert — pipeline order preserved: custom middleware first, RoutingMiddleware last.
        XCTAssertEqual(app.middleware.count, 2)
        XCTAssertTrue(type(of: app.middleware[0]) == CustomMiddleware.self)
        let routing = try XCTUnwrap(app.middleware.last as? RoutingMiddleware)

        // The frozen snapshot still resolves the registered route.
        let request = Request(eventLoop: EmbeddedEventLoop(), uri: URI("/posts")!)
        let result = try await routing.handle(request: request) { _ in fatalError() }
        let response = try XCTUnwrap(result as? Response)
        XCTAssertEqual(response.status, .accepted)
    }

    func testFreezeRoutesDoesNotDuplicateRoutingMiddleware() throws {
        // Arrange
        let app = Chaqmoq()
        app.get("/a") { _ in Response() }

        // Act — freezing twice must not accumulate RoutingMiddleware instances.
        app.freezeRoutes()
        app.freezeRoutes()

        // Assert
        XCTAssertEqual(app.middleware.count, 1)
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
        func handle(request: Request, responder: @escaping Responder) async throws -> any Encodable & Sendable {
            try await responder(request)
        }
    }
}
