@testable import LibMakeColors
import XCTest

final class ColorHSVTest: XCTestCase {
    func testHSV0Degrees() {
        let color = Color(hue: 0, saturation: 0xFF, value: 0xFF)
        XCTAssertEqual(color, Color(red: 0xFF, green: 0, blue: 0))
    }

    func testHSV60Degrees() {
        let color = Color(hue: 60, saturation: 0xFF, value: 0xFF)
        XCTAssertEqual(color, Color(red: 0xFF, green: 0xFF, blue: 0))
    }

    func testHSV120Degrees() {
        let color = Color(hue: 120, saturation: 0xFF, value: 0xFF)
        XCTAssertEqual(color, Color(red: 0, green: 0xFF, blue: 0))
    }

    func testHSV180Degrees() {
        let color = Color(hue: 180, saturation: 0xFF, value: 0xFF)
        XCTAssertEqual(color, Color(red: 0, green: 0xFF, blue: 0xFF))
    }

    func testHSV240Degrees() {
        let color = Color(hue: 240, saturation: 0xFF, value: 0xFF)
        XCTAssertEqual(color, Color(red: 0, green: 0, blue: 0xFF))
    }

    func testHSV300Degrees() {
        let color = Color(hue: 300, saturation: 0xFF, value: 0xFF)
        XCTAssertEqual(color, Color(red: 0xFF, green: 0, blue: 0xFF))
    }

    func testHSV360Degrees() {
        let color = Color(hue: 360, saturation: 0xFF, value: 0xFF)
        XCTAssertEqual(color, Color(red: 0xFF, green: 0, blue: 0))
    }
}
