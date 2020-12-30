import ArgumentParser
import Foundation

private struct GeneratorOption: EnumerableFlag, CustomStringConvertible {
    static let allCases: [GeneratorOption] = [
        .init(type: AssetCatalogGenerator.self),
        .init(type: AndroidGenerator.self),
        .init(type: HTMLGenerator.self),
    ]

    let type: Generator.Type

    var description: String {
        type.option
    }

    static func == (lhs: GeneratorOption, rhs: GeneratorOption) -> Bool {
        lhs.type == rhs.type
    }
}

enum Errors: Error {
    case syntaxError
    case duplicateColor(String)
    case missingReference(String)
    case cyclicReference(String)
}

public final class MakeColors: ParsableCommand, Context {
    @Argument(help: "The color list to proces")
    var input: String

    @Flag(help: "The formatter to use")
    private var formatter = GeneratorOption.allCases[0]

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

        for (key, color) in data.sorted() {
            let resolved = try data.resolve(key)
            switch color {
            case .color:
                print(key.insertCamelCaseSeparators(), resolved, separator: ": ")

            case let .reference(referenced):
                print(
                    "\(key.insertCamelCaseSeparators()) (@\(referenced.insertCamelCaseSeparators()))",
                    resolved,
                    separator: ": "
                )
            }
        }

        let generator = formatter.type.init(context: self)
        let fileWrapper = try generator.generate(data: data)

        let writeURL = outputURL(extension: formatter.type.defaultExtension)
        try fileWrapper.write(to: writeURL, options: .atomic, originalContentsURL: nil)
    }

    func outputURL(extension: String) -> URL {
        if let output = output {
            return URL(fileURLWithPath: output)
        } else {
            let basename = URL(fileURLWithPath: input).deletingPathExtension().lastPathComponent
            return URL(fileURLWithPath: basename).appendingPathExtension(`extension`)
        }
    }
}
