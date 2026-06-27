import SwiftUI

/// Course cover art. Ports the Flutter rule (`home_screen.dart`): remote `http`
/// art loads via `AsyncImage`; everything else (and load failures) falls back to
/// a deterministic gradient. No local image assets are bundled.
struct CourseArt: View {
    let course: Course

    var body: some View {
        let hue = Hashing.hue(for: course.slug)
        if course.art.hasPrefix("http"), let url = URL(string: course.art) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .empty:
                    CoverGradient(hue: hue).overlay(ProgressView().tint(.white))
                default:
                    CoverGradient(hue: hue)
                }
            }
        } else {
            CoverGradient(hue: hue)
        }
    }
}

/// Hashed two-stop gradient with a faint bolt — the cover fallback.
struct CoverGradient: View {
    let hue: Double

    var body: some View {
        LinearGradient(
            colors: [
                Color(h: hue, s: 0.45, l: 0.42),
                Color(h: hue + 40, s: 0.55, l: 0.20),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            Image(systemName: "bolt.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 34, height: 34)
                .foregroundStyle(.white.opacity(0.35))
                .accessibilityHidden(true)
        )
    }
}
