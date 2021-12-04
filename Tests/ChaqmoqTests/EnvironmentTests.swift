@testable import Chaqmoq
import XCTest

final class EnvironmentTests: XCTestCase {
    func testInit() {
        // Act
        let environment = Environment()

        // Assert
        XCTAssertEqual(environment, .development)
    }
}
