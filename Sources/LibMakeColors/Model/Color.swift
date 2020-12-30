struct Color: CustomStringConvertible, Equatable {
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

    var description: String {
        return a != 0xFF ? String(format: "#%02X%02X%02X%02X", r, g, b, a): String(format: "#%02X%02X%02X", r, g, b)
    }
}

enum ColorDef {
    case reference(String)
    case color(Color)
}

extension Dictionary where Key == String, Value == ColorDef {
    func resolve(_ name: String, visited: Set<String> = []) throws -> Color {
        var visited = visited
        guard visited.insert(name).inserted else {
            throw Errors.cyclicReference(name)
        }

        switch self[name] {
        case nil:
            throw Errors.missingReference(name)

        case .color(let color):
            return color

        case .reference(let referenced):
            return try resolve(referenced, visited: visited)
        }
    }

    func sorted() -> [Element] {
        sorted(by: Self.compare)
    }

    static func compare(_ a: (String, ColorDef), _ b: (String, ColorDef)) -> Bool {
        switch (a, b) {
        case ((_, .color), (_, .reference)): return true
        case ((_, .reference), (_, .color)): return false
        case let ((left, _), (right, _)): return left.localizedStandardCompare(right) == .orderedAscending
        }
    }

}
