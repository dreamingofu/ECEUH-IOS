import SwiftUI
import Observation

/// Tracks the user's active courses for the current term and the semester's
/// start/end dates. Progress is **purely time-based** — the fraction of the
/// semester that has elapsed — and deliberately has nothing to do with whether
/// files were opened (that's `ProgressService`). Persisted locally as JSON.
@Observable
@MainActor
final class SemesterStore {
    private(set) var courseSlugs: [String] = []
    private(set) var start: Date
    private(set) var end: Date
    /// True once the user has completed setup at least once.
    private(set) var isConfigured = false

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private static let key = "semester.config"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let now = Date()
        start = now
        end = Calendar.current.date(byAdding: .weekOfYear, value: 16, to: now) ?? now
        load()
    }

    /// The selected courses, resolved from the catalog in catalog order.
    var activeCourses: [Course] { kCourses.filter { courseSlugs.contains($0.slug) } }

    /// Where "now" sits relative to the semester window.
    enum Phase { case upcoming, active, complete }
    var phase: Phase {
        let now = Date()
        if now < start { return .upcoming }
        if now >= end { return .complete }
        return .active
    }

    /// Fraction of the semester elapsed (0…1), clamped. Fills on a time basis.
    var progress: Double {
        let total = end.timeIntervalSince(start)
        guard total > 0 else { return 0 }
        return min(1, max(0, Date().timeIntervalSince(start) / total))
    }

    /// Total whole weeks in the semester window (at least 1).
    var totalWeeks: Int {
        max(1, Int((end.timeIntervalSince(start) / (7 * 86_400)).rounded()))
    }

    /// 1-based current week within the semester (0 before it starts).
    var currentWeek: Int {
        let elapsed = Date().timeIntervalSince(start)
        guard elapsed > 0 else { return 0 }
        return min(totalWeeks, Int(elapsed / (7 * 86_400)) + 1)
    }

    /// Days until the semester starts (for the upcoming phase).
    var daysUntilStart: Int {
        let cal = Calendar.current
        return max(0, cal.dateComponents([.day], from: cal.startOfDay(for: Date()),
                                         to: cal.startOfDay(for: start)).day ?? 0)
    }

    func save(courseSlugs: [String], start: Date, end: Date) {
        self.courseSlugs = courseSlugs
        self.start = start
        self.end = end
        isConfigured = true
        persist()
    }

    // MARK: Persistence

    private struct Config: Codable {
        var courseSlugs: [String]
        var start: Date
        var end: Date
        var configured: Bool
    }

    private func load() {
        guard let data = defaults.data(forKey: Self.key),
              let c = try? JSONDecoder().decode(Config.self, from: data) else { return }
        courseSlugs = c.courseSlugs
        start = c.start
        end = c.end
        isConfigured = c.configured
    }

    private func persist() {
        let config = Config(courseSlugs: courseSlugs, start: start, end: end, configured: isConfigured)
        guard let data = try? JSONEncoder().encode(config) else { return }
        defaults.set(data, forKey: Self.key)
    }
}
