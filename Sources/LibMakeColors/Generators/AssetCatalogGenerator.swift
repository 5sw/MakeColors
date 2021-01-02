import Foundation

final class AssetCatalogGenerator: Generator {
    static let defaultExtension = "xcassets"
    static let option = "ios"

    let context: Context

    init(context: Context) {
        self.context = context
    }

    func generate(data: [String: ColorDef]) throws -> FileWrapper {
        let root = FileWrapper(directoryWithFileWrappers: ["Contents.json": FileWrapper(catalog)])
        let colorRoot: FileWrapper

        if let prefix = context.prefix?.insertCamelCaseSeparators() {
            colorRoot = FileWrapper(directoryWithFileWrappers: ["Contents.json": FileWrapper(group)])
            colorRoot.filename = prefix
            colorRoot.preferredFilename = prefix
            root.addFileWrapper(colorRoot)
        } else {
            colorRoot = root
        }

        for key in data.keys {
            var path = key.insertCamelCaseSeparators().split(separator: "/").map(\.capitalizeFirst)
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

        return root
    }
}

private let infoTag = """
"info" : {
    "author" : "de.5sw.MakeColors",
    "version" : 1
}
"""

extension Color {
    func json() -> String {
        """
        {
        "colors" : [
            {
            "color" : {
                "color-space" : "srgb",
                "components" : {
                "alpha" : "\(Double(alpha) / 0xFF)",
                "blue" : "0x\(blue, radix: 16, width: 2)",
                "green" : "0x\(green, radix: 16, width: 2)",
                "red" : "0x\(red, radix: 16, width: 2)"
                }
            },
            "idiom" : "universal"
            }
        ],
        \(infoTag)
        }
        """
    }

    func fileWrapper() -> FileWrapper {
        FileWrapper(directoryWithFileWrappers: [
            "Contents.json": FileWrapper(json()),
        ])
    }
}

extension String.StringInterpolation {
    mutating func appendInterpolation<I: BinaryInteger>(
        _ value: I,
        radix: Int,
        width: Int = 0,
        uppercase: Bool = true
    ) {
        var string = String(value, radix: radix, uppercase: uppercase)
        if width > string.count {
            string.insert(contentsOf: String(repeating: "0", count: width - string.count), at: string.startIndex)
        }

        appendLiteral(string)
    }
}

private let group = """
{
  "properties" : {
    "provides-namespace" : true
  },
  \(infoTag)
}
"""

private let catalog = """
{
\(infoTag)
}
"""
