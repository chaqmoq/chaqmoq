@testable import Chaqmoq
import Resolver
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
        XCTAssertTrue(type(of: app.middleware.first!) == RoutingMiddleware.self)
        XCTAssertTrue(app.resolver === Resolver.main)
    }

    func testInit() {
        // Arrange
        let configuration = Chaqmoq.Configuration()
        let environment = Environment.testing
        let resolver = Resolver()

        // Act
        let app = Chaqmoq(configuration: configuration, environment: environment, resolver: resolver)

        // Assert
        XCTAssertEqual(app.configuration, configuration)
        XCTAssertEqual(app.environment, environment)
        XCTAssertTrue(app.eventLoopGroup === app.server.eventLoopGroup)
        XCTAssertEqual(app.middleware.count, 1)
        XCTAssertTrue(type(of: app.middleware.first!) == RoutingMiddleware.self)
        XCTAssertTrue(app.resolver === resolver)
    }
}
