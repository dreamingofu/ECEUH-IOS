import SwiftUI

/// Home-screen "Active courses" card. Before setup it invites the user to pick
/// their courses; after, it shows a semester progress bar that fills on a time
/// basis (elapsed fraction of the term) plus the list of active courses.
struct ActiveCoursesCard: View {
    let store: SemesterStore
    var onSetup: () -> Void

    var body: some View {
        if store.isConfigured {
            configured
        } else {
            setupPrompt
        }
    }

    // MARK: Not-yet-configured

    private var setupPrompt: some View {
        Button(action: onSetup) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    IconTile(systemName: "graduationcap.fill", color: EE.accent, size: 46)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Active courses").font(.title3.weight(.bold)).foregroundStyle(EE.text)
                        Text("Track your semester").font(.footnote).foregroundStyle(EE.textDim)
                    }
                    Spacer(minLength: 0)
                }
                Text("Pick the courses you're taking and set your semester dates. The progress bar fills as the term goes by — not by what you open.")
                    .font(.subheadline).foregroundStyle(EE.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
                Divider().overlay(EE.separator).padding(.top, 2)
                HStack(spacing: 6) {
                    Text("Choose your courses").font(.subheadline.weight(.semibold))
                    Image(systemName: "arrow.right").font(.caption.weight(.bold))
                }
                .foregroundStyle(EE.accent)
            }
            .cardChrome()
        }
        .buttonStyle(PressScaleStyle())
    }

    // MARK: Configured

    private var configured: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                IconTile(systemName: "graduationcap.fill", color: EE.accent, size: 46)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Active courses").font(.title3.weight(.bold)).foregroundStyle(EE.text)
                    Text(statusLine).font(.footnote).foregroundStyle(EE.textDim)
                }
                Spacer(minLength: 0)
                Button(action: onSetup) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.subheadline.weight(.semibold)).foregroundStyle(EE.textMuted)
                        .frame(width: 34, height: 34)
                        .background(EE.bgRaised, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Edit courses and dates")
            }

            // Time-based semester progress.
            VStack(alignment: .leading, spacing: 7) {
                EEProgressBar(value: store.progress)
                HStack {
                    Text("\(Int((store.progress * 100).rounded()))% through the semester")
                        .font(.caption.weight(.semibold)).foregroundStyle(EE.textMuted)
                    Spacer(minLength: 8)
                    Text(dateRange).font(.caption).foregroundStyle(EE.textDim).monospacedDigit()
                }
            }

            if store.activeCourses.isEmpty {
                Text("No courses yet — tap the slider to add them.")
                    .font(.subheadline).foregroundStyle(EE.textDim)
            } else {
                VStack(spacing: 8) {
                    ForEach(store.activeCourses) { course in
                        courseRow(course)
                    }
                }
            }
        }
        .cardChrome()
    }

    @ViewBuilder
    private func courseRow(_ course: Course) -> some View {
        if courseHasContent(course) {
            NavigationLink(value: Route.courseDetail(slug: course.slug)) {
                courseRowBody(course, tappable: true)
            }
            .buttonStyle(PressScaleStyle())
        } else {
            courseRowBody(course, tappable: false)
        }
    }

    private func courseRowBody(_ course: Course, tappable: Bool) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2).fill(EE.accent).frame(width: 3, height: 34)
            VStack(alignment: .leading, spacing: 2) {
                Text(course.code)
                    .font(.eeMono(.caption2)).textCase(.uppercase).kerning(0.6)
                    .foregroundStyle(EE.accent)
                Text(course.displayArchiveTitle)
                    .font(.subheadline.weight(.semibold)).foregroundStyle(EE.text).lineLimit(1)
            }
            Spacer(minLength: 8)
            if tappable {
                Image(systemName: "chevron.right").font(.caption.weight(.bold)).foregroundStyle(EE.textFaint)
            }
        }
        .padding(.horizontal, 12).padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(EE.bgRaised, in: RoundedRectangle(cornerRadius: Radii.md, style: .continuous))
        .contentShape(Rectangle())
    }

    // MARK: Labels

    private var statusLine: String {
        switch store.phase {
        case .upcoming:
            let days = store.daysUntilStart
            return days == 0 ? "Starts today" : "Starts in \(days) day\(days == 1 ? "" : "s")"
        case .active:
            return "Week \(store.currentWeek) of \(store.totalWeeks)"
        case .complete:
            return "Semester complete"
        }
    }

    private var dateRange: String {
        let s = store.start.formatted(.dateTime.month(.abbreviated).day())
        let e = store.end.formatted(.dateTime.month(.abbreviated).day())
        return "\(s) – \(e)"
    }
}

/// Shared bento chrome for the card (near-black fill, hairline border, shadow).
private extension View {
    func cardChrome() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(EE.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: Radii.card, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: Radii.card, style: .continuous).strokeBorder(EE.border))
            .eeCardShadow()
            .contentShape(Rectangle())
    }
}

// MARK: - Setup sheet

/// Pick active courses and set the semester start/end dates.
struct SemesterSetupSheet: View {
    @Environment(\.dismiss) private var dismiss
    let store: SemesterStore

    @State private var selected: Set<String>
    @State private var start: Date
    @State private var end: Date

    init(store: SemesterStore) {
        self.store = store
        _selected = State(initialValue: Set(store.courseSlugs))
        _start = State(initialValue: store.start)
        _end = State(initialValue: store.end)
    }

    private var validDates: Bool { end > start }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Start", selection: $start, displayedComponents: .date)
                    DatePicker("End", selection: $end, in: start..., displayedComponents: .date)
                } header: {
                    Text("Semester dates")
                } footer: {
                    Text("Progress fills based on how far into the semester you are — not on files opened.")
                }

                Section {
                    ForEach(kCourses) { course in
                        Button {
                            if selected.contains(course.slug) { selected.remove(course.slug) }
                            else { selected.insert(course.slug) }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: selected.contains(course.slug) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selected.contains(course.slug) ? EE.accent : EE.textFaint)
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(course.code)
                                        .font(.eeMono(.caption2)).foregroundStyle(EE.accent)
                                    Text(course.title).foregroundStyle(EE.text).lineLimit(1)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Your courses")
                } footer: {
                    Text("Choose the courses you're taking this semester.")
                }
            }
            .scrollContentBackground(.hidden)
            .background(EE.bg.ignoresSafeArea())
            .navigationTitle("Your semester")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let ordered = kCourses.filter { selected.contains($0.slug) }.map(\.slug)
                        store.save(courseSlugs: ordered, start: start, end: end)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!validDates)
                }
            }
            .tint(EE.accent)
        }
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            ActiveCoursesCard(store: SemesterStore()) {}
                .padding()
        }
        .background(EE.bg)
    }
    .preferredColorScheme(.dark)
}
