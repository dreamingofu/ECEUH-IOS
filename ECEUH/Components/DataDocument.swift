import SwiftUI
import UniformTypeIdentifiers

/// A minimal `FileDocument` wrapping raw bytes, so SwiftUI's `.fileExporter` can
/// write an already-downloaded file (e.g. a PDF) to a user-chosen Files location.
struct DataDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.pdf, .data] }

    var data: Data

    init(_ data: Data) { self.data = data }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}
