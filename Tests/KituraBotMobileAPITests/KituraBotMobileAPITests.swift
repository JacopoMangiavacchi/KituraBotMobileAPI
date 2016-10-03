import XCTest
@testable import KituraBotMobileAPI

class KituraBotMobileAPITests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(KituraBotMobileAPI().text, "Hello, World!")
    }


    static var allTests : [(String, (KituraBotMobileAPITests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
