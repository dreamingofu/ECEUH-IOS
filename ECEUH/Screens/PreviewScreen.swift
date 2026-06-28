import SwiftUI
import PDFKit

/// A file the preview sheet can open.
struct PreviewTarget: Identifiable, Hashable {
    let url: String
    let title: String
    var id: String { url }
}

/// In-app file preview. PDFs render natively with **PDFKit** — page indicator,
/// a tappable thumbnail strip, in-document find, and an on-disk cache so
/// re-opens are instant. If a PDF can't be parsed it falls back to QuickLook
/// over a downloaded copy; non-PDF URLs load in a web view. Toolbar offers
/// open-in-Safari, share, and save-to-Files.
struct PreviewScreen: View {
    let target: PreviewTarget
    @Environment(\.dismiss) private var dismiss

    private enum Stage { case loading, pdf, quicklook, web, failed }
    @State private var stage: Stage = .loading
    @State private var reader = PDFReader()
    @State private var localURL: URL?
    @State private var saving = false
    @State private var shareItem: ShareableURL?
    @State private var toast: String?
    @State private var showThumbnails = false
    @State private var searching = false
    @State private var query = ""
    @FocusState private var searchFocused: Bool

    private var remoteURL: URL {
        URL(string: target.url) ?? URL(string: "https://eceuh.com")!
    }
    private var isPDF: Bool { target.url.lowercased().hasSuffix(".pdf") }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(target.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbar }
                .overlay(alignment: .top) { if searching { searchBar } }
                .overlay(alignment: .bottom) { bottomOverlay }
                .overlay { if saving { savingOverlay } }
                .sheet(item: $shareItem) { ShareSheet(items: [$0.url]) }
                .task { await load() }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch stage {
        case .loading:
            loadingView
        case .pdf:
            PDFKitView(reader: reader).ignoresSafeArea(edges: .bottom)
        case .quicklook:
            if let localURL { QuickLookPreview(url: localURL).ignoresSafeArea(edges: .bottom) } else { failedView }
        case .web:
            WebView(url: remoteURL).ignoresSafeArea(edges: .bottom)
        case .failed:
            failedView
        }
    }

    private var loadingView: some View {
        ZStack {
            EE.bg.ignoresSafeArea()
            ProgressView("Loading…").tint(EE.accent).foregroundStyle(EE.textMuted)
        }
    }

    private var failedView: some View {
        ZStack {
            EE.bg.ignoresSafeArea()
            VStack(spacing: 14) {
                Image(systemName: "doc.questionmark")
                    .font(.largeTitle).foregroundStyle(EE.textDim)
                Text("Couldn't open this file").font(.headline).foregroundStyle(EE.text)
                EEButton(title: "Open in browser", icon: "safari", variant: .tinted) {
                    ShareService.openExternal(target.url)
                }
            }
            .padding()
        }
    }

    // MARK: Toolbar

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button { dismiss() } label: { Image(systemName: "xmark") }
                .accessibilityLabel("Close")
        }
        ToolbarItemGroup(placement: .primaryAction) {
            if stage == .pdf {
                Button { openSearch() } label: { Image(systemName: "magnifyingglass") }
                    .accessibilityLabel("Find in document")
                Button {
                    withAnimation(.easeOut(duration: 0.2)) { showThumbnails.toggle() }
                } label: {
                    Image(systemName: showThumbnails ? "square.grid.2x2.fill" : "square.grid.2x2")
                }
                .accessibilityLabel("Toggle thumbnails")
            }
            Menu {
                Button { ShareService.openExternal(target.url) } label: { Label("Open in browser", systemImage: "safari") }
                Button { shareItem = ShareableURL(url: remoteURL) } label: { Label("Share", systemImage: "square.and.arrow.up") }
                Button { Task { await save() } } label: { Label("Save to Files", systemImage: "arrow.down.to.line") }
            } label: { Image(systemName: "ellipsis.circle") }
        }
    }

    // MARK: Search bar (top)

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").font(.subheadline).foregroundStyle(EE.textDim)
            TextField("Find in document", text: $query)
                .focused($searchFocused)
                .submitLabel(.search)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .foregroundStyle(EE.text)
                .onChange(of: query) { _, q in reader.search(q) }
                .onSubmit { reader.nextMatch() }
            if reader.matchCount > 0 {
                Text("\(reader.currentMatch)/\(reader.matchCount)")
                    .font(.eeMono(.caption2)).foregroundStyle(EE.textMuted).monospacedDigit()
                Button { reader.prevMatch() } label: { Image(systemName: "chevron.up") }
                    .accessibilityLabel("Previous match")
                Button { reader.nextMatch() } label: { Image(systemName: "chevron.down") }
                    .accessibilityLabel("Next match")
            } else if query.count >= 2 {
                Text("No matches").font(.caption2).foregroundStyle(EE.textDim)
            }
            Button { closeSearch() } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(EE.textDim) }
                .accessibilityLabel("Close search")
        }
        .font(.subheadline)
        .padding(.horizontal, 14).padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
        .overlay(alignment: .bottom) { Divider().overlay(EE.separator) }
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    // MARK: Bottom overlay (toast + page pill + thumbnails)

    @ViewBuilder
    private var bottomOverlay: some View {
        VStack(spacing: 10) {
            if let toast {
                Text(toast).font(.subheadline.weight(.medium)).foregroundStyle(EE.text)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(.regularMaterial, in: Capsule())
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            if stage == .pdf, reader.pageCount > 1 {
                Text("\(reader.currentPage) / \(reader.pageCount)")
                    .font(.eeMono(.caption)).foregroundStyle(EE.text).monospacedDigit()
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(.regularMaterial, in: Capsule())
                    .overlay(Capsule().strokeBorder(EE.border))
            }
            if stage == .pdf, showThumbnails {
                PDFThumbnailStrip(pdfView: reader.view)
                    .frame(maxWidth: .infinity).frame(height: 70)
                    .background(.ultraThinMaterial)
                    .overlay(alignment: .top) { Divider().overlay(EE.separator) }
                    .transition(.move(edge: .bottom))
            }
        }
        .padding(.bottom, showThumbnails ? 0 : 14)
        .animation(.easeOut(duration: 0.2), value: showThumbnails)
        .animation(.easeOut(duration: 0.2), value: toast)
    }

    private var savingOverlay: some View {
        ProgressView("Saving…")
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: Actions

    private func openSearch() {
        withAnimation(.easeOut(duration: 0.2)) { searching = true }
        searchFocused = true
    }

    private func closeSearch() {
        searchFocused = false
        withAnimation(.easeOut(duration: 0.2)) { searching = false }
        query = ""
        reader.clearSearch()
    }

    /// Render PDFs natively with PDFKit, hitting the on-disk cache first; fall
    /// back to a downloaded copy in QuickLook, then to a web view / error.
    private func load() async {
        guard stage == .loading else { return }
        guard isPDF else { stage = .web; return }

        if let cached = PDFCache.cachedFile(for: target.url), let doc = PDFDocument(url: cached) {
            reader.setDocument(doc)
            stage = .pdf
            return
        }
        if let (data, _) = try? await URLSession.shared.data(from: remoteURL),
           let doc = PDFDocument(data: data) {
            PDFCache.store(data, for: target.url)
            reader.setDocument(doc)
            stage = .pdf
            return
        }
        if let local = await ShareService.download(target.url) {
            localURL = local
            stage = .quicklook
            return
        }
        stage = .failed
    }

    private func save() async {
        saving = true
        defer { saving = false }
        if await ShareService.download(target.url) != nil {
            showToast("Saved to Files")
        } else {
            showToast("Couldn't save")
        }
    }

    private func showToast(_ message: String) {
        withAnimation { toast = message }
        Task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation { toast = nil }
        }
    }
}
