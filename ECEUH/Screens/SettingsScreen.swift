import SwiftUI

struct SettingsScreen: View {
    @Environment(ThemeService.self) private var theme
    @Environment(NotificationService.self) private var notifications
    @Environment(AuthService.self) private var auth
    @Environment(CalendarStore.self) private var calendar

    @State private var presentingSignIn = false
    @AppStorage("settings.icloudSync") private var icloudSync = false
    @AppStorage("settings.appIcon") private var appIconID = ""

    private var darkBinding: Binding<Bool> {
        Binding(get: { theme.theme != .light },
                set: { theme.setTheme($0 ? .dark : .light) })
    }

    private var savedCount: Int {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return (try? FileManager.default.contentsOfDirectory(atPath: docs.path))?.count ?? 0
    }

    var body: some View {
        Form {
            accountSection

            Section("Appearance") {
                SRow(icon: "moon.fill", iconColor: Color(hex: 0x5856D6), title: "Dark mode") {
                    Toggle("", isOn: darkBinding).labelsHidden().tint(EE.accent)
                }
                NavigationLink(value: Route.appIcon) {
                    HStack(spacing: 12) {
                        Image(appIconOption(for: appIconID).preview)
                            .resizable().scaledToFill()
                            .frame(width: 30, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        Text("App icon").foregroundStyle(EE.text)
                        Spacer()
                        Text(appIconOption(for: appIconID).title).foregroundStyle(EE.textMuted)
                    }
                }
            }

            Section {
                SRow(icon: "bell.fill", iconColor: EE.exam, title: "New files") {
                    Toggle("", isOn: Binding(get: { notifications.newFilesEnabled },
                                             set: { v in Task { await notifications.setNewFiles(v) } }))
                        .labelsHidden().tint(EE.accent)
                }
                SRow(icon: "clock.fill", iconColor: EE.classwork, title: "iCloud sync") {
                    Toggle("", isOn: $icloudSync).labelsHidden().tint(EE.accent)
                }
            } header: { Text("Notifications") }
            footer: { Text("Get notified when new quiz solutions and exam reviews are posted.") }

            Section("Library") {
                NavigationLink(value: Route.calendar) {
                    SRow(icon: "calendar", iconColor: EE.accent, title: "Planner",
                         value: calendar.upcoming.isEmpty ? nil : "\(calendar.upcoming.count)")
                }
                NavigationLink(value: Route.clubs) {
                    SRow(icon: "person.3.fill", iconColor: EE.lab, title: "Clubs", value: "\(kClubs.count)")
                }
                SRow(icon: "arrow.down.circle.fill", iconColor: EE.homework, title: "Saved files", value: "\(savedCount)")
            }

            Section {
                NavigationLink(value: Route.privacy) {
                    SRow(icon: "lock.shield.fill", iconColor: EE.good, title: "Privacy")
                }
                if auth.isSignedIn {
                    NavigationLink(value: Route.deleteAccount) {
                        SRow(icon: "trash.fill", iconColor: EE.accent, title: "Delete account")
                    }
                }
                SRow(icon: "info.circle.fill", iconColor: EE.reference, title: "Version", value: "2.0")
            } footer: {
                Text("ECEUH — built for the UH EE Discord community.")
            }

            if auth.isSignedIn {
                Section {
                    Button(role: .destructive) {
                        Task { await auth.signOut() }
                    } label: {
                        Text("Sign Out").frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(EE.bg.ignoresSafeArea())
        .navigationTitle("Settings")
        .tint(EE.accent)
        .sheet(isPresented: $presentingSignIn) { SignInScreen() }
        .task { await notifications.refreshStatus() }
    }

    @ViewBuilder private var accountSection: some View {
        Section {
            if auth.isSignedIn {
                SRow(title: auth.displayName.isEmpty ? "Your account" : auth.displayName,
                     subtitle: auth.email) {
                    Avatar(initials: initials(auth.displayName), size: 34)
                }
            } else {
                Button { presentingSignIn = true } label: {
                    SRow(title: "Sign in with Apple", subtitle: "Sync progress across devices") {
                        HStack(spacing: 6) {
                            Avatar(initials: "EE", size: 34)
                            Image(systemName: "chevron.right").font(.footnote).foregroundStyle(EE.textFaint)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func initials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return letters.isEmpty ? "EE" : String(letters).uppercased()
    }
}

/// A settings row: optional colored icon tile, title, subtitle/value, trailing accessory.
private struct SRow<Trailing: View>: View {
    var icon: String? = nil
    var iconColor: Color = EE.accent
    let title: String
    var subtitle: String? = nil
    var value: String? = nil
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(spacing: 12) {
            if let icon { IconTile(systemName: icon, color: iconColor) }
            VStack(alignment: .leading, spacing: 1) {
                Text(title).foregroundStyle(EE.text)
                if let subtitle { Text(subtitle).font(.footnote).foregroundStyle(EE.textMuted) }
            }
            Spacer(minLength: 8)
            if let value { Text(value).foregroundStyle(EE.textMuted) }
            trailing
        }
    }
}

private extension SRow where Trailing == EmptyView {
    init(icon: String? = nil, iconColor: Color = EE.accent, title: String, subtitle: String? = nil, value: String? = nil) {
        self.init(icon: icon, iconColor: iconColor, title: title, subtitle: subtitle, value: value) { EmptyView() }
    }
}

#Preview {
    NavigationStack { SettingsScreen() }
        .environment(ThemeService())
        .environment(NotificationService())
        .environment(AuthService())
        .environment(CalendarStore(notifications: NotificationService(), calendarSync: CalendarSyncService()))
        .preferredColorScheme(.dark)
}
