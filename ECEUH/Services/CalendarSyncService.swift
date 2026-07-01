import EventKit
import Observation

/// Mirrors planner events into the device calendar via EventKit. If the user has
/// added their Google account under iOS Settings → Calendar, events written here
/// sync to Google Calendar automatically (CalDAV) — so this is "Google Calendar
/// sync" without any Google Cloud setup or third-party SDK.
///
/// We request **full access** (not write-only) on purpose: to keep a mirrored
/// event consistent with later edits/deletes we must read it back by identifier,
/// which write-only access forbids.
@Observable
@MainActor
final class CalendarSyncService {
    /// Latest known EventKit authorization for calendar events.
    private(set) var status: EKAuthorizationStatus = EKEventStore.authorizationStatus(for: .event)

    @ObservationIgnored private let store = EKEventStore()

    /// Whether we can create and manage mirrored events.
    var canManage: Bool { status == .fullAccess }
    /// Whether the user has explicitly refused calendar access.
    var isDenied: Bool { status == .denied || status == .restricted }

    func refreshStatus() {
        status = EKEventStore.authorizationStatus(for: .event)
    }

    /// Request full calendar access in context. Returns true once granted.
    @discardableResult
    func requestAccess() async -> Bool {
        if status == .fullAccess { return true }
        let granted = (try? await store.requestFullAccessToEvents()) ?? false
        refreshStatus()
        return granted
    }

    /// Create or update the calendar event mirroring a planner event. Returns the
    /// EventKit identifier to persist, or nil if access was refused / the save failed.
    func upsert(_ event: PersonalEvent) async -> String? {
        guard await requestAccess() else { return nil }

        let ekEvent: EKEvent
        if let id = event.calendarEventID, let existing = store.event(withIdentifier: id) {
            ekEvent = existing
        } else {
            ekEvent = EKEvent(eventStore: store)
            ekEvent.calendar = store.defaultCalendarForNewEvents
        }
        guard ekEvent.calendar != nil else { return nil }

        ekEvent.title = event.title.isEmpty ? event.kind.label : event.title
        ekEvent.startDate = event.date
        ekEvent.endDate = event.date.addingTimeInterval(3600)  // 1-hour block
        ekEvent.notes = notes(for: event)
        ekEvent.alarms = event.reminderLeads.map { EKAlarm(relativeOffset: TimeInterval(-$0 * 60)) }

        do {
            try store.save(ekEvent, span: .thisEvent, commit: true)
            return ekEvent.eventIdentifier
        } catch {
            return nil
        }
    }

    /// Remove a previously-mirrored calendar event.
    func remove(identifier: String) async {
        guard await requestAccess() else { return }
        guard let ekEvent = store.event(withIdentifier: identifier) else { return }
        try? store.remove(ekEvent, span: .thisEvent, commit: true)
    }

    private func notes(for event: PersonalEvent) -> String {
        var parts: [String] = []
        if let code = event.courseCode { parts.append(code) }
        if !event.notes.isEmpty { parts.append(event.notes) }
        parts.append("Added from the ECEUH planner.")
        return parts.joined(separator: "\n")
    }
}
