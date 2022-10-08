import Foundation

protocol Generator: AnyObject {
    static var defaultExtension: String { get }
    static var option: String { get }

    init(context: Context)

    func generate(data: [String: ColorDef]) throws -> FileWrapper
}

protocol Context: AnyObject {
    var prefix: String? { get }
}

extension Generator {
    static var option: String {
        String(String(describing: self).droppingSuffix("Generator"))
    }
}
