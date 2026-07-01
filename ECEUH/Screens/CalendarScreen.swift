import SwiftUI

/// The personal planner: students add their own quiz / exam / deadline dates
/// (professors move them constantly) and get local reminder notifications off
/// them. Grouped into Overdue / Today / Tomorrow / This Week / Later.
struct CalendarScreen: View {
    @Environment(CalendarStore.self) private var store
    @Environment(NotificationService.self) private var notifications
    @Environment(CalendarSyncService.self) private var calendarSync
    @Environment(GmailScanService.self) private var gmail

    @State private var showingNew = false
    @State private var editing: PersonalEvent?
    @State private var scanning = false
    @State private var gmailSuggestions: [PersonalEvent] = []
    @State private var showingGmailReview = false
    @State private var showingGmailSetup = false
    @State private var scanMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header

                gmailScanButton

                if notifications.status == .denied {
                    permissionBanner
                }

                if store.events.isEmpty {
                    emptyState
                } else {
                    ForEach(sections, id: \.title) { section in
                        sectionView(section)
                    }
                }
            }
            .padding(.horizontal, Spacing.gutter)
            .padding(.vertical, 4)
            .padding(.bottom, 24)
        }
        .background(EE.bg.ignoresSafeArea())
        .navigationTitle("Planner")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showingNew = true } label: {
                    Image(systemName: "plus").font(.body.weight(.semibold))
                }
                .accessibilityLabel("Add event")
            }
        }
        .sheet(isPresented: $showingNew) {
            EventEditor(event: nil) { store.add($0) }
        }
        .sheet(item: $editing) { event in
            EventEditor(event: event, onSave: { store.update($0) },
                        onDelete: { store.remove(event) })
        }
        .sheet(isPresented: $showingGmailReview) {
            GmailReviewSheet(suggestions: gmailSuggestions) { chosen in
                for event in chosen { store.add(event) }
            }
        }
        .alert("Scan Gmail for dates", isPresented: $showingGmailSetup) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Gmail scanning needs a Google OAuth client ID. Add GOOGLE_OAUTH_CLIENT_ID to Secrets.xcconfig (see docs/GOOGLE_SETUP.md), then rebuild.")
        }
        .alert("Gmail", isPresented: Binding(get: { scanMessage != nil },
                                             set: { if !$0 { scanMessage = nil } })) {
            Button("OK", role: .cancel) { scanMessage = nil }
        } message: {
            Text(scanMessage ?? "")
        }
        .task {
            await notifications.refreshStatus()
            calendarSync.refreshStatus()
        }
        .tint(EE.accent)
    }

    // MARK: Gmail scan

    private var gmailScanButton: some View {
        Button {
            Task { await runGmailScan() }
        } label: {
            HStack(spacing: 12) {
                IconTile(systemName: "envelope.badge.fill", color: EE.classwork, size: 34)
                VStack(alignment: .leading, spacing: 1) {
                    Text("Scan Gmail for dates")
                        .font(.subheadline.weight(.semibold)).foregroundStyle(EE.text)
                    Text("Find quiz & exam emails and add them here")
                        .font(.footnote).foregroundStyle(EE.textDim).lineLimit(1)
                }
                Spacer(minLength: 8)
                if scanning {
                    ProgressView().tint(EE.accent)
                } else {
                    Image(systemName: "chevron.right").font(.caption.weight(.bold)).foregroundStyle(EE.textFaint)
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(EE.bgCard, in: RoundedRectangle(cornerRadius: Radii.md, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: Radii.md, style: .continuous).strokeBorder(EE.border))
            .contentShape(Rectangle())
        }
        .buttonStyle(PressScaleStyle())
        .disabled(scanning)
    }

    private func runGmailScan() async {
        guard gmail.isConfigured else { showingGmailSetup = true; return }
        scanning = true
        let suggestions = await gmail.scan()
        scanning = false
        if !suggestions.isEmpty {
            gmailSuggestions = suggestions
            showingGmailReview = true
        } else if case .failed(let message) = gmail.phase {
            scanMessage = message
        } else if case .idle = gmail.phase {
            return                 // user cancelled sign-in — say nothing
        } else {
            scanMessage = "No quiz or exam dates found in recent email."
        }
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Your dates").eeKicker()
            Text("Quiz & exam planner")
                .font(.title.weight(.bold)).foregroundStyle(EE.text)
            Text("Professors move quizzes all the time. Keep your own copy and get a reminder before each one.")
                .font(.subheadline).foregroundStyle(EE.textMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var permissionBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "bell.slash.fill")
                .font(.subheadline.weight(.bold)).foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(EE.warn, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
            VStack(alignment: .leading, spacing: 1) {
                Text("Reminders are off").font(.subheadline.weight(.semibold)).foregroundStyle(EE.text)
                Text("Turn on notifications to be reminded before your dates.")
                    .font(.footnote).foregroundStyle(EE.textMuted)
            }
            Spacer(minLength: 8)
            Button("Settings") { notifications.openSystemSettings() }
                .font(.subheadline.weight(.semibold)).foregroundStyle(EE.accent)
        }
        .padding(.vertical, 12).padding(.horizontal, 14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Radii.md, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Radii.md, style: .continuous).strokeBorder(EE.borderStrong))
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 42, weight: .regular)).foregroundStyle(EE.textDim)
            Text("No dates yet").font(.title3.weight(.bold)).foregroundStyle(EE.text)
            Text("Add your first quiz or exam and we'll remind you before it's due.")
                .font(.subheadline).foregroundStyle(EE.textMuted)
                .multilineTextAlignment(.center)
            EEButton(title: "Add a date", icon: "plus", variant: .primary) { showingNew = true }
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 44)
    }

    // MARK: Sections

    private struct EventSection { let title: String; let events: [PersonalEvent] }

    private var sections: [EventSection] {
        let cal = Calendar.current
        let now = Date()
        var overdue: [PersonalEvent] = [], today: [PersonalEvent] = []
        var tomorrow: [PersonalEvent] = [], week: [PersonalEvent] = [], later: [PersonalEvent] = []

        for event in store.sorted {
            if cal.isDateInToday(event.date) {
                today.append(event)
            } else if event.date < now {
                overdue.append(event)
            } else if cal.isDateInTomorrow(event.date) {
                tomorrow.append(event)
            } else if let days = cal.dateComponents([.day],
                        from: cal.startOfDay(for: now),
                        to: cal.startOfDay(for: event.date)).day, days <= 7 {
                week.append(event)
            } else {
                later.append(event)
            }
        }

        return [
            EventSection(title: "Overdue", events: overdue),
            EventSection(title: "Today", events: today),
            EventSection(title: "Tomorrow", events: tomorrow),
            EventSection(title: "This Week", events: week),
            EventSection(title: "Later", events: later),
        ].filter { !$0.events.isEmpty }
    }

    private func sectionView(_ section: EventSection) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(section.title)
                .font(.footnote.weight(.bold)).textCase(.uppercase).kerning(0.6)
                .foregroundStyle(section.title == "Overdue" ? EE.accent : EE.textDim)
                .padding(.leading, 2)
            VStack(spacing: 8) {
                ForEach(section.events) { event in
                    Button { editing = event } label: { EventRow(event: event) }
                        .buttonStyle(PressScaleStyle())
                }
            }
        }
    }
}

/// A single planner row: a date block, title, kind/course/time meta, reminder bell.
private struct EventRow: View {
    let event: PersonalEvent

    var body: some View {
        HStack(spacing: 14) {
            VStack(spacing: 1) {
                Text(event.date.formatted(.dateTime.month(.abbreviated)))
                    .font(.caption2.weight(.bold)).textCase(.uppercase)
                Text(event.date.formatted(.dateTime.day()))
                    .font(.title3.weight(.bold)).monospacedDigit()
            }
            .foregroundStyle(event.kind.color)
            .frame(width: 42)

            RoundedRectangle(cornerRadius: 2).fill(event.kind.color).frame(width: 3, height: 38)

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.subheadline.weight(.semibold)).foregroundStyle(EE.text)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Text(event.kind.label)
                        .font(.caption2.weight(.bold)).textCase(.uppercase).kerning(0.4)
                        .foregroundStyle(event.kind.color)
                    if let code = event.courseCode {
                        Text("·").foregroundStyle(EE.textFaint)
                        Text(code).font(.caption).foregroundStyle(EE.textDim)
                    }
                    Text("·").foregroundStyle(EE.textFaint)
                    Text(event.date.formatted(date: .omitted, time: .shortened))
                        .font(.caption).foregroundStyle(EE.textDim)
                }
            }

            Spacer(minLength: 8)

            HStack(spacing: 8) {
                if event.syncToCalendar {
                    Image(systemName: "calendar")
                        .font(.caption).foregroundStyle(EE.good)
                        .accessibilityLabel("On your calendar")
                }
                if !event.reminderLeads.isEmpty {
                    Image(systemName: "bell.fill").font(.caption).foregroundStyle(EE.textFaint)
                }
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(EE.bgCard, in: RoundedRectangle(cornerRadius: Radii.md, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Radii.md, style: .continuous).strokeBorder(EE.border))
        .contentShape(Rectangle())
    }
}

// MARK: - Editor

/// Add / edit sheet for a planner event: title, type, course, date, reminders, notes.
private struct EventEditor: View {
    @Environment(\.dismiss) private var dismiss

    let original: PersonalEvent?
    var onSave: (PersonalEvent) -> Void
    var onDelete: (() -> Void)?

    @State private var title: String
    @State private var kind: EventKind
    @State private var date: Date
    @State private var courseSlug: String?
    @State private var notes: String
    @State private var leads: Set<Int>
    @State private var syncToCalendar: Bool

    init(event: PersonalEvent?,
         onSave: @escaping (PersonalEvent) -> Void,
         onDelete: (() -> Void)? = nil) {
        self.original = event
        self.onSave = onSave
        self.onDelete = onDelete
        _title = State(initialValue: event?.title ?? "")
        _kind = State(initialValue: event?.kind ?? .quiz)
        _date = State(initialValue: event?.date ?? Self.defaultDate())
        _courseSlug = State(initialValue: event?.courseSlug)
        _notes = State(initialValue: event?.notes ?? "")
        _leads = State(initialValue: Set(event?.reminderLeads ?? [1440, 60]))
        _syncToCalendar = State(initialValue: event?.syncToCalendar ?? false)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title — e.g. Quiz 4: K-maps", text: $title)
                    Picker("Type", selection: $kind) {
                        ForEach(EventKind.allCases) { Text($0.label).tag($0) }
                    }
                    Picker("Course", selection: $courseSlug) {
                        Text("None").tag(String?.none)
                        ForEach(coursesWithContent) { course in
                            Text(course.code).tag(Optional(course.slug))
                        }
                    }
                }

                Section("Date & time") {
                    DatePicker("When", selection: $date)
                        .datePickerStyle(.compact)
                }

                Section {
                    ForEach(ReminderLead.allCases) { lead in
                        Toggle(lead.label, isOn: binding(for: lead.rawValue))
                            .tint(EE.accent)
                    }
                } header: {
                    Text("Reminders")
                } footer: {
                    Text("You'll get a notification at each selected time before the event.")
                }

                Section {
                    Toggle("Add to Calendar", isOn: $syncToCalendar)
                        .tint(EE.accent)
                } footer: {
                    Text("Adds this to your device calendar. If your Google account is set up in iOS Settings → Calendar, it syncs to Google Calendar automatically.")
                }

                Section("Notes") {
                    TextField("Optional — room, topics, what to bring…",
                              text: $notes, axis: .vertical)
                        .lineLimit(1...4)
                }

                if onDelete != nil {
                    Section {
                        Button(role: .destructive) {
                            onDelete?()
                            dismiss()
                        } label: {
                            Text("Delete event").frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(EE.bg.ignoresSafeArea())
            .navigationTitle(original == nil ? "New date" : "Edit date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .tint(EE.accent)
        }
    }

    private func binding(for minutes: Int) -> Binding<Bool> {
        Binding(get: { leads.contains(minutes) },
                set: { on in if on { leads.insert(minutes) } else { leads.remove(minutes) } })
    }

    private func save() {
        var event = original ?? PersonalEvent(title: "", date: date)
        event.title = title.trimmingCharacters(in: .whitespaces)
        event.kind = kind
        event.date = date
        event.courseSlug = courseSlug
        event.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        event.reminderLeads = leads.sorted()
        event.syncToCalendar = syncToCalendar
        onSave(event)
        dismiss()
    }

    /// Default new-event time: tomorrow, on the hour, at the current hour.
    private static func defaultDate() -> Date {
        let cal = Calendar.current
        let tomorrow = cal.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        let comps = cal.dateComponents([.year, .month, .day, .hour], from: tomorrow)
        return cal.date(from: comps) ?? tomorrow
    }
}

// MARK: - Home card

/// The Home-screen entry point into the planner: shows the next date (or a
/// call-to-action when empty) and pushes into `CalendarScreen`.
struct PlannerHomeCard: View {
    let next: PersonalEvent?
    let count: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                IconTile(systemName: "calendar", color: EE.accent, size: 46)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Your planner").font(.title3.weight(.bold)).foregroundStyle(EE.text)
                    Text(count == 0 ? "Quiz & exam dates" : "\(count) upcoming")
                        .font(.footnote).foregroundStyle(EE.textDim)
                }
                Spacer(minLength: 0)
            }

            if let next {
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 2).fill(next.kind.color).frame(width: 3, height: 38)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(next.title)
                            .font(.subheadline.weight(.semibold)).foregroundStyle(EE.text).lineLimit(1)
                        Text(subtitle(for: next)).font(.footnote).foregroundStyle(EE.textMuted).lineLimit(1)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 12).padding(.vertical, 10)
                .background(EE.bgRaised, in: RoundedRectangle(cornerRadius: Radii.md, style: .continuous))
            } else {
                Text("Professors change quiz dates constantly. Add your own and get reminded before each one.")
                    .font(.subheadline).foregroundStyle(EE.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Divider().overlay(EE.separator).padding(.top, 2)

            HStack(spacing: 6) {
                Text(next == nil ? "Add a date" : "Open planner").font(.subheadline.weight(.semibold))
                Image(systemName: "arrow.right").font(.caption.weight(.bold))
            }
            .foregroundStyle(EE.accent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(EE.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: Radii.card, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Radii.card, style: .continuous).strokeBorder(EE.border))
        .eeCardShadow()
        .contentShape(Rectangle())
    }

    private func subtitle(for event: PersonalEvent) -> String {
        var parts = [event.kind.label]
        if let code = event.courseCode { parts.append(code) }
        parts.append(event.date.formatted(
            .dateTime.weekday(.abbreviated).month(.abbreviated).day().hour().minute()))
        return parts.joined(separator: " · ")
    }
}

// MARK: - Gmail review

/// Review sheet for Gmail-suggested dates: pick which to keep, then add them.
private struct GmailReviewSheet: View {
    @Environment(\.dismiss) private var dismiss
    let suggestions: [PersonalEvent]
    var onAdd: ([PersonalEvent]) -> Void

    @State private var selected: Set<UUID>

    init(suggestions: [PersonalEvent], onAdd: @escaping ([PersonalEvent]) -> Void) {
        self.suggestions = suggestions
        self.onAdd = onAdd
        _selected = State(initialValue: Set(suggestions.map(\.id)))  // all on by default
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ForEach(suggestions) { event in
                        Button {
                            if selected.contains(event.id) { selected.remove(event.id) }
                            else { selected.insert(event.id) }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: selected.contains(event.id) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selected.contains(event.id) ? EE.accent : EE.textFaint)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(event.title).foregroundStyle(EE.text).lineLimit(2)
                                    Text("\(event.kind.label) · \(event.date.formatted(date: .abbreviated, time: .shortened))")
                                        .font(.footnote).foregroundStyle(EE.textDim)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Found \(suggestions.count) possible date\(suggestions.count == 1 ? "" : "s")")
                } footer: {
                    Text("Detected from recent Gmail subjects. Double-check the date and type before adding — you can edit each one afterward.")
                }
            }
            .scrollContentBackground(.hidden)
            .background(EE.bg.ignoresSafeArea())
            .navigationTitle("Gmail dates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add \(selected.count)") {
                        onAdd(suggestions.filter { selected.contains($0.id) })
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(selected.isEmpty)
                }
            }
            .tint(EE.accent)
        }
    }
}

#Preview {
    NavigationStack { CalendarScreen() }
        .environment(CalendarStore(notifications: NotificationService(), calendarSync: CalendarSyncService()))
        .environment(NotificationService())
        .environment(CalendarSyncService())
        .environment(GmailScanService())
        .preferredColorScheme(.dark)
}
