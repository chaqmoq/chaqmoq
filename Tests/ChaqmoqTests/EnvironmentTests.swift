@testable import Chaqmoq
import XCTest

final class EnvironmentTests: XCTestCase {
    func testInit() {
        // Act
        let environment = Environment()

        // Assert
        XCTAssertEqual(environment, .development)
    }

    func testInitWithName() {
        // Arrange
        let name = "staging"

        // Act
        let environment = Environment(name: name)

        // Assert
        XCTAssertEqual(environment.name, name)
    }
}
