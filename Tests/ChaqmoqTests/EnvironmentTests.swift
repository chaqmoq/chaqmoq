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

    func testInitWithEmptyName() {
        // Act
        let environment = Environment(name: "")

        // Assert
        XCTAssertEqual(environment, .development)
    }

    func testEnvironments() {
        // Assert
        XCTAssertEqual(Environment.production.name, "production")
        XCTAssertEqual(Environment.development.name, "development")
        XCTAssertEqual(Environment.testing.name, "testing")
    }

    func testGet() {
        // Act
        let value = Environment.get("PATH")

        // Assert
        XCTAssertNotNil(value)
    }

    func testGetMissingKey() {
        // Act
        let value = Environment.get("CHAQMOQ_NON_EXISTENT_KEY")

        // Assert
        XCTAssertNil(value)
    }

    func testEquality() {
        // Assert
        XCTAssertEqual(Environment(name: "staging"), Environment(name: "staging"))
    }

    func testInequality() {
        // Assert
        XCTAssertNotEqual(Environment(name: "staging"), Environment(name: "production"))
    }
}
