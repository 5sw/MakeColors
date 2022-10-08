protocol Importer {
    init(source: String) throws

    func read() throws -> [String: ColorDef]

    static var option: String { get }
}

extension Importer {
    static var option: String {
        String(describing: self).droppingSuffix("Importer").lowercased()
    }
}
