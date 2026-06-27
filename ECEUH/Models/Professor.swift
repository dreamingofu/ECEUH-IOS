import Foundation

/// A course grouping of professors. 1:1 port of `lib/models/professor.dart`.
struct ProfessorCourse: Identifiable, Hashable {
    let id: String
    let code: String
    let title: String
    let profs: [Professor]
}

/// A professor with optional RateMyProfessors data.
struct Professor: Hashable {
    let name: String
    let shortName: String
    let initials: String
    let dept: String
    var overall: Double? = nil
    var difficulty: Double? = nil
    var wouldTake: Int? = nil
    var rmpUrl: String? = nil

    var hasRating: Bool { overall != nil }

    /// Title-prefixed short name, e.g. "Dr. Landon" (mirrors the Dart regex
    /// `^(Dr\.|Prof\.|Mr\.|Ms\.|Mrs\.)\s+`).
    var title: String {
        let prefixes = ["Dr.", "Prof.", "Mr.", "Ms.", "Mrs."]
        let prefix = prefixes.first { name.hasPrefix($0 + " ") } ?? ""
        return "\(prefix) \(shortName)".trimmingCharacters(in: .whitespaces)
    }
}
