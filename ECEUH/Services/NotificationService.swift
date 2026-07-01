import SwiftUI
import UserNotifications
import UIKit
import Observation

/// Backs the real notification toggles in Settings (no longer placeholders).
/// Persists each toggle in UserDefaults and requests APNs authorization in
/// context when a toggle is enabled. Actual push *delivery* requires a real
/// device + an APNs key on the server; the permission flow and toggles are
/// fully testable on the simulator.
@Observable
@MainActor
final class NotificationService {
    var newFilesEnabled: Bool
    var newRatingsEnabled: Bool
    var securityAlertsEnabled: Bool

    /// Latest known authorization status (refreshed via `refreshStatus()`).
    var status: UNAuthorizationStatus = .notDetermined

    @ObservationIgnored private let center = UNUserNotificationCenter.current()
    @ObservationIgnored private let defaults: UserDefaults
    /// Retained so planner reminders still present as banners while the app is
    /// open (the center holds its delegate weakly).
    @ObservationIgnored private let presenter = ForegroundPresenter()

    /// Identifier prefix for every planner reminder, so they can be reconciled
    /// as a group without touching any other pending notifications.
    @ObservationIgnored private static let reminderPrefix = "event."

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        newFilesEnabled = defaults.bool(forKey: "notif.newFiles")
        newRatingsEnabled = defaults.bool(forKey: "notif.newRatings")
        securityAlertsEnabled = defaults.bool(forKey: "notif.security")
        center.delegate = presenter
    }

    func setNewFiles(_ on: Bool) async {
        newFilesEnabled = on
        defaults.set(on, forKey: "notif.newFiles")
        if on { await ensurePermission() }
    }

    func setNewRatings(_ on: Bool) async {
        newRatingsEnabled = on
        defaults.set(on, forKey: "notif.newRatings")
        if on { await ensurePermission() }
    }

    func setSecurityAlerts(_ on: Bool) async {
        securityAlertsEnabled = on
        defaults.set(on, forKey: "notif.security")
        if on { await ensurePermission() }
    }

    func refreshStatus() async {
        status = await center.notificationSettings().authorizationStatus
    }

    private func ensurePermission() async {
        await refreshStatus()
        if status == .notDetermined {
            _ = try? await center.requestAuthorization(options: [.alert, .badge, .sound])
            await refreshStatus()
        }
    }

    /// Public entry point for the planner to request reminder authorization in
    /// context (e.g. when the user enables their first reminder).
    func requestRemindersAuthorization() async {
        await ensurePermission()
    }

    func openSystemSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - Personal-planner reminders

    /// Reconcile scheduled local notifications with the user's current planner.
    /// Clears every previously-scheduled planner reminder, then schedules one for
    /// each future `(event, lead-time)` pair. Called on launch and after edits.
    func syncReminders(for events: [PersonalEvent]) async {
        let pending = await center.pendingNotificationRequests()
        let stale = pending.map(\.identifier).filter { $0.hasPrefix(Self.reminderPrefix) }
        if !stale.isEmpty { center.removePendingNotificationRequests(withIdentifiers: stale) }

        // Nothing to schedule → leave notifications alone (don't prompt for perms).
        guard events.contains(where: { !$0.reminderLeads.isEmpty }) else { return }

        await ensurePermission()
        guard status == .authorized || status == .provisional else { return }

        for event in events {
            for lead in Set(event.reminderLeads) {
                guard let fire = event.fireDate(leadMinutes: lead) else { continue }

                let content = UNMutableNotificationContent()
                content.title = event.title.isEmpty ? event.kind.label : event.title
                content.subtitle = reminderSubtitle(for: event)
                content.body = reminderBody(for: event, leadMinutes: lead)
                content.sound = .default
                content.interruptionLevel = .timeSensitive

                let comps = Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute], from: fire)
                let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
                let id = "\(Self.reminderPrefix)\(event.id.uuidString).\(lead)"
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                try? await center.add(request)
            }
        }
    }

    private func reminderSubtitle(for event: PersonalEvent) -> String {
        var parts = [event.kind.label]
        if let code = event.courseCode { parts.append(code) }
        return parts.joined(separator: " · ")
    }

    private func reminderBody(for event: PersonalEvent, leadMinutes: Int) -> String {
        let when = event.date.formatted(date: .abbreviated, time: .shortened)
        return "\(Self.leadPhrase(leadMinutes)) — \(when)"
    }

    /// A short human phrase for a lead-time, e.g. 1440 → "Tomorrow".
    static func leadPhrase(_ minutes: Int) -> String {
        switch minutes {
        case ..<1:         return "Starting now"
        case 1..<60:       return "In \(minutes) min"
        case 60:           return "In 1 hour"
        case 61..<1440:    return "In \(minutes / 60) hours"
        case 1440:         return "Tomorrow"
        case 1441..<10080: return "In \(minutes / 1440) days"
        case 10080:        return "In 1 week"
        default:           return "In \(minutes / 10080) weeks"
        }
    }
}

/// Presents planner reminders as banners even while the app is in the foreground
/// (without this, iOS suppresses them when the app is active).
private final class ForegroundPresenter: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async
        -> UNNotificationPresentationOptions {
        [.banner, .sound, .list]
    }
}
