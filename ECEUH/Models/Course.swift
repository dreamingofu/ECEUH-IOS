import Foundation

/// A course in the ECE knowledge base. 1:1 port of `lib/models/course.dart`.
struct Course: Identifiable, Hashable {
    let slug: String
    let code: String
    let title: String
    var archiveTitle: String? = nil
    let desc: String
    let level: Int
    let units: Int
    let art: String
    let isLive: Bool
    var hub: CourseHub? = nil
    var sections: CourseSections? = nil

    var id: String { slug }

    /// Title used in the archives catalog; falls back to `title`.
    var displayArchiveTitle: String { archiveTitle ?? title }
}

/// Landing-page metadata for a live course's hub screen.
struct CourseHub: Hashable {
    let routeName: String // e.g. "course"
    let kicker: String
    let title: String
    let desc: String
}

/// References to a live course's sub-sections (files / links / topics).
struct CourseSections: Hashable {
    var files: SectionRef? = nil
    var links: SectionRef? = nil
    var topics: SectionRef? = nil
}

/// A titled, described pointer to a course sub-section.
struct SectionRef: Hashable {
    let title: String
    let desc: String
}
