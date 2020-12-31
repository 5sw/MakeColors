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
    case cannotWriteWrapperToStdout
    case cannotReadStdin
}

enum HelpTexts {
    static let input = ArgumentHelp(
        "The color list to process.",
        discussion: """
        Use - to process the standard input.
        """
    )

    static let output = ArgumentHelp(
        "Output file to write.",
        discussion: """
        Use - for standard output.
        Default is the input file name with the appropriate file extension. \
        If the input is - the default is standard output.
        Note that asset catalogs cannot be written to standard output.
        """
    )
}

public final class MakeColors: ParsableCommand, Context {
    @Argument(help: HelpTexts.input)
    var input: String

    @Flag(help: "The formatter to use.")
    private var formatter = GeneratorOption.allCases[0]

    @Option(help: "Prefix for color names.")
    var prefix: String?

    @Option(help: HelpTexts.output)
    var output: String?

    public init() {}

    public func run() throws {
        let scanner = Scanner(string: try readInput())
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

        try writeOutput(fileWrapper)
    }

    func readInput() throws -> String {
        if input == "-" {
            return try readStdin()
        }

        let url = URL(fileURLWithPath: input)
        return try String(contentsOf: url)
    }

    func readStdin() throws -> String {
        guard
            let data = try FileHandle.standardInput.readToEnd(),
            let input = String(data: data, encoding: .utf8)
        else {
            throw Errors.cannotReadStdin
        }

        return input
    }

    func writeOutput(_ wrapper: FileWrapper) throws {
        if shouldWriteToStdout {
            guard wrapper.isRegularFile, let contents = wrapper.regularFileContents else {
                throw Errors.cannotWriteWrapperToStdout
            }

            FileHandle.standardOutput.write(contents)
        } else {
            let writeURL = outputURL(extension: formatter.type.defaultExtension)
            try wrapper.write(to: writeURL, options: .atomic, originalContentsURL: nil)
        }
    }

    var shouldWriteToStdout: Bool { output == "-" || (input == "-" && output == nil) }

    func outputURL(extension: String) -> URL {
        if let output = output {
            return URL(fileURLWithPath: output)
        } else {
            let basename = URL(fileURLWithPath: input).deletingPathExtension().lastPathComponent
            return URL(fileURLWithPath: basename).appendingPathExtension(`extension`)
        }
    }
}
