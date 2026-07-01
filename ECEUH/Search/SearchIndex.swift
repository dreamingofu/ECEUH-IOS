import SwiftUI

/// The category a global-search hit belongs to — drives its icon, tint, and label.
enum SearchKind {
    case course, file, link, club, professor

    var icon: String {
        switch self {
        case .course:    "book.closed.fill"
        case .file:      "doc.text.fill"
        case .link:      "link"
        case .club:      "person.3.fill"
        case .professor: "person.crop.circle.fill"
        }
    }
    var tint: Color {
        switch self {
        case .course:    EE.accent
        case .file:      EE.homework
        case .link:      EE.blue
        case .club:      EE.lab
        case .professor: EE.exam
        }
    }
    var label: String {
        switch self {
        case .course:    "Course"
        case .file:      "File"
        case .link:      "Resource"
        case .club:      "Club"
        case .professor: "Professor"
        }
    }
}

/// Where tapping a search hit navigates — either a pushed `Route` (within the
/// Home stack) or a top-level tab switch (faculty has no dedicated detail page).
enum SearchDestination: Hashable {
    case route(Route)
    case tab(AppTab)
}

/// A single global-search hit across the whole app.
struct SearchResult: Identifiable, Hashable {
    let id: String
    let kind: SearchKind
    let title: String
    let subtitle: String
    let destination: SearchDestination
    /// Lowercased combined text every query token is matched against.
    let haystack: String
}

/// Builds and queries the app-wide search index (courses, files, resources,
/// clubs, and faculty). The index is static data, so it's built once and reused.
enum AppSearch {
    /// The full index, assembled once from the bundled data.
    static let index: [SearchResult] = build()

    /// Ranked hits for a query. Every whitespace-separated token must appear in a
    /// record; title-prefix matches rank above title-contains above body matches.
    static func results(for raw: String, limit: Int = 14) -> [SearchResult] {
        let q = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return [] }
        let tokens = q.split(separator: " ").map(String.init)

        return index
            .compactMap { r -> (result: SearchResult, score: Int)? in
                guard tokens.allSatisfy({ r.haystack.contains($0) }) else { return nil }
                let title = r.title.lowercased()
                let score = title.hasPrefix(q) ? 0 : (title.contains(q) ? 1 : 2)
                return (r, score)
            }
            .sorted { a, b in
                a.score != b.score
                    ? a.score < b.score
                    : a.result.title.localizedCaseInsensitiveCompare(b.result.title) == .orderedAscending
            }
            .prefix(limit)
            .map(\.result)
    }

    private static func build() -> [SearchResult] {
        var out: [SearchResult] = []

        // Courses that actually have content — and everything inside them.
        for course in coursesWithContent {
            out.append(SearchResult(
                id: "course.\(course.slug)",
                kind: .course,
                title: course.displayArchiveTitle,
                subtitle: "\(course.code) · Course",
                destination: .route(.courseDetail(slug: course.slug)),
                haystack: [course.code, course.title, course.displayArchiveTitle, course.desc, course.slug]
                    .joined(separator: " ").lowercased()))

            for file in kCourseFiles[course.slug] ?? [] {
                out.append(SearchResult(
                    id: "file.\(course.slug).\(file.id)",
                    kind: .file,
                    title: file.title,
                    subtitle: "\(course.code) · \(file.type.label)",
                    destination: .route(.fileLibrary(slug: course.slug)),
                    haystack: [file.title, file.desc, file.type.label, file.label, course.code]
                        .joined(separator: " ").lowercased()))
            }

            for link in kCourseLinks[course.slug] ?? [] {
                out.append(SearchResult(
                    id: "link.\(course.slug).\(link.id)",
                    kind: .link,
                    title: link.title,
                    subtitle: "\(course.code) · Resource",
                    destination: .route(.externalLinks(slug: course.slug)),
                    haystack: [link.title, link.desc, course.code].joined(separator: " ").lowercased()))
            }
        }

        // Active clubs.
        for club in kClubs where club.isActive {
            out.append(SearchResult(
                id: "club.\(club.slug)",
                kind: .club,
                title: club.name,
                subtitle: "\(club.category.rawValue) · Club",
                destination: .route(.clubDetail(slug: club.slug)),
                haystack: ([club.name, club.acronym ?? "", club.category.rawValue] + club.tags)
                    .joined(separator: " ").lowercased()))
        }

        // Professors → the Faculty tab. Group each professor across every course
        // they teach (so they're findable by ANY of those course codes/titles),
        // preserve first-seen order, and skip the "TBD" placeholder entries.
        var profOrder: [String] = []
        var profInfo: [String: (prof: Professor, courses: [ProfessorCourse])] = [:]
        for pc in kProfessorCourses {
            for prof in pc.profs {
                guard prof.name != "Prof. Name", prof.shortName != "TBD" else { continue }
                if profInfo[prof.name] == nil {
                    profOrder.append(prof.name)
                    profInfo[prof.name] = (prof, [pc])
                } else {
                    profInfo[prof.name]?.courses.append(pc)
                }
            }
        }
        for name in profOrder {
            guard let info = profInfo[name] else { continue }
            let courseTerms = info.courses.flatMap { [$0.code, $0.title] }
            out.append(SearchResult(
                id: "prof.\(name)",
                kind: .professor,
                title: info.prof.name,
                subtitle: "\(info.prof.dept) · Professor",
                destination: .tab(.faculty),
                haystack: ([info.prof.name, info.prof.shortName, info.prof.dept] + courseTerms)
                    .joined(separator: " ").lowercased()))
        }

        return out
    }
}
