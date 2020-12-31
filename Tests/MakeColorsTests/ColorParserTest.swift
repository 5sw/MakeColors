@testable import LibMakeColors
import XCTest

final class ColorParserTest: XCTestCase {
    func testScanningThreeDigitColor() throws {
        let scanner = Scanner(string: "#abc")
        let color = scanner.color()
        XCTAssertEqual(Color(red: 0xAA, green: 0xBB, blue: 0xCC), color)
    }

    func testScanningThreeDigitColorUppercase() throws {
        let scanner = Scanner(string: "#ABc")
        let color = scanner.color()
        XCTAssertEqual(Color(red: 0xAA, green: 0xBB, blue: 0xCC), color)
    }

    func testScanningFourDigitColor() throws {
        let scanner = Scanner(string: "#abcd")
        let color = scanner.color()
        XCTAssertEqual(Color(red: 0xAA, green: 0xBB, blue: 0xCC, alpha: 0xDD), color)
    }

    func testScanningSixDigitColor() throws {
        let scanner = Scanner(string: "#abcdef")
        let color = scanner.color()
        XCTAssertEqual(Color(red: 0xAB, green: 0xCD, blue: 0xEF), color)
    }

    func testScanningEightDigitColor() throws {
        let scanner = Scanner(string: "#abcdef17")
        let color = scanner.color()
        XCTAssertEqual(Color(red: 0xAB, green: 0xCD, blue: 0xEF, alpha: 0x17), color)
    }

    func testScanningRGBColor() throws {
        let scanner = Scanner(string: "rgb(1,2,3)")
        let color = scanner.color()
        XCTAssertEqual(Color(red: 1, green: 2, blue: 3), color)
    }

    func testScanningRGBAColor() throws {
        let scanner = Scanner(string: "rgba(1,2,3,4)")
        let color = scanner.color()
        XCTAssertEqual(Color(red: 1, green: 2, blue: 3, alpha: 4), color)
    }

    func testScanningWhite() throws {
        let scanner = Scanner(string: "white(255)")
        let color = scanner.color()
        XCTAssertEqual(Color(red: 255, green: 255, blue: 255, alpha: 255), color)
    }

    func testScanningWhiteWithAlpha() throws {
        let scanner = Scanner(string: "white(255, 128)")
        let color = scanner.color()
        XCTAssertEqual(Color(red: 255, green: 255, blue: 255, alpha: 128), color)
    }

    func testWhiteFailsWithoutArguments() throws {
        let scanner = Scanner(string: "white()")
        let color = scanner.color()
        XCTAssertNil(color)
    }

    func testWhiteFailsWith3Arguments() throws {
        let scanner = Scanner(string: "white(1,2,3)")
        let color = scanner.color()
        XCTAssertNil(color)
    }
}
