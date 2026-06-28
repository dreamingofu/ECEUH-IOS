import SwiftUI
import PDFKit

/// A file the preview sheet can open.
struct PreviewTarget: Identifiable, Hashable {
    let url: String
    let title: String
    var id: String { url }
}

/// In-app file preview. PDFs render natively with **PDFKit** (`PDFView`) — fast,
/// GPU-accelerated, with pinch-zoom and continuous scroll. If a PDF can't be
/// parsed it falls back to QuickLook over a downloaded copy; non-PDF URLs load in
/// a web view. Toolbar offers open-in-Safari, share, and save-to-Files.
struct PreviewScreen: View {
    let target: PreviewTarget
    @Environment(\.dismiss) private var dismiss

    private enum Stage { case loading, pdf, quicklook, web, failed }
    @State private var stage: Stage = .loading
    @State private var document: PDFDocument?
    @State private var localURL: URL?
    @State private var saving = false
    @State private var shareItem: ShareableURL?
    @State private var toast: String?

    private var remoteURL: URL {
        URL(string: target.url) ?? URL(string: "https://eceuh.com")!
    }
    private var isPDF: Bool { target.url.lowercased().hasSuffix(".pdf") }

    var body: some View {
        NavigationStack {
            content
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle(target.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbar }
                .overlay { if saving { savingOverlay } }
                .overlay(alignment: .bottom) { toastView }
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
            if let document { PDFKitView(document: document) } else { failedView }
        case .quicklook:
            if let localURL { QuickLookPreview(url: localURL) } else { failedView }
        case .web:
            WebView(url: remoteURL)
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

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button { dismiss() } label: { Image(systemName: "xmark") }
                .accessibilityLabel("Close")
        }
        ToolbarItemGroup(placement: .primaryAction) {
            Button { ShareService.openExternal(target.url) } label: { Image(systemName: "safari") }
                .accessibilityLabel("Open in browser")
            Button { shareItem = ShareableURL(url: remoteURL) } label: { Image(systemName: "square.and.arrow.up") }
                .accessibilityLabel("Share")
            Button { Task { await save() } } label: { Image(systemName: "arrow.down.to.line") }
                .accessibilityLabel("Save to Files")
        }
    }

    private var savingOverlay: some View {
        ProgressView("Saving…")
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    @ViewBuilder
    private var toastView: some View {
        if let toast {
            Text(toast)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 16).padding(.vertical, 10)
                .background(.regularMaterial, in: Capsule())
                .padding(.bottom, 24)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    // MARK: Loading

    /// Render PDFs natively with PDFKit; fall back to a downloaded copy in
    /// QuickLook, then to a web view / error. Non-PDF URLs load in the web view.
    private func load() async {
        guard stage == .loading else { return }
        guard isPDF else { stage = .web; return }

        if let (data, _) = try? await URLSession.shared.data(from: remoteURL),
           let doc = PDFDocument(data: data) {
            document = doc
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
