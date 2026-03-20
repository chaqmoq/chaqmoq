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
}

extension ChaqmoqTests {
    struct CustomErrorMiddleware: ErrorMiddleware {}
}
