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
final class NotificationService {
    var newFilesEnabled: Bool
    var newRatingsEnabled: Bool
    var securityAlertsEnabled: Bool

    /// Latest known authorization status (refreshed via `refreshStatus()`).
    var status: UNAuthorizationStatus = .notDetermined

    @ObservationIgnored private let center = UNUserNotificationCenter.current()
    @ObservationIgnored private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        newFilesEnabled = defaults.bool(forKey: "notif.newFiles")
        newRatingsEnabled = defaults.bool(forKey: "notif.newRatings")
        securityAlertsEnabled = defaults.bool(forKey: "notif.security")
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

    @MainActor
    func openSystemSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
