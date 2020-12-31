struct Color: CustomStringConvertible, Equatable {
    let red: UInt8
    let green: UInt8
    let blue: UInt8
    let alpha: UInt8

    init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8 = 0xFF) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    init(_ array: [UInt8]) {
        precondition(array.count == 3 || array.count == 4)
        red = array[0]
        green = array[1]
        blue = array[2]
        alpha = array.count == 4 ? array[3] : 0xFF
    }

    init(white array: [UInt8]) {
        precondition(array.count == 1 || array.count == 2)
        red = array[0]
        green = array[0]
        blue = array[0]
        alpha = array.count == 2 ? array[1] : 0xFF
    }

    var description: String {
        let alphaSuffix = alpha != 0xFF ? String(format: "%02X", alpha) : ""
        return String(format: "#%02X%02X%02X%@", red, green, blue, alphaSuffix)
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

        case let .color(color):
            return color

        case let .reference(referenced):
            return try resolve(referenced, visited: visited)
        }
    }

    func sorted() -> [Element] {
        sorted(by: Self.compare)
    }

    static func compare(_ lhs: (String, ColorDef), _ rhs: (String, ColorDef)) -> Bool {
        switch (lhs, rhs) {
        case ((_, .color), (_, .reference)):
            return true

        case ((_, .reference), (_, .color)):
            return false

        case let ((left, _), (right, _)):
            return left.localizedStandardCompare(right) == .orderedAscending
        }
    }
}
