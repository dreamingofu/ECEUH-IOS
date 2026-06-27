import SwiftUI

/// Auto-cycling faculty spotlight (native take on the Flutter Faculty Ledger):
/// rotates through rated professors with a crossfade, an avatar with a slowly
/// rotating accent ring, a star rating, and "% would take again".
struct FacultyLedger: View {
    private struct Spot: Identifiable {
        let id: Int
        let prof: Professor
        let code: String
        let course: String
    }

    private let spots: [Spot]
    @State private var index = 0
    @State private var ringAngle = 0.0

    init() {
        var collected: [Spot] = []
        var i = 0
        for course in kProfessorCourses {
            for prof in course.profs where prof.hasRating {
                collected.append(Spot(id: i, prof: prof, code: course.code, course: course.title))
                i += 1
            }
        }
        spots = collected
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Faculty Spotlight").font(.title2.weight(.bold))

            if let spot = spots.indices.contains(index) ? spots[index] : spots.first {
                HStack(spacing: 16) {
                    avatar(spot.prof)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(spot.code)
                            .font(.caption2.weight(.bold))
                            .textCase(.uppercase)
                            .foregroundStyle(Color.accentColor)
                        Text(spot.prof.title).font(.headline)
                        Text(spot.course)
                            .font(.caption2).textCase(.uppercase)
                            .foregroundStyle(.secondary)
                        HStack(spacing: 6) {
                            stars(spot.prof.overall ?? 0)
                            Text(String(format: "%.1f", spot.prof.overall ?? 0))
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(Color.accentColor)
                                .monospacedDigit()
                        }
                        if let would = spot.prof.wouldTake {
                            Text("\(would)% would take again")
                                .font(.caption2).foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                }
                .id(spot.id)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .trailing)),
                    removal: .opacity))
                .accessibilityElement(children: .combine)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: Radii.lg, style: .continuous))
        .onAppear {
            withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
                ringAngle = 360
            }
        }
        .task {
            guard spots.count > 1 else { return }
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(4))
                withAnimation(.easeInOut(duration: 0.5)) {
                    index = (index + 1) % spots.count
                }
            }
        }
    }

    private func avatar(_ prof: Professor) -> some View {
        ZStack {
            Circle()
                .strokeBorder(
                    AngularGradient(
                        colors: [.accentColor, .accentColor.opacity(0), .accentColor.opacity(0), .accentColor],
                        center: .center),
                    lineWidth: 3)
                .frame(width: 76, height: 76)
                .rotationEffect(.degrees(ringAngle))
            Text(prof.initials)
                .font(.headline.weight(.heavy))
                .foregroundStyle(Color.accentColor)
                .frame(width: 60, height: 60)
                .background(Color.accentColor.opacity(0.12), in: Circle())
        }
        .accessibilityHidden(true)
    }

    private func stars(_ value: Double) -> some View {
        let filled = Int(value.rounded())
        return HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { i in
                Image(systemName: i < filled ? "star.fill" : "star")
                    .imageScale(.small)
                    .foregroundStyle(Color.accentColor)
            }
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    FacultyLedger().padding()
}
