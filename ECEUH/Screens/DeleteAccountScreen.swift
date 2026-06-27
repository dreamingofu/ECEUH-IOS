import SwiftUI

/// In-app account deletion (App Store requirement since 2023 — replaces the
/// Flutter `mailto:` flow). Phase 4 wires the confirmation UI + a mock deletion;
/// Phase 6 connects `AuthService.deleteAccount()` (delete progress rows → invoke
/// the `delete-account` Edge Function → sign out).
struct DeleteAccountScreen: View {
    @Environment(SessionStore.self) private var session
    @State private var showConfirmation = false
    @State private var isDeleting = false
    @State private var errorMessage: String?

    private let deletedItems = [
        "Your email address and username",
        "Your course progress across every unit",
        "Your sign-in session and credentials",
        "Any cached progress synced from previous devices",
    ]

    var body: some View {
        List {
            Section {
                SectionHeader(
                    kicker: "Account",
                    title: "Delete Your Account",
                    subtitle: "Permanently remove your ECEUH account and any data tied to it. This applies across web, Android, and iOS."
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            Section("What Gets Deleted") {
                ForEach(deletedItems, id: \.self) { item in
                    Label(item, systemImage: "circle.fill")
                        .labelStyle(BulletLabelStyle())
                }
            }

            Section("What Gets Kept") {
                Text("Nothing personal. All data associated with your account is permanently deleted within 7 days of your request.")
                    .foregroundStyle(.secondary)
            }

            Section {
                Text("Deleting your account permanently removes your email address, username, and all saved progress. This cannot be undone.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Button(role: .destructive) {
                    showConfirmation = true
                } label: {
                    Label("Delete My Account", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Delete Account")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Delete account permanently?",
                            isPresented: $showConfirmation, titleVisibility: .visible) {
            Button("Delete Account", role: .destructive) {
                Task { await performDeletion() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("All your data will be deleted. This cannot be undone.")
        }
        .overlay {
            if isDeleting {
                ProgressView("Deleting account…")
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .alert("Couldn't delete account", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private func performDeletion() async {
        isDeleting = true
        defer { isDeleting = false }
        // Phase 6: try await auth.deleteAccount()
        // (delete progress rows → invoke `delete-account` Edge Function → sign out)
        try? await Task.sleep(for: .seconds(1))
        session.signOut()
    }
}

/// Renders a label as a bulleted line (small accent dot + text).
struct BulletLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Circle()
                .fill(Color.accentColor)
                .frame(width: 6, height: 6)
                .padding(.top, 6)
            configuration.title
        }
    }
}

#Preview {
    NavigationStack { DeleteAccountScreen() }
        .environment(SessionStore())
}
