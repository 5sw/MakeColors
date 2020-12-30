import Foundation

private extension CharacterSet {
    static let hex = CharacterSet(charactersIn: "0123456789abcdef")
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

extension Scanner {
    func string(_ s: String) -> Bool {
        scanString(s) != nil
    }

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

            default: return nil
            }
        }

        if string("rgba"), string("("), let components = commaSeparated(), components.count == 4, string(")") {
            return Color(components)
        }

        if string("rgb"), string("("), let components = commaSeparated(), components.count == 3, string(")") {
            return Color(components)
        }

        return nil
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
            let name = self.name(),
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

    func commaSeparated() -> [UInt8]? {
        var result: [UInt8] = []
        repeat {
            guard let int = scanInt(), let component = UInt8(exactly: int) else {
                return nil
            }
            result.append(component)
        } while string(",")
        return result
    }
}