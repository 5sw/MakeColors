import Foundation

extension Scanner {
    func color() -> Color? {
        if string("#"), let digits = scanCharacters(from: .hex) {
            switch digits.count {
            case 3, 4: // rgb(a)
                let digits = digits.chunks(size: 1)
                    .compactMap { UInt8($0, radix: 16) }
                    .map { $0 << 4 | $0 }
                return Color(digits)

            case 6, 8: // rrggbb(aa)
                let digits = digits.chunks(size: 2).compactMap { UInt8($0, radix: 16) }
                return Color(digits)

            default:
                return nil
            }
        }

        if string("rgba"), let components = argumentList(4) {
            return Color(components)
        }

        if string("rgb"), let components = argumentList(3) {
            return Color(components)
        }

        if string("white"), let arguments = argumentList(min: 1, max: 2) {
            return Color(white: arguments)
        }

        if string("hsva") {
            return readHSV(alpha: true)
        }

        if string("hsv") {
            return readHSV(alpha: false)
        }

        return nil
    }

    private func readHSV(alpha readAlpha: Bool) -> Color? {
        guard
            string("("),
            let hue = degrees(),
            string(","),
            let saturation = component(),
            string(","),
            let value = component()
        else { return nil }

        let alpha: UInt8

        if readAlpha {
            guard
                string(","),
                let value = component()
            else { return nil }
            alpha = value
        } else {
            alpha = 0xFF
        }

        guard string(")") else { return nil }

        return Color(hue: hue, saturation: saturation, value: value, alpha: alpha)
    }

    func degrees() -> Int? {
        guard let int = scanInt() else { return nil }

        if string("%") {
            guard 0...100 ~= int else { return nil }
            return (360 * int) / 100
        } else if string("°") || string("deg") {
            return int
        } else {
            guard 0...0xFF ~= int else { return nil }
            return (360 * int) / 0xFF
        }
    }

    func colorReference() -> String? {
        guard string("@") else { return nil }
        return name()
    }

    func name() -> String? {
        guard let name = scanCharacters(from: .name), !name.isEmpty else {
            return nil
        }

        return name
    }

    func colorDef() -> ColorDef? {
        if let color = color() {
            return .color(color)
        }

        if let ref = colorReference() {
            return .reference(ref)
        }

        return nil
    }

    func colorLine() -> (String, ColorDef)? {
        guard
            let name = name(),
            let def = colorDef(),
            endOfLine()
        else {
            return nil
        }
        return (name, def)
    }

    func endOfLine() -> Bool {
        guard isAtEnd || string("\n") else {
            return false
        }
        _ = scanCharacters(from: .whitespacesAndNewlines)
        return true
    }

    func colorList() throws -> [String: ColorDef] {
        var result: [String: ColorDef] = [:]
        while !isAtEnd {
            guard let (name, def) = colorLine() else {
                throw Errors.syntaxError
            }

            guard !result.keys.contains(name) else {
                throw Errors.duplicateColor(name)
            }

            result[name] = def
        }

        return result
    }

    // swiftlint:disable:next discouraged_optional_collection
    func argumentList(_ count: Int) -> [UInt8]? {
        argumentList(min: count, max: count)
    }

    // swiftlint:disable:next discouraged_optional_collection
    func argumentList(min: Int, max: Int? = nil) -> [UInt8]? {
        let max = max ?? Int.max
        guard
            string("("),
            let arguments = commaSeparated(),
            string(")"),
            (min...max) ~= arguments.count
        else {
            return nil
        }

        return arguments
    }

    // swiftlint:disable:next discouraged_optional_collection
    func commaSeparated() -> [UInt8]? {
        var result: [UInt8] = []
        repeat {
            guard let component = component() else {
                return nil
            }
            result.append(component)
        } while string(",")
        return result
    }

    func component() -> UInt8? {
        guard var int = scanInt() else {
            return nil
        }

        if string("%") {
            guard 0...100 ~= int else { return nil }
            int = int * 0xFF / 100
        }

        return UInt8(exactly: int)
    }
}

private extension Scanner {
    func string(_ string: String) -> Bool {
        scanString(string) != nil
    }
}

private extension CharacterSet {
    static let hex = CharacterSet(charactersIn: "0123456789abcdefABCDEF")
    static let name = alphanumerics.union(CharacterSet(charactersIn: "_/"))
}

private extension Collection {
    func chunks(size: Int) -> UnfoldSequence<Self.SubSequence, Self.Index> {
        sequence(state: startIndex) { state -> SubSequence? in
            guard state != endIndex else { return nil }
            let next = index(state, offsetBy: size, limitedBy: endIndex) ?? endIndex
            defer { state = next }
            return self[state..<next]
        }
    }
}
