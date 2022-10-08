import Foundation

final class HTMLGenerator: Generator {
    static let defaultExtension = "html"

    static let head = """
    <html>
    <head>
        <style type="text/css">
            .checkered {
                padding: 5px;
                margin: 5px;

                background-image:
                    linear-gradient(45deg, #000 25%, transparent 25%),
                    linear-gradient(45deg, transparent 75%, #000 75%),
                    linear-gradient(45deg, transparent 75%, #000 75%),
                    linear-gradient(45deg, #000 25%, transparent 25%);

                background-size:30px 30px;

                background-position:0 0, 0 0, -15px -15px, 15px 15px;
            }

            .swatch {
                width:50px;
                height:50px;
                display:inline-block;
            }
        </style>
    <body>
    <table>
        <thead>
        <tr>
            <th>&nbsp;</th>
            <th>Name</th>
            <th>Value</th>
        </tr>
        </thead>
        <tbody>

    """

    let context: Context

    init(context: Context) {
        self.context = context
    }

    func generate(data: [String: ColorDef]) throws -> FileWrapper {
        var html = Self.head

        for (key, color) in data.sorted() {
            let actualColor = try data.resolve(key)
            let value: String

            switch color {
            case let .reference(name):
                value = """
                <a href="#cref/\(name)">\(name.insertCamelCaseSeparators())</a><br>\(actualColor)
                """

            case .color:
                value = actualColor.description
            }

            html += """
                <tr>
                    <td class="checkered" id="cref/\(key)">
                        <span style="background:\(actualColor)" class="swatch">&nbsp;</span>
                    </td>
                    <td>\(key.insertCamelCaseSeparators())</td>
                    <td>\(value)</td>
                </tr>

            """
        }

        html += """
        </table>
        </body>
        </html>

        """

        return FileWrapper(html)
    }
}
