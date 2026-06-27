import SwiftUI

/// Fixed-size cover card for the home-screen "Your Library" carousel:
/// cover art, a darkening gradient, a code badge, and the archive title.
struct CourseCoverCard: View {
    let course: Course

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            CourseArt(course: course)

            LinearGradient(
                colors: [.clear, .black.opacity(0.75)],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(course.code)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.accentColor, in: Capsule())

                Text(course.displayArchiveTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
            }
            .padding(12)
        }
        .frame(width: 150, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: Radii.lg, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(course.code), \(course.displayArchiveTitle)")
    }
}
