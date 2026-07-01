import SwiftUI
import Observation

/// Local store for the user's personal planner. Persists events as JSON in
/// UserDefaults and keeps notification reminders in sync on every change.
@Observable
@MainActor
final class CalendarStore {
    private(set) var events: [PersonalEvent] = []

    @ObservationIgnored private let notifications: NotificationService
    @ObservationIgnored private let calendarSync: CalendarSyncService
    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private static let key = "calendar.events"

    init(notifications: NotificationService,
         calendarSync: CalendarSyncService,
         defaults: UserDefaults = .standard) {
        self.notifications = notifications
        self.calendarSync = calendarSync
        self.defaults = defaults
        load()
    }

    /// All events, soonest-first (past dates included).
    var sorted: [PersonalEvent] { events.sorted { $0.date < $1.date } }

    /// Upcoming events, soonest-first. Keeps items for an hour past their time so
    /// a just-finished quiz doesn't vanish mid-day.
    var upcoming: [PersonalEvent] {
        let cutoff = Date().addingTimeInterval(-3600)
        return sorted.filter { $0.date >= cutoff }
    }

    // MARK: Mutations

    func add(_ event: PersonalEvent) {
        events.append(event)
        persistAndSync()
        syncCalendar(for: event.id)
    }

    func update(_ event: PersonalEvent) {
        guard let i = events.firstIndex(where: { $0.id == event.id }) else { return add(event) }
        // Preserve the mirrored calendar id if the editor didn't carry it through.
        var merged = event
        if merged.calendarEventID == nil { merged.calendarEventID = events[i].calendarEventID }
        events[i] = merged
        persistAndSync()
        syncCalendar(for: merged.id)
    }

    func remove(_ event: PersonalEvent) {
        let removed = events.first { $0.id == event.id }
        events.removeAll { $0.id == event.id }
        persistAndSync()
        if let id = removed?.calendarEventID {
            Task { await calendarSync.remove(identifier: id) }
        }
    }

    func remove(atOffsets offsets: IndexSet, in list: [PersonalEvent]) {
        let removed = offsets.map { list[$0] }
        let ids = Set(removed.map(\.id))
        events.removeAll { ids.contains($0.id) }
        persistAndSync()
        for id in removed.compactMap(\.calendarEventID) {
            Task { await calendarSync.remove(identifier: id) }
        }
    }

    /// Re-sync every reminder with the current events. Safe to call on launch to
    /// self-heal (drops reminders whose dates have passed, restores the rest).
    func reschedule() {
        let snapshot = events
        Task { await notifications.syncReminders(for: snapshot) }
    }

    /// Reconcile one event's mirrored calendar entry with its `syncToCalendar`
    /// flag: create/update when on, remove when off. Writes the resulting
    /// EventKit id back into the stored event.
    private func syncCalendar(for id: UUID) {
        Task {
            guard let event = events.first(where: { $0.id == id }) else { return }
            if event.syncToCalendar {
                // Only record the id on a *successful* upsert. On failure (access
                // denied, no writable calendar, transient save error) upsert returns
                // nil — keep the existing id so we don't orphan a real calendar
                // event or create a duplicate on the next edit.
                if let newID = await calendarSync.upsert(event),
                   let i = events.firstIndex(where: { $0.id == id }),
                   events[i].calendarEventID != newID {
                    events[i].calendarEventID = newID
                    save()
                }
            } else if let existing = event.calendarEventID {
                await calendarSync.remove(identifier: existing)
                if let i = events.firstIndex(where: { $0.id == id }) {
                    events[i].calendarEventID = nil
                    save()
                }
            }
        }
    }

    // MARK: Persistence

    private func persistAndSync() {
        save()
        reschedule()
    }

    private func load() {
        guard let data = defaults.data(forKey: Self.key),
              let decoded = try? JSONDecoder().decode([LossyEvent].self, from: data) else { return }
        // Per-element decode: a single corrupt/legacy record is skipped rather
        // than throwing away the user's entire planner.
        events = decoded.compactMap(\.value)
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(events) else { return }
        defaults.set(data, forKey: Self.key)
    }
}

/// Decodes one planner event, tolerating a malformed element by yielding `nil`
/// instead of failing the whole array decode.
private struct LossyEvent: Decodable {
    let value: PersonalEvent?
    init(from decoder: Decoder) throws {
        value = try? PersonalEvent(from: decoder)
    }
}
