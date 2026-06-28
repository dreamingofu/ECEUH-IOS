import SwiftUI

/// A selectable app icon. `id` is the alternate-icon asset name (empty = the
/// default "Ember" icon); `preview` is the picker thumbnail imageset.
struct AppIconOption: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let preview: String

    var alternateName: String? { id.isEmpty ? nil : id }
}

/// The default + 3 alternate icons (all variants of the original "E" mark).
let kAppIcons: [AppIconOption] = [
    AppIconOption(id: "",            title: "Ember", subtitle: "Scarlet — original", preview: "icon-ember"),
    AppIconOption(id: "AppIcon-Ocean", title: "Ocean", subtitle: "Deep blue",        preview: "icon-ocean"),
    AppIconOption(id: "AppIcon-Onyx",  title: "Onyx",  subtitle: "Graphite mono",     preview: "icon-onyx"),
    AppIconOption(id: "AppIcon-Gold",  title: "Gold",  subtitle: "Warm amber",        preview: "icon-gold"),
]

func appIconOption(for id: String) -> AppIconOption {
    kAppIcons.first { $0.id == id } ?? kAppIcons[0]
}

/// Lets the user swap the home-screen app icon between the original and three
/// recolored variants, via `setAlternateIconName`.
struct AppIconScreen: View {
    @AppStorage("settings.appIcon") private var appIconID = ""
    @State private var errorMessage: String?

    private let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(kicker: "Personalize", title: "App Icon",
                              subtitle: "Pick the mark that shows up on your home screen.")
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(kAppIcons) { option in
                        Button { select(option) } label: { tile(option) }
                            .buttonStyle(PressScaleStyle())
                    }
                }
            }
            .padding(.horizontal, Spacing.gutter)
            .padding(.vertical, 4)
            .padding(.bottom, 24)
        }
        .background(EE.bg.ignoresSafeArea())
        .navigationTitle("App Icon")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Couldn't change icon",
               isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK", role: .cancel) {}
        } message: { Text(errorMessage ?? "") }
    }

    private func tile(_ option: AppIconOption) -> some View {
        let selected = appIconID == option.id
        return VStack(spacing: 10) {
            Image(option.preview)
                .resizable().scaledToFill()
                .frame(width: 84, height: 84)
                .clipShape(RoundedRectangle(cornerRadius: 19, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 19, style: .continuous)
                    .strokeBorder(selected ? EE.accent : EE.border, lineWidth: selected ? 2.5 : 1))
                .overlay(alignment: .bottomTrailing) {
                    if selected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3).symbolRenderingMode(.palette)
                            .foregroundStyle(.white, EE.accent)
                            .offset(x: 5, y: 5)
                    }
                }
            VStack(spacing: 1) {
                Text(option.title).font(.subheadline.weight(.semibold)).foregroundStyle(EE.text)
                Text(option.subtitle).font(.caption2).foregroundStyle(EE.textDim)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(EE.bgCard, in: RoundedRectangle(cornerRadius: Radii.lg, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Radii.lg, style: .continuous)
            .strokeBorder(selected ? EE.accent.opacity(0.5) : EE.border))
    }

    private func select(_ option: AppIconOption) {
        guard appIconID != option.id else { return }
        guard UIApplication.shared.supportsAlternateIcons else {
            errorMessage = "Alternate icons aren't supported on this device."
            return
        }
        UIApplication.shared.setAlternateIconName(option.alternateName) { error in
            Task { @MainActor in
                if let error { errorMessage = error.localizedDescription }
                else { appIconID = option.id }
            }
        }
    }
}

#Preview {
    NavigationStack { AppIconScreen() }.preferredColorScheme(.dark)
}
