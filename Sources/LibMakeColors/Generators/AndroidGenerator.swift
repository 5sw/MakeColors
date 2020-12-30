import Foundation

final class AndroidGenerator: Generator {
    static let defaultExtension = "xml"

    let context: Context

    init(context: Context) {
        self.context = context
    }

    func generate(data: [String: ColorDef]) throws -> FileWrapper {
        var xml = """
        <?xml version="1.0" encoding="utf-8"?>
        <resources>

        """

        let prefix = context.prefix.map { $0.camelCasePathToSnakeCase() + "_" } ?? ""

        for (key, color) in data.sorted() {
            _ = try data.resolve(key)

            let value: String
            switch color {
            case let .color(colorValue): value = colorValue.description
            case let .reference(ref): value = "@color/\(prefix)\(ref.camelCasePathToSnakeCase())"
            }

            xml += """
                <color name="\(prefix)\(key.camelCasePathToSnakeCase())">\(value)</color>

            """
        }

        xml += """
        </resources>
        </xml>

        """

        return FileWrapper(xml)
    }
}
