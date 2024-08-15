@testable import Chaqmoq
import XCTest

final class ChaqmoqTests: XCTestCase {
    func testDefaultInit() {
        // Act
        let app = Chaqmoq()

        // Assert
        XCTAssertEqual(app.configuration, Chaqmoq.Configuration())
        XCTAssertEqual(app.environment, .development)
        XCTAssertTrue(app.eventLoopGroup === app.server.eventLoopGroup)
        XCTAssertEqual(app.middleware.count, 1)
        XCTAssertTrue(type(of: app.middleware.last!) == RoutingMiddleware.self)
    }

    func testInit() {
        // Arrange
        let configuration = Chaqmoq.Configuration()
        let environment = Environment.testing

        // Act
        let app = Chaqmoq(configuration: configuration, environment: environment)

        // Assert
        XCTAssertEqual(app.configuration, configuration)
        XCTAssertEqual(app.environment, environment)
        XCTAssertTrue(app.eventLoopGroup === app.server.eventLoopGroup)
        XCTAssertEqual(app.middleware.count, 1)
        XCTAssertTrue(type(of: app.middleware.last!) == RoutingMiddleware.self)
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
