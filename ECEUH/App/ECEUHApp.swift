import SwiftUI

@main
struct ECEUHApp: App {
    @State private var theme = ThemeService()
    @State private var notifications: NotificationService
    @State private var auth = AuthService()
    @State private var progress = ProgressService()
    @State private var calendar: CalendarStore
    @State private var calendarSync = CalendarSyncService()
    @State private var gmail = GmailScanService()

    init() {
        // The planner store schedules reminders and mirrors events to the device
        // calendar, so it shares those service instances (created up front).
        let notifications = NotificationService()
        let calendarSync = CalendarSyncService()
        _notifications = State(initialValue: notifications)
        _calendarSync = State(initialValue: calendarSync)
        _calendar = State(initialValue: CalendarStore(notifications: notifications,
                                                      calendarSync: calendarSync))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(theme)
                .environment(notifications)
                .environment(auth)
                .environment(progress)
                .environment(calendar)
                .environment(calendarSync)
                .environment(gmail)
                .preferredColorScheme(theme.colorScheme)
                .task { await auth.start() }
                .task { calendar.reschedule() }  // self-heal planner reminders on launch
                .task(id: auth.userId) {
                    // Pull cloud progress when a user signs in.
                    if let userId = auth.userId {
                        await progress.pull(userId: userId)
                    }
                }
        }
    }
}
