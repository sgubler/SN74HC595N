import XCTest
@testable import SN74HC595N

final class SN74HC595NTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SN74HC595N().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
