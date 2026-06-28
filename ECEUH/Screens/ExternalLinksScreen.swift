import SwiftUI

/// A course's External Resources: curated outside links (simulators, docs,
/// references) that open in the browser.
struct ExternalLinksScreen: View {
    let slug: String

    private var course: Course? { courseBySlug(slug) }
    private var links: [LinkEntry] { kCourseLinks[slug] ?? [] }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(kicker: course?.code ?? "Course",
                              title: course?.sections?.links?.title ?? "External Resources",
                              subtitle: course?.sections?.links?.desc)

                if links.isEmpty {
                    Text("No links yet for this course.")
                        .font(.footnote).italic().foregroundStyle(EE.textDim)
                        .padding(.vertical, 8)
                } else {
                    ForEach(links) { link in
                        Button { ShareService.openExternal(link.url) } label: {
                            linkCard(link)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, Spacing.gutter)
            .padding(.vertical, 4)
            .padding(.bottom, 24)
        }
        .background(EE.bg.ignoresSafeArea())
        .navigationTitle("External Resources")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func linkCard(_ link: LinkEntry) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(link.title).font(.headline).foregroundStyle(EE.text)
                Spacer()
                Image(systemName: "arrow.up.right").font(.subheadline).foregroundStyle(EE.accent)
            }
            Text(link.desc).font(.footnote).foregroundStyle(EE.textMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(EE.bgCard, in: RoundedRectangle(cornerRadius: Radii.lg, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Radii.lg, style: .continuous).strokeBorder(EE.border))
    }
}

#Preview {
    NavigationStack { ExternalLinksScreen(slug: "dld") }.preferredColorScheme(.dark)
}
