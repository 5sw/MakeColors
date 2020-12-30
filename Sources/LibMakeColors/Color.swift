struct Color: CustomStringConvertible, Equatable {
    var description: String {
        return a != 0xFF ? String(format: "#%02X%02X%02X%02X", r, g, b, a): String(format: "#%02X%02X%02X", r, g, b)
    }

    let r, g, b, a: UInt8

    init(r: UInt8, g: UInt8, b: UInt8, a: UInt8 = 0xFF) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }

    init?(_ array: [UInt8]) {
        guard array.count >= 3 else { return nil }
        r = array[0]
        g = array[1]
        b = array[2]
        a = array.count >= 4 ? array[3] : 0xFF
    }
}

enum ColorDef {
    case reference(String)
    case color(Color)
}
