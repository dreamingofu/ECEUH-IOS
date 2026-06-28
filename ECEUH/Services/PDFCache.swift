import Foundation
import CryptoKit

/// On-disk cache for downloaded PDFs (in the Caches directory), so re-opening a
/// file is instant and works offline. Keyed by a stable SHA-256 of the source
/// URL (Swift's `hashValue` is randomized per launch, so it can't be used here).
enum PDFCache {
    private static var directory: URL {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("pdf-cache", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private static func fileURL(for urlString: String) -> URL {
        let digest = SHA256.hash(data: Data(urlString.utf8))
        let name = digest.map { String(format: "%02x", $0) }.joined()
        return directory.appendingPathComponent(name).appendingPathExtension("pdf")
    }

    /// The cached file URL if a copy exists, else nil.
    static func cachedFile(for urlString: String) -> URL? {
        let file = fileURL(for: urlString)
        return FileManager.default.fileExists(atPath: file.path) ? file : nil
    }

    /// Persist downloaded data and return the local file URL.
    @discardableResult
    static func store(_ data: Data, for urlString: String) -> URL? {
        let file = fileURL(for: urlString)
        do {
            try data.write(to: file, options: .atomic)
            return file
        } catch {
            return nil
        }
    }
}
