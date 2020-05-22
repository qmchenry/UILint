import XCTest
@testable import UILint

final class UILintTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(UILint().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
