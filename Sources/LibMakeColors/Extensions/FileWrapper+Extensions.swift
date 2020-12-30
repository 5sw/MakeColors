import Foundation

extension FileWrapper {
    convenience init(_ string: String) {
        self.init(regularFileWithContents: Data(string.utf8))
    }
}
