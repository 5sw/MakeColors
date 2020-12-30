@testable import LibMakeColors
import XCTest

final class ColorParserTest: XCTestCase {
    func testScanningThreeDigitColor() throws {
        let scanner = Scanner(string: "#abc")
        let color = scanner.color()
        XCTAssertEqual(Color(r: 0xAA, g: 0xBB, b: 0xCC), color)
    }

    func testScanningFourDigitColor() throws {
        let scanner = Scanner(string: "#abcd")
        let color = scanner.color()
        XCTAssertEqual(Color(r: 0xAA, g: 0xBB, b: 0xCC, a: 0xDD), color)
    }

    func testScanningSixDigitColor() throws {
        let scanner = Scanner(string: "#abcdef")
        let color = scanner.color()
        XCTAssertEqual(Color(r: 0xAB, g: 0xCD, b: 0xEF), color)
    }

    func testScanningEightDigitColor() throws {
        let scanner = Scanner(string: "#abcdef17")
        let color = scanner.color()
        XCTAssertEqual(Color(r: 0xAB, g: 0xCD, b: 0xEF, a: 0x17), color)
    }

    func testScanningRGBColor() throws {
        let scanner = Scanner(string: "rgb(1,2,3)")
        let color = scanner.color()
        XCTAssertEqual(Color(r: 1, g: 2, b: 3), color)
    }

    func testScanningRGBAColor() throws {
        let scanner = Scanner(string: "rgba(1,2,3,4)")
        let color = scanner.color()
        XCTAssertEqual(Color(r: 1, g: 2, b: 3, a: 4), color)
    }
}
