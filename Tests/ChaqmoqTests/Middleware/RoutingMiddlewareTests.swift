@testable import Chaqmoq
import XCTest

final class RoutingMiddlewareTests: XCTestCase {
    func testHandle() async throws {
        // Arrange
        let eventLoop = EmbeddedEventLoop()
        let initialRequest = Request(eventLoop: eventLoop)
        let expectedResponse = Response()
        let app = Chaqmoq()
        let middleware = RoutingMiddleware(router: app)

        // Act
        var result = try await middleware.handle(request: initialRequest) { _ in fatalError() }
        var response = try XCTUnwrap(result as? Response)

        // Assert
        XCTAssertEqual(response.status, .notFound)

        // Arrange
        app.get(middleware: [HTTPMethodOverrideMiddleware()]) { request in
            // Assert
            XCTAssertNil(initialRequest.route)
            XCTAssertNotNil(request.route)

            return expectedResponse
        }

        // Act
        result = try await middleware.handle(request: initialRequest) { _ in fatalError() }
        response = try XCTUnwrap(result as? Response)

        // Assert
        XCTAssertEqual(response.status, expectedResponse.status)
    }
}
