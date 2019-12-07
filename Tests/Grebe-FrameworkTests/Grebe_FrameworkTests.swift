import XCTest
@testable import Grebe_Framework

final class Grebe_FrameworkTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Grebe_Framework().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
