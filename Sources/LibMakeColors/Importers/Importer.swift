protocol Importer {
    init(source: String) throws

    func read() throws -> [String: ColorDef]
}
