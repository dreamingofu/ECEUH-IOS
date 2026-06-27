import SwiftUI

@main
struct ECEUHApp: App {
    @State private var theme = ThemeService()
    @State private var notifications = NotificationService()
    @State private var auth = AuthService()
    @State private var progress = ProgressService()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(theme)
                .environment(notifications)
                .environment(auth)
                .environment(progress)
                .preferredColorScheme(theme.colorScheme)
                .task { await auth.start() }
                .task(id: auth.userId) {
                    // Pull cloud progress when a user signs in.
                    if let userId = auth.userId {
                        await progress.pull(userId: userId)
                    }
                }
        }
    }
}
