import Foundation

/// File classification. 1:1 port of `lib/models/file_entry.dart`.
enum FileType: String, CaseIterable, Hashable {
    case reference, classwork, quiz, exam, homework, lab

    var label: String {
        switch self {
        case .reference: "Reference"
        case .classwork: "Classwork"
        case .quiz:      "Quiz"
        case .exam:      "Exam"
        case .homework:  "Homework"
        case .lab:       "Lab"
        }
    }
}

/// A single course document, possibly with multiple versions.
struct FileEntry: Identifiable, Hashable {
    let type: FileType
    let label: String
    let title: String
    let desc: String
    let versions: [FileVersion]

    var id: String { primary.url }

    /// First PDF version, else the first version.
    var primary: FileVersion {
        versions.first { $0.url.lowercased().hasSuffix(".pdf") } ?? versions[0]
    }

    var versionCount: Int { versions.count }
}

/// A named, addressable version of a file.
struct FileVersion: Hashable {
    let label: String
    let url: String

    /// Uppercased file extension (without the dot), query string stripped.
    /// (`extension` is a Swift keyword, so this is named `ext`.)
    var ext: String {
        let clean = url.components(separatedBy: "?").first ?? url
        guard let dot = clean.lastIndex(of: ".") else { return "" }
        return String(clean[clean.index(after: dot)...]).uppercased()
    }
}
