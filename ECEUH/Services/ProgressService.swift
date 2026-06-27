import SwiftUI
import Supabase
import Observation

/// Per-unit progress. Local UserDefaults cache (key `eceuh:progress`, a
/// `[String]` of `"course=status"` pairs — byte-compatible with the web/Android
/// apps) plus Supabase sync to the existing `progress(user_id, course, status)`
/// table: pulled on sign-in, written through on change.
///
/// Note: the current screens don't yet expose a progress-marking interaction, so
/// nothing drives `setStatus` from the UI yet — this provides the plumbing and
/// data-model parity with the web app for when that UI lands.
@Observable
@MainActor
final class ProgressService {
    private(set) var progress: [String: String] = [:]

    private static let key = "eceuh:progress"
    private let client = SupabaseManager.client

    init() { loadLocal() }

    func status(of course: String) -> String? { progress[course] }

    func setStatus(_ status: String, for course: String, userId: UUID?) async {
        progress[course] = status
        saveLocal()
        guard let userId, SupabaseManager.isConfigured else { return }
        let row = ProgressRow(user_id: userId.uuidString, course: course, status: status)
        try? await client.from("progress").upsert(row, onConflict: "user_id,course").execute()
    }

    /// Pull the signed-in user's rows and merge into the local cache.
    func pull(userId: UUID) async {
        guard SupabaseManager.isConfigured else { return }
        do {
            let rows: [ProgressPull] = try await client.from("progress")
                .select("course,status")
                .eq("user_id", value: userId.uuidString)
                .execute()
                .value
            for row in rows { progress[row.course] = row.status }
            saveLocal()
        } catch {
            // Offline / RLS — keep the local cache.
        }
    }

    private func loadLocal() {
        let pairs = UserDefaults.standard.stringArray(forKey: Self.key) ?? []
        progress = Dictionary(pairs.compactMap { pair -> (String, String)? in
            let parts = pair.split(separator: "=", maxSplits: 1).map(String.init)
            return parts.count == 2 ? (parts[0], parts[1]) : nil
        }, uniquingKeysWith: { _, new in new })
    }

    private func saveLocal() {
        UserDefaults.standard.set(progress.map { "\($0.key)=\($0.value)" }, forKey: Self.key)
    }
}

private struct ProgressRow: Encodable {
    let user_id: String
    let course: String
    let status: String
}

private struct ProgressPull: Decodable {
    let course: String
    let status: String
}
