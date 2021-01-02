@testable import LibMakeColors
import RBBJSON
import XCTest

class AssetCatalogFormattingTest: XCTestCase {
    func testColorProducedValidJSON() throws {
        let color = Color(red: 0xFF, green: 0xF0, blue: 0x0F)
        let data = Data(color.json().utf8)

        let json = try JSONDecoder().decode(RBBJSON.self, from: data)

        XCTAssertEqual(json.info.author, .string("de.5sw.MakeColors"))
        XCTAssertEqual(json.info.version, .number(1))

        XCTAssertEqual(Array(json.colors[any: .child]).count, 1)

        XCTAssertEqual(json.colors[0].idiom, .string("universal"))

        let jsonColor = json.colors[0].color
        XCTAssertEqual(jsonColor["color-space"], .string("srgb"))
        XCTAssertEqual(jsonColor.components.alpha, .string("1.0"))
        XCTAssertEqual(jsonColor.components.red, .string("0xFF"))
        XCTAssertEqual(jsonColor.components.green, .string("0xF0"))
        XCTAssertEqual(jsonColor.components.blue, .string("0x0F"))
    }
}
