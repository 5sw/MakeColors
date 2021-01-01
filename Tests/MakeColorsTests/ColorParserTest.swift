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

    func testScanningColorWithPercentage() throws {
        let color = scanColor("rgba(100%, 0, 50%, 100%)")
        XCTAssertEqual(color, Color(red: 255, green: 0, blue: 127, alpha: 255))
    }

    func testReadingComponentAsByte() throws {
        let scanner = Scanner(string: "128")
        XCTAssertEqual(scanner.component(), 128)
        XCTAssertTrue(scanner.isAtEnd)
    }

    func testReadingComponentAs100Percent() throws {
        let scanner = Scanner(string: "100%")
        XCTAssertEqual(scanner.component(), 0xFF)
        XCTAssertTrue(scanner.isAtEnd)
    }

    func testReadingComponentAs0Percent() throws {
        let scanner = Scanner(string: "0%")
        XCTAssertEqual(scanner.component(), 0)
        XCTAssertTrue(scanner.isAtEnd)
    }

    func testReadingComponentAs50PercentRoundsDown() throws {
        let scanner = Scanner(string: "50%")
        XCTAssertEqual(scanner.component(), 127)
        XCTAssertTrue(scanner.isAtEnd)
    }

    func testScanningDegreesAsByte() throws {
        let scanner = Scanner(string: "128")
        XCTAssertEqual(scanner.degrees(), 180)
    }

    func testScanningDegreesAsPercentage() throws {
        let scanner = Scanner(string: "50%")
        XCTAssertEqual(scanner.degrees(), 180)
    }

    func testScanningDegrees() throws {
        let scanner = Scanner(string: "120°")
        XCTAssertEqual(scanner.degrees(), 120)
    }

    func testScanningDegreesWithDegSuffix() throws {
        let scanner = Scanner(string: "120 deg")
        XCTAssertEqual(scanner.degrees(), 120)
    }

    func testScanningHSVColor() throws {
        XCTAssertEqual(scanColor("hsv(60°, 255, 100%)"), Color(red: 0xFF, green: 0xFF, blue: 0))
    }

    func testScanningHSVAColor() throws {
        XCTAssertEqual(scanColor("hsva(60°, 50%, 255, 99)"), Color(red: 0xFF, green: 0xFF, blue: 128, alpha: 99))
    }

    private func scanColor(_ input: String) -> Color? {
        let scanner = Scanner(string: input)
        let result = scanner.color()
        XCTAssertTrue(result == nil || scanner.isAtEnd)
        return result
    }
}
