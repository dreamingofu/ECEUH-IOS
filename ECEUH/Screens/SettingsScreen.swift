import SwiftUI

struct SettingsScreen: View {
    @Environment(ThemeService.self) private var theme
    @Environment(NotificationService.self) private var notifications
    @Environment(SessionStore.self) private var session

    var body: some View {
        @Bindable var theme = theme
        @Bindable var session = session

        Form {
            profileHeader

            Section("Profile Details") {
                LabeledField("Full Name", text: $session.displayName)
                LabeledField("Cougarnet Email", text: $session.email, keyboard: .emailAddress)
                LabeledField("Major / Track", text: $session.major)
                Picker("Expected Graduation", selection: $session.gradYear) {
                    ForEach(["2026", "2027", "2028", "2029"], id: \.self) { Text($0).tag($0) }
                }
            }

            Section("Notifications") {
                NotifToggle(title: "New File Uploads",
                            subtitle: "Get notified when new lecture files, worksheets, or exams are added to your courses.",
                            isOn: notifications.newFilesEnabled) { v in Task { await notifications.setNewFiles(v) } }
                NotifToggle(title: "Faculty Rating Updates",
                            subtitle: "Updates when new ratings and reviews are posted.",
                            isOn: notifications.newRatingsEnabled) { v in Task { await notifications.setNewRatings(v) } }
                NotifToggle(title: "Security Alerts",
                            subtitle: "Notifications for sign-ins from a new device or browser.",
                            isOn: notifications.securityAlertsEnabled) { v in Task { await notifications.setSecurityAlerts(v) } }
                if notifications.status == .denied {
                    Button {
                        notifications.openSystemSettings()
                    } label: {
                        Label("Notifications are off in iOS Settings — tap to enable", systemImage: "bell.slash")
                            .font(.footnote)
                    }
                }
            }

            Section("Appearance") {
                Picker("Theme", selection: $theme.theme) {
                    ForEach(AppTheme.allCases) { Text($0.label).tag($0) }
                }
                .pickerStyle(.segmented)
            }

            Section {
                NavigationLink(value: Route.privacy) { Label("Privacy Policy", systemImage: "lock.shield") }
                NavigationLink(value: Route.deleteAccount) { Label("Delete Account", systemImage: "trash") }
            }

            Section {
                Button(role: .destructive) {
                    session.signOut()
                } label: {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
        }
        .navigationTitle("Account")
        .task { await notifications.refreshStatus() }
    }

    private var profileHeader: some View {
        Section {
            VStack(spacing: 12) {
                Image(systemName: "bolt.fill")
                    .resizable().scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 96, height: 96)
                    .background(Color(.secondarySystemGroupedBackground), in: Circle())
                    .overlay(
                        Circle().strokeBorder(
                            LinearGradient(colors: [Brand.goldLight, Brand.goldDark], startPoint: .top, endPoint: .bottom),
                            lineWidth: 3)
                    )
                Text(session.displayName).font(.title2.weight(.bold))
                Text(session.major).font(.subheadline).foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    BadgeChip(text: "ECE Major", tint: .accentColor)
                    BadgeChip(text: "Class of \(session.gradYear)", tint: .blue)
                }
                ShareLink(item: URL(string: "https://github.com/dreamingofu/eceuh")!) {
                    Label("Share App", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .listRowBackground(Color.clear)
        }
    }
}

private struct LabeledField: View {
    let title: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default

    init(_ title: String, text: Binding<String>, keyboard: UIKeyboardType = .default) {
        self.title = title
        self._text = text
        self.keyboard = keyboard
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            TextField(title, text: $text)
                .keyboardType(keyboard)
                .textInputAutocapitalization(keyboard == .emailAddress ? .never : .sentences)
                .autocorrectionDisabled(keyboard == .emailAddress)
        }
    }
}

private struct NotifToggle: View {
    let title: String
    let subtitle: String
    let isOn: Bool
    let onChange: (Bool) -> Void

    var body: some View {
        Toggle(isOn: Binding(get: { isOn }, set: onChange)) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

private struct BadgeChip: View {
    let text: String
    let tint: Color
    var body: some View {
        Text(text)
            .font(.caption.weight(.bold))
            .foregroundStyle(tint)
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(tint.opacity(0.12), in: Capsule())
    }
}

#Preview {
    NavigationStack { SettingsScreen() }
        .environment(ThemeService())
        .environment(NotificationService())
        .environment(SessionStore())
}
