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
}
