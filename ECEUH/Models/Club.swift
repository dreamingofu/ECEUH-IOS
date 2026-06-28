import SwiftUI

/// Category buckets in the UH Cullen College of Engineering club directory.
enum ClubCategory: String, CaseIterable, Hashable {
    case engineering = "Engineering"
    case technology = "Technology"
    case honorSociety = "Honor Society"

    /// Accent color used for the club's avatar tile and category label.
    var color: Color {
        switch self {
        case .engineering:  EE.accent
        case .technology:   EE.blue
        case .honorSociety: EE.exam
        }
    }
}

/// A UH student organization (source: official Cullen College club directory).
struct Club: Identifiable, Hashable {
    let slug: String
    let name: String
    let acronym: String?
    let category: ClubCategory
    let email: String?
    let website: String?
    let tags: [String]
    let featured: Bool
    var isActive: Bool = true

    var id: String { slug }

    var hasLinks: Bool { email != nil || website != nil }

    /// Short label for the avatar tile — the acronym, else the name's initials.
    var badge: String {
        if let acronym, !acronym.isEmpty { return acronym }
        let initials = name.split(separator: " ").prefix(3).compactMap { $0.first }
        return String(initials).uppercased()
    }
}
