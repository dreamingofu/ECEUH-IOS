import SwiftUI

struct ClubDetailScreen: View {
    let slug: String

    var body: some View {
        let club = clubBySlug(slug)
        Group {
            if let club {
                content(club)
            } else {
                ContentUnavailableView("Club not found", systemImage: "person.3")
            }
        }
        .background(EE.bg.ignoresSafeArea())
        .navigationTitle(club?.acronym ?? club?.name ?? "Club")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func content(_ club: Club) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                EECard {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 14) {
                            Text(club.badge)
                                .font(.title3.weight(.bold))
                                .minimumScaleFactor(0.5).lineLimit(1)
                                .foregroundStyle(.white)
                                .frame(width: 60, height: 60)
                                .background(club.category.color.gradient,
                                            in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(club.category.rawValue)
                                    .font(.eeMono(.caption2)).textCase(.uppercase).kerning(1)
                                    .foregroundStyle(club.category.color)
                                Text(club.name)
                                    .font(.title3.weight(.bold)).foregroundStyle(EE.text)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: 0)
                        }
                        if club.featured {
                            Label("Featured organization", systemImage: "star.fill")
                                .font(.caption.weight(.semibold)).foregroundStyle(EE.accent)
                        }
                        if !club.tags.isEmpty {
                            FlowLayout(spacing: 6) {
                                ForEach(club.tags, id: \.self) { TagChip(text: $0) }
                            }
                        }
                    }
                }

                if club.hasLinks {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Connect").eeKicker()
                        if let web = club.website {
                            linkRow("globe", "Website", web.replacingOccurrences(of: "https://", with: ""), url: web)
                        }
                        if let email = club.email {
                            linkRow("envelope.fill", "Email", email, url: "mailto:\(email)")
                        }
                    }
                } else {
                    Text("No public contact info listed yet.")
                        .font(.footnote).italic().foregroundStyle(EE.textDim)
                }
            }
            .padding(.horizontal, Spacing.gutter)
            .padding(.vertical, 4)
            .padding(.bottom, 24)
        }
    }

    private func linkRow(_ icon: String, _ label: String, _ detail: String, url: String) -> some View {
        Button { ShareService.openExternal(url) } label: {
            HStack(spacing: 12) {
                IconTile(systemName: icon, color: EE.accent)
                VStack(alignment: .leading, spacing: 1) {
                    Text(label).font(.subheadline.weight(.semibold)).foregroundStyle(EE.text)
                    Text(detail).font(.footnote).foregroundStyle(EE.textMuted).lineLimit(1)
                }
                Spacer(minLength: 8)
                Image(systemName: "arrow.up.right").font(.footnote).foregroundStyle(EE.accent)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(EE.bgCard, in: RoundedRectangle(cornerRadius: Radii.lg, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: Radii.lg, style: .continuous).strokeBorder(EE.border))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack { ClubDetailScreen(slug: "ieee") }.preferredColorScheme(.dark)
}
