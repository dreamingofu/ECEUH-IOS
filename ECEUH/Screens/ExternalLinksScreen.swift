import SwiftUI

struct ExternalLinksScreen: View {
    let slug: String

    var body: some View {
        let course = courseBySlug(slug)
        let links = kCourseLinks[slug] ?? []

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(
                    kicker: course?.title ?? "Course",
                    title: "External Resources",
                    subtitle: course?.sections?.links?.desc ?? "Curated tools, simulators, and references."
                )

                ForEach(links) { link in
                    Button {
                        ShareService.openExternal(link.url)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(alignment: .firstTextBaseline) {
                                Text(link.title).font(.headline)
                                Spacer()
                                Label("Open", systemImage: "arrow.up.right")
                                    .font(.caption.weight(.bold))
                                    .labelStyle(.titleAndIcon)
                                    .foregroundStyle(Color.accentColor)
                            }
                            Text(link.desc).font(.subheadline).foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground),
                                    in: RoundedRectangle(cornerRadius: Radii.lg, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .navigationTitle("External Resources")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { ExternalLinksScreen(slug: "dld") }
}
