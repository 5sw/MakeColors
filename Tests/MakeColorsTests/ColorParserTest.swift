@testable import LibMakeColors
import XCTest

final class ColorParserTest: XCTestCase {
    func testScanningThreeDigitColor() throws {
        let color = scanColor("#abc")
        XCTAssertEqual(Color(red: 0xAA, green: 0xBB, blue: 0xCC), color)
    }

    func testScanningThreeDigitColorUppercase() throws {
        let color = scanColor("#ABc")
        XCTAssertEqual(Color(red: 0xAA, green: 0xBB, blue: 0xCC), color)
    }

    func testScanningFourDigitColor() throws {
        let color = scanColor("#abcd")
        XCTAssertEqual(Color(red: 0xAA, green: 0xBB, blue: 0xCC, alpha: 0xDD), color)
    }

    func testScanningSixDigitColor() throws {
        let color = scanColor("#abcdef")
        XCTAssertEqual(Color(red: 0xAB, green: 0xCD, blue: 0xEF), color)
    }

    func testScanningEightDigitColor() throws {
        let color = scanColor("#abcdef17")
        XCTAssertEqual(Color(red: 0xAB, green: 0xCD, blue: 0xEF, alpha: 0x17), color)
    }

    func testScanningRGBColor() throws {
        let color = scanColor("rgb(1,2,3)")
        XCTAssertEqual(Color(red: 1, green: 2, blue: 3), color)
    }

    func testScanningRGBAColor() throws {
        let color = scanColor("rgba(1,2,3,4)")
        XCTAssertEqual(Color(red: 1, green: 2, blue: 3, alpha: 4), color)
    }

    func testScanningWhite() throws {
        let color = scanColor("white(255)")
        XCTAssertEqual(Color(red: 255, green: 255, blue: 255, alpha: 255), color)
    }

    func testScanningWhiteWithAlpha() throws {
        let color = scanColor("white(255, 128)")
        XCTAssertEqual(Color(red: 255, green: 255, blue: 255, alpha: 128), color)
    }

    func testWhiteFailsWithoutArguments() throws {
        let color = scanColor("white()")
        XCTAssertNil(color)
    }

    func testWhiteFailsWith3Arguments() throws {
        let color = scanColor("white(1,2,3)")
        XCTAssertNil(color)
    }

    private func scanColor(_ input: String) -> Color? {
        let scanner = Scanner(string: input)
        return scanner.color()
    }
}
