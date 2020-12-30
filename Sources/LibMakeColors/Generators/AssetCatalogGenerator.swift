import Foundation

final class AssetCatalogGenerator: Generator {
    static let defaultExtension = "xcasset"
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

private extension Color {
    func json() -> String {
        """
        {
        "colors" : [
            {
            "color" : {
                "color-space" : "srgb",
                "components" : {
                "alpha" : "\(Float(alpha) / 256)",
                "blue" : "0x\(String(blue, radix: 16))",
                "green" : "0x\(String(green, radix: 16))",
                "red" : "0x\(String(red, radix: 16))"
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
            "Contents.json": FileWrapper(json()),
        ])
    }
}

private let group = """
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

private let catalog = """
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
"""
