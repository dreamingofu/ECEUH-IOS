import SwiftUI
import UIKit

/// Native bridges for sharing / opening / downloading files.
enum ShareService {
    /// Open a URL in the system browser or the appropriate external app
    /// (mailto:, https:, etc.). Mirrors the Flutter `url_launcher` external mode.
    @MainActor
    static func openExternal(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }

    /// Download a file to the app's Documents directory and return the local URL.
    /// Mirrors the Flutter `ShareService.download` (dio + path_provider): strips
    /// the query string, infers the filename, falls back to `file.pdf`.
    static func download(_ urlString: String, filename: String? = nil) async -> URL? {
        guard let url = URL(string: urlString) else { return nil }
        do {
            let (tempURL, _) = try await URLSession.shared.download(from: url)
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let name = filename ?? inferredFilename(from: urlString)
            let destination = documents.appendingPathComponent(name)
            try? FileManager.default.removeItem(at: destination)
            try FileManager.default.moveItem(at: tempURL, to: destination)
            return destination
        } catch {
            return nil
        }
    }

    /// Fetch a file's bytes for export, reusing the on-disk PDF cache when present
    /// (so a file you just previewed exports instantly).
    static func data(_ urlString: String) async -> Data? {
        if urlString.lowercased().hasSuffix(".pdf"), let cached = PDFCache.cachedFile(for: urlString) {
            return try? Data(contentsOf: cached)
        }
        guard let url = URL(string: urlString) else { return nil }
        return try? await URLSession.shared.data(from: url).0
    }

    /// A suggested filename for a URL (decoded last path component).
    static func filename(_ urlString: String) -> String { inferredFilename(from: urlString) }

    private static func inferredFilename(from urlString: String) -> String {
        let clean = urlString.components(separatedBy: "?").first ?? urlString
        let last = (clean.components(separatedBy: "/").last ?? "")
        let decoded = last.removingPercentEncoding ?? last
        return decoded.isEmpty ? "file.pdf" : decoded
    }
}

/// Identifiable wrapper so a URL can drive a `.sheet(item:)` share sheet.
struct ShareableURL: Identifiable {
    let url: URL
    var id: String { url.absoluteString }
}
