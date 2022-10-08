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

private struct ImporterOption: CaseIterable, ExpressibleByArgument, CustomStringConvertible {
    static let allCases: [ImporterOption] = [
        .list,
        .init(type: FigmaImporter.self),
    ]

    static let list = ImporterOption(type: ListImporter.self)

    let type: Importer.Type

    init(type: Importer.Type) {
        self.type = type
    }

    init?(argument: String) {
        guard
            let found = Self.allCases
                .first(where: { $0.description.caseInsensitiveCompare(argument) == .orderedSame })
        else {
            return nil
        }
        self = found
    }

    var description: String {
        type.option
    }

    static func == (lhs: ImporterOption, rhs: ImporterOption) -> Bool {
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

@main
public final class MakeColors: AsyncParsableCommand, Context {
    @Argument(help: HelpTexts.input)
    var input: String

    @Flag(help: "The formatter to use.")
    private var formatter = GeneratorOption.allCases[0]

    @Option(help: "The importer to use.")
    private var importer = ImporterOption.list

    @Option(help: "Prefix for color names.")
    var prefix: String?

    @Option(help: HelpTexts.output)
    var output: String?

    @Flag(help: "List read colors on console.")
    var dump = false

    public init() {}

    public func run() async throws {
        let importer = try importer.type.init(source: input)
        let data = try await importer.read()

        if dump {
            try dump(data: data)
        }

        let generator = formatter.type.init(context: self)
        let fileWrapper = try generator.generate(data: data)

        try writeOutput(fileWrapper, name: output ?? "\(importer.outputName).\(formatter.type.defaultExtension)")
    }

    func dump(data: [String: ColorDef]) throws {
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
    }

    func writeOutput(_ wrapper: FileWrapper, name: String) throws {
        if shouldWriteToStdout {
            guard wrapper.isRegularFile, let contents = wrapper.regularFileContents else {
                throw Errors.cannotWriteWrapperToStdout
            }

            FileHandle.standardOutput.write(contents)
        } else {
            let writeURL = URL(fileURLWithPath: name)
            try wrapper.write(to: writeURL, options: .atomic, originalContentsURL: nil)
        }
    }

    var shouldWriteToStdout: Bool { output == "-" || (input == "-" && output == nil) }
}
