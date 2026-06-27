import SwiftUI

@main
struct ECEUHApp: App {
    @State private var theme = ThemeService()
    @State private var notifications = NotificationService()
    @State private var session = SessionStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(theme)
                .environment(notifications)
                .environment(session)
                .preferredColorScheme(theme.colorScheme)
                .task {
                    // Per Apple's HIG, notification permission is requested in
                    // context (when the user enables a toggle in Settings), not
                    // on cold launch. Here we only sync the current status.
                    await notifications.refreshStatus()
                }
        }
    }
}
