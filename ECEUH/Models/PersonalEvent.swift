import SwiftUI

/// The kind of graded item a planner entry represents. Colors and icons reuse the
/// file-type palette, so a "Quiz" reads the same here as it does in the archives.
enum EventKind: String, Codable, CaseIterable, Identifiable, Hashable {
    case quiz, exam, homework, lab, project, other
    var id: String { rawValue }

    var label: String {
        switch self {
        case .quiz:     "Quiz"
        case .exam:     "Exam"
        case .homework: "Homework"
        case .lab:      "Lab"
        case .project:  "Project"
        case .other:    "Other"
        }
    }
    var icon: String {
        switch self {
        case .quiz:     "pencil.and.list.clipboard"
        case .exam:     "doc.badge.clock"
        case .homework: "book.closed.fill"
        case .lab:      "flask.fill"
        case .project:  "hammer.fill"
        case .other:    "calendar"
        }
    }
    var color: Color {
        switch self {
        case .quiz:     EE.quiz
        case .exam:     EE.exam
        case .homework: EE.homework
        case .lab:      EE.lab
        case .project:  EE.classwork
        case .other:    EE.reference
        }
    }
}

/// A user-entered date on their personal planner (a quiz, exam, deadline…).
/// Professors move these constantly, so students keep their own copy and get
/// reminders off it. Persisted locally as JSON in `CalendarStore`.
struct PersonalEvent: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var title: String
    var kind: EventKind = .quiz
    var date: Date
    var courseSlug: String? = nil
    var notes: String = ""
    /// Minutes-before-`date` at which to fire a reminder (e.g. 1440 = one day out).
    var reminderLeads: [Int] = [1440, 60]
    /// When true, this event is mirrored into the device (Apple/Google) Calendar.
    var syncToCalendar: Bool = false
    /// The EventKit identifier of the mirrored calendar event, once created.
    var calendarEventID: String? = nil

    /// The course code for a linked course, if any (e.g. "ECE 3441").
    var courseCode: String? { courseSlug.flatMap { courseBySlug($0)?.code } }

    /// The fire time for a given lead, or `nil` if that reminder is already in the past.
    func fireDate(leadMinutes: Int, now: Date = Date()) -> Date? {
        let fire = date.addingTimeInterval(TimeInterval(-leadMinutes * 60))
        return fire > now ? fire : nil
    }
}

/// The reminder lead-times offered in the event editor (minutes before the date).
enum ReminderLead: Int, CaseIterable, Identifiable {
    case atTime = 0, min10 = 10, min30 = 30, hour1 = 60, hours3 = 180
    case day1 = 1440, day2 = 2880, week1 = 10080
    var id: Int { rawValue }

    var label: String {
        switch self {
        case .atTime: "At time of event"
        case .min10:  "10 minutes before"
        case .min30:  "30 minutes before"
        case .hour1:  "1 hour before"
        case .hours3: "3 hours before"
        case .day1:   "1 day before"
        case .day2:   "2 days before"
        case .week1:  "1 week before"
        }
    }
}
