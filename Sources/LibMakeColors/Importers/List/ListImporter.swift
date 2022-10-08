import Foundation

struct ListImporter: Importer {
    let input: String

    init(source: String) {
        input = source
    }

    func read() throws -> [String: ColorDef] {
        let scanner = Scanner(string: try readInput())
        scanner.charactersToBeSkipped = .whitespaces

        return try scanner.colorList()
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
}
