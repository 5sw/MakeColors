import ArgumentParser
import Foundation

enum Formatter: String, EnumerableFlag {
    case ios
    case android
    case html
}

enum Errors: Error {
    case syntaxError
    case duplicateColor(String)
    case missingReference(String)
    case cyclicReference(String)
}

public struct MakeColors: ParsableCommand {
    @Argument(help: "The color list to proces")
    var input: String

    @Flag(help: "The formatter to use")
    var formatter = Formatter.ios

    @Option(help: "Prefix for color names")
    var prefix: String?

    @Option(help: "Output file")
    var output: String?

    public init() {}

    public func run() throws {
        let url = URL(fileURLWithPath: input)
        let string = try String(contentsOf: url)

        let scanner = Scanner(string: string)
        scanner.charactersToBeSkipped = .whitespaces

        let data = try scanner.colorList()

        print(data)

        switch formatter {
        case .ios:
            try writeAssetCatalog(data: data)

        case .android:
            try writeAndroidXML(data: data)

        case .html:
            try writeHtmlPreview(data: data)
        }
    }

    func outputURL(extension: String) -> URL {
        if let output = output {
            return URL(fileURLWithPath: output)
        } else {
            return URL(fileURLWithPath: input).deletingPathExtension().appendingPathExtension(`extension`)
        }
    }

    func mapColorName(_ name: String) -> String {
        mapSpaceColorName(name, separator: "_")
            .replacingOccurrences(of: "/", with: "_")
            .lowercased()
    }

    func mapSpaceColorName(_ name: String, separator: String = " ") -> String {
        name.replacingOccurrences(
            of: "(?<=[a-z0-9])([A-Z])",
            with: "\(separator)$1",
            options: .regularExpression,
            range: nil
        )
    }

    func writeAndroidXML(data: [String: ColorDef]) throws {
        var xml = """
        <?xml version="1.0" encoding="utf-8"?>
        <resources>

        """

        let prefix = self.prefix.map { mapColorName($0) + "_" } ?? ""

        for (key, color) in data.sorted(by: compare) {
            _ = try data.resolve(key)

            let value: String
            switch color {
            case .color(let colorValue): value = colorValue.description
            case .reference(let ref): value = "@color/\(prefix)\(mapColorName(ref))"
            }

            xml += """
                <color name="\(prefix)\(mapColorName(key))">\(value)</color>

            """
        }

        xml += """
        </resources>
        </xml>

        """

        try xml.write(to: outputURL(extension: "xml"), atomically: true, encoding: .utf8)
    }

    func writeHtmlPreview(data: [String: ColorDef]) throws {
        var html = """
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

        for (key, color) in data.sorted(by: compare) {
            let actualColor = try data.resolve(key)
            let value: String

            switch color {
            case let .reference(name): value = """
                <a href="#cref/\(name)">\(mapSpaceColorName(name))</a><br>\(actualColor)
                """
            case .color: value = actualColor.description
            }

            html += """
                <tr>
                    <td class="checkered" id="cref/\(key)"><span style="background:\(actualColor); width:50px; height:50px;display:inline-block;">&nbsp;&nbsp;</span></td>
                    <td>\(mapSpaceColorName(key))</td>
                    <td>\(value)</td>
                </tr>

            """
        }

        html += """
        </table>
        </body>
        </html>

        """

        try html.write(to: outputURL(extension: "html"), atomically: true, encoding: .utf8)
    }

    func writeAssetCatalog(data: [String: ColorDef]) throws {
        let root = FileWrapper(directoryWithFileWrappers: ["Contents.json" : FileWrapper(catalog)])
        let colorRoot: FileWrapper

        if let prefix = prefix {
            let name = mapSpaceColorName(prefix)
            colorRoot = FileWrapper(directoryWithFileWrappers: ["Contents.json": FileWrapper(group)])
            colorRoot.filename = name
            colorRoot.preferredFilename = name
            root.addFileWrapper(colorRoot)
        } else {
            colorRoot = root
        }

        for key in data.keys {
            var path = mapSpaceColorName(key).split(separator: "/").map(\.capitalizeFirst)
            let colorSet = path.removeLast()

            var current = colorRoot
            for pathSegment in path {
                if let next = current.fileWrappers?[pathSegment] {
                    current = next
                } else {
                    let next = FileWrapper(directoryWithFileWrappers: ["Contents.json": FileWrapper(group)])
                    next.filename = pathSegment
                    next.preferredFilename = pathSegment
                    _ = current.addFileWrapper(next)
                    current = next
                }
            }

            let colorWrapper = try data.resolve(key).fileWrapper()
            colorWrapper.filename = "\(colorSet).colorset"
            colorWrapper.preferredFilename = "\(colorSet).colorset"

            current.addFileWrapper(colorWrapper)
        }

        let outputUrl = outputURL(extension: "xcassets")

        try root.write(to: outputUrl, options: .atomic, originalContentsURL: nil)
    }
}

extension StringProtocol {
    var capitalizeFirst: String {
        guard !isEmpty else {
            return String(self)
        }

        return prefix(1).uppercased() + dropFirst()
    }
}

func compareDef(_ a: ColorDef, _ b: ColorDef) -> ComparisonResult {
    switch (a, b) {
    case (.color, .reference): return .orderedAscending
    case (.reference, .color): return .orderedDescending
    case (.color, .color), (.reference, .reference): return .orderedSame
    }
}

func compare(_ a: (String, ColorDef), b: (String, ColorDef)) -> Bool {
    switch (compareDef(a.1, b.1)) {
    case .orderedAscending: return true
    case .orderedDescending: return false
    case .orderedSame: return a.0.localizedStandardCompare(b.0) == .orderedAscending
    }
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

}

extension Color {
    func json() -> String {
        return """
        {
        "colors" : [
            {
            "color" : {
                "color-space" : "srgb",
                "components" : {
                "alpha" : "\(Float(a) / 256)",
                "blue" : "0x\(String(b, radix: 16))",
                "green" : "0x\(String(g, radix: 16))",
                "red" : "0x\(String(r, radix: 16))"
                }
            },
            "idiom" : "universal"
            }
        ],
        "info" : {
            "author" : "xcode",
            "version" : 1
        }
        }
        """
    }

    func fileWrapper() -> FileWrapper {
        FileWrapper(directoryWithFileWrappers: [
            "Contents.json": FileWrapper(json())
        ])
    }
}

extension FileWrapper {
    convenience init(_ string: String) {
        self.init(regularFileWithContents: Data(string.utf8))
    }
}

let group = """
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  },
  "properties" : {
    "provides-namespace" : true
  }
}
"""

let catalog = """
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
"""

