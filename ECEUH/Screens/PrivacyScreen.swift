import SwiftUI

struct PrivacyScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(
                    kicker: "Legal",
                    title: "Privacy Policy",
                    subtitle: "What ECEUH and the mobile app collect, how it's used, and the third-party services involved."
                )

                PolicySection(title: "Information We Collect",
                    text: "If you create an account we collect your email and a username — used solely to save your unit progress across devices. Anonymous usage stores nothing.")
                PolicySection(title: "How We Use Your Information",
                    text: "We use it to identify your account and sync progress. No ads, no resale.")
                PolicySection(title: "Third-Party Services",
                    text: "Supabase handles auth and progress storage. Vercel Analytics counts page views anonymously. Cloudflare R2 serves PDFs.")
                PolicySection(title: "Data Retention & Deletion",
                    text: "Use the Delete Account page to remove your account in-app at any time. All associated data is removed within 7 days of a deletion request.")
                PolicySection(title: "Contact",
                    text: "Questions? Email mail@felipejmiranda.com.")

                Button {
                    ShareService.openExternal("mailto:mail@felipejmiranda.com")
                } label: {
                    Label("Email us", systemImage: "envelope").frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct PolicySection: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            Text(text).font(.subheadline).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: Radii.lg, style: .continuous))
    }
}

#Preview {
    NavigationStack { PrivacyScreen() }
}
