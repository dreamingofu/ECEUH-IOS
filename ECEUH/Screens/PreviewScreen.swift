import SwiftUI

/// A file the preview sheet can open.
struct PreviewTarget: Identifiable, Hashable {
    let url: String
    let title: String
    var id: String { url }
}

/// In-app file preview. PDFs route through the Google Docs Viewer proxy (mobile
/// WebKit can't render PDFs in an iframe directly); other URLs load directly.
/// On a WebView load failure (e.g. gview rate-limiting on campus networks) it
/// falls back to QuickLook over a downloaded copy. Toolbar offers open-in-Safari,
/// share, and save-to-Files.
struct PreviewScreen: View {
    let target: PreviewTarget
    @Environment(\.dismiss) private var dismiss

    @State private var useFallback = false
    @State private var localURL: URL?
    @State private var saving = false
    @State private var shareItem: ShareableURL?
    @State private var toast: String?

    private var remoteURL: URL {
        URL(string: target.url) ?? URL(string: "https://eceuh.com")!
    }

    private var sourceURL: URL {
        if target.url.lowercased().hasSuffix(".pdf"),
           let encoded = target.url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let proxied = URL(string: "https://docs.google.com/gview?embedded=true&url=\(encoded)") {
            return proxied
        }
        return remoteURL
    }

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
        }
    }

    @ViewBuilder
    private var content: some View {
        if useFallback, let localURL {
            QuickLookPreview(url: localURL)
        } else {
            WebView(url: sourceURL) {
                Task { await prepareFallback() }
            }
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

    private func prepareFallback() async {
        if localURL == nil {
            localURL = await ShareService.download(target.url)
        }
        if localURL != nil { useFallback = true }
    }

    private func save() async {
        saving = true
        defer { saving = false }
        if let saved = await ShareService.download(target.url) {
            localURL = saved
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
