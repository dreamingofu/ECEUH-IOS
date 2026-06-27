import Foundation

/// The five primary tabs, mirroring the Flutter app's PillNav shell.
/// (Academy / Research / Clubs / Ratings / Account.)
enum AppTab: Int, CaseIterable, Identifiable {
    case academy, research, clubs, ratings, account
    var id: Int { rawValue }

    var title: String {
        switch self {
        case .academy:  "Academy"
        case .research: "Research"
        case .clubs:    "Clubs"
        case .ratings:  "Ratings"
        case .account:  "Account"
        }
    }

    var symbol: String {
        switch self {
        case .academy:  "graduationcap.fill"
        case .research: "testtube.2"
        case .clubs:    "person.3.fill"
        case .ratings:  "chart.bar.fill"
        case .account:  "person.crop.circle"
        }
    }
}

/// Typed navigation destinations pushed within a tab's `NavigationStack`.
/// Mirrors the GoRouter nested routes (`/archives/course/:slug/...`, `/clubs/:slug`).
enum Route: Hashable {
    case courseHub(slug: String)
    case fileLibrary(slug: String)
    case externalLinks(slug: String)
    case clubDetail(slug: String)
    case privacy
    case deleteAccount
}
