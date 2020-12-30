extension StringProtocol {
    var capitalizeFirst: String {
        guard !isEmpty else {
            return String(self)
        }

        return prefix(1).uppercased() + dropFirst()
    }

    var lowercasedFirst: String {
        guard !isEmpty else {
            return String(self)
        }

        return prefix(1).lowercased() + dropFirst()
    }

    func droppingSuffix(_ suffix: String) -> SubSequence {
        guard hasSuffix(suffix) else {
            return self[...]
        }

        return dropLast(suffix.count)
    }

    func insertCamelCaseSeparators(separator: String = " ") -> String {
        replacingOccurrences(
            of: "(?<=[a-z0-9])([A-Z])",
            with: "\(separator)$1",
            options: .regularExpression,
            range: nil
        )
    }

    func camelCasePathToSnakeCase() -> String {
        insertCamelCaseSeparators(separator: "_")
            .replacingOccurrences(of: "/", with: "_")
            .lowercased()
    }
}
