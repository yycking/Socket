import XCTest
@testable import Socket

final class SocketTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Socket().text, "Hello, World!")
    }
}
