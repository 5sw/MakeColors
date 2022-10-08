protocol Importer {
    init(source: String) throws

    func read() async throws -> [String: ColorDef]

    var outputName: String { get }

    static var option: String { get }
}

extension Importer {
    static var option: String {
        String(describing: self).droppingSuffix("Importer").lowercased()
    }
}
