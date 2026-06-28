import SwiftUI

/// Cover-art asset name for a course slug (bundled for live courses; CourseCard
/// falls back to a red/ink gradient when absent).
func artAsset(for slug: String) -> String { "art-\(slug)" }

/// Curated archive badge for the live courses (design `data.js`).
func courseBadge(for slug: String) -> String? {
    switch slug {
    case "dld":       "Top Pick"
    case "circuits2": "Advanced"
    case "cprog":     "Fundamental"
    default:          nil
    }
}

/// Home is reserved for unique, app-only features. It deliberately carries no
/// archive or faculty content — just the quote header for now; the rest is TBD.
struct HomeScreen: View {
    var selectTab: (AppTab) -> Void = { _ in }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HomeQuoteSlide()
            }
            .padding(.horizontal, Spacing.gutter)
            .padding(.vertical, 4)
            .padding(.bottom, 24)
        }
        .background(EE.bg.ignoresSafeArea())
        .navigationTitle("ECEUH")
    }
}

/// A "quote slide" header (design `slides/05-quote.html`): a big serif quote
/// mark, an italic serif pull-quote, and a logo attribution, over a red glow.
private struct HomeQuoteSlide: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\u{201C}")
                .font(.system(size: 64, weight: .bold, design: .serif))
                .foregroundStyle(EE.accent)
                .frame(height: 30, alignment: .top)
                .accessibilityHidden(true)
            Text("For students, by a student — built in real time, every semester.")
                .font(.system(.title2, design: .serif).weight(.medium))
                .italic()
                .foregroundStyle(EE.text)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 12) {
                Image("AppLogo")
                    .resizable().scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                VStack(alignment: .leading, spacing: 1) {
                    Text("The ECEUH project").font(.subheadline.weight(.bold)).foregroundStyle(EE.text)
                    Text("UH Electrical & Computer Engineering").font(.footnote).foregroundStyle(EE.textDim)
                }
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background {
            ZStack {
                EE.bgCard
                RadialGradient(colors: [Color(hex: 0xEC1B34, alpha: 0.20), .clear],
                               center: UnitPoint(x: 0.5, y: 1.15), startRadius: 0, endRadius: 380)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: Radii.xl, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Radii.xl, style: .continuous).strokeBorder(EE.border))
        .eeCardShadow()
    }
}

#Preview {
    NavigationStack { HomeScreen() }.preferredColorScheme(.dark)
}
