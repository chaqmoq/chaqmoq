@testable import Chaqmoq
import XCTest

final class RoutingMiddlewareTests: XCTestCase {
    func testHandleNotFound() async throws {
        // Arrange
        let app = Chaqmoq()
        let middleware = RoutingMiddleware(router: app)
        let request = Request(eventLoop: EmbeddedEventLoop())

        // Act
        let result = try await middleware.handle(request: request) { _ in fatalError() }
        let response = try XCTUnwrap(result as? Response)

        // Assert
        XCTAssertEqual(response.status, .notFound)
    }

    func testHandleMatchedRoute() async throws {
        // Arrange
        let app = Chaqmoq()
        let middleware = RoutingMiddleware(router: app)
        let request = Request(eventLoop: EmbeddedEventLoop())
        let expectedResponse = Response()
        app.get { _ in expectedResponse }

        // Act
        let result = try await middleware.handle(request: request) { _ in fatalError() }
        let response = try XCTUnwrap(result as? Response)

        // Assert
        XCTAssertEqual(response.status, expectedResponse.status)
    }

    func testHandleSetsRouteOnRequest() async throws {
        // Arrange
        let app = Chaqmoq()
        let middleware = RoutingMiddleware(router: app)
        let initialRequest = Request(eventLoop: EmbeddedEventLoop())

        app.get { request in
            // Assert — route is set on the copied request inside the handler
            XCTAssertNotNil(request.route)
            return Response()
        }

        // Assert — route is nil before routing
        XCTAssertNil(initialRequest.route)

        // Act
        _ = try await middleware.handle(request: initialRequest) { _ in fatalError() }

        // Assert — route remains nil on the original request (Request is a value type)
        XCTAssertNil(initialRequest.route)
    }

    func testHandleWithRouteMiddleware() async throws {
        // Arrange
        let app = Chaqmoq()
        let middleware = RoutingMiddleware(router: app)
        let request = Request(eventLoop: EmbeddedEventLoop())
        let expectedResponse = Response()
        let trackingMiddleware = TrackingMiddleware()
        app.get(middleware: [trackingMiddleware]) { _ in expectedResponse }

        // Act
        let result = try await middleware.handle(request: request) { _ in fatalError() }
        let response = try XCTUnwrap(result as? Response)

        // Assert
        XCTAssertTrue(trackingMiddleware.wasCalled)
        XCTAssertEqual(response.status, expectedResponse.status)
    }
}

extension RoutingMiddlewareTests {
    final class TrackingMiddleware: Middleware {
        var wasCalled = false

        func handle(request: Request, responder: @escaping Responder) async throws -> Encodable {
            wasCalled = true
            return try await responder(request)
        }
    }
}
