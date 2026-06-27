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
        .navigationTitle(club?.name ?? "Club")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func content(_ club: Club) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(kicker: "Campus Club", title: club.name, subtitle: club.description)
                    HStack(spacing: 6) {
                        ForEach(club.tags, id: \.self) { TagChip(text: $0) }
                    }
                }

                if club.meetingTime != nil || club.location != nil {
                    detailsCard(club)
                }

                if club.hasLinks {
                    linksCard(club)
                }
            }
            .padding()
        }
    }

    private func detailsCard(_ club: Club) -> some View {
        CardSection(header: "Details") {
            VStack(alignment: .leading, spacing: 12) {
                if let meeting = club.meetingTime {
                    InfoRow(systemImage: "clock", label: "Meets", value: meeting)
                }
                if let location = club.location {
                    InfoRow(systemImage: "mappin.and.ellipse", label: "Location", value: location)
                }
            }
        }
    }

    private func linksCard(_ club: Club) -> some View {
        CardSection(header: "Links") {
            FlowLinks(links: clubLinks(club))
        }
    }

    private func clubLinks(_ club: Club) -> [ClubLink] {
        var links: [ClubLink] = []
        if let w = club.websiteUrl { links.append(.init(icon: "globe", label: "Website", url: w)) }
        if let i = club.instagramUrl { links.append(.init(icon: "camera", label: "Instagram", url: i)) }
        if let d = club.discordUrl { links.append(.init(icon: "bubble.left.and.bubble.right", label: "Discord", url: d)) }
        if let e = club.contactEmail { links.append(.init(icon: "envelope", label: "Email", url: "mailto:\(e)")) }
        return links
    }
}

struct ClubLink: Identifiable {
    let icon: String
    let label: String
    let url: String
    var id: String { url }
}

private struct CardSection<Content: View>: View {
    let header: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(header)
                .font(.caption.weight(.bold))
                .textCase(.uppercase)
                .kerning(1)
                .foregroundStyle(Color.accentColor)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: Radii.lg, style: .continuous))
    }
}

private struct InfoRow: View {
    let systemImage: String
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .font(.subheadline)
                .foregroundStyle(Color.accentColor)
                .frame(width: 36, height: 36)
                .background(Color.accentColor.opacity(0.1), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.caption2.weight(.bold))
                    .textCase(.uppercase)
                    .kerning(1)
                    .foregroundStyle(Color.accentColor)
                Text(value).font(.subheadline)
            }
        }
    }
}

private struct FlowLinks: View {
    let links: [ClubLink]
    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 10)]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
            ForEach(links) { link in
                Button {
                    ShareService.openExternal(link.url)
                } label: {
                    Label(link.label, systemImage: link.icon)
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(.tertiarySystemFill), in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    NavigationStack { ClubDetailScreen(slug: "ieee") }
}
