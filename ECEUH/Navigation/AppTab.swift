import Foundation

/// The four primary tabs of the redesigned app (Home, Archives, Faculty, Settings).
enum AppTab: Int, CaseIterable, Identifiable {
    case home, archives, faculty, settings
    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home:     "Home"
        case .archives: "Archives"
        case .faculty:  "Faculty"
        case .settings: "Settings"
        }
    }

    var symbol: String {
        switch self {
        case .home:     "house.fill"
        case .archives: "books.vertical.fill"
        case .faculty:  "star.fill"
        case .settings: "gearshape.fill"
        }
    }
}

/// Typed navigation destinations pushed within a tab's `NavigationStack`.
enum Route: Hashable {
    case courseDetail(slug: String)
    case fileLibrary(slug: String)
    case externalLinks(slug: String)
    case clubs
    case clubDetail(slug: String)
    case privacy
    case deleteAccount
}
