import Foundation

/// A curated external resource. 1:1 port of `lib/models/link_entry.dart`.
struct LinkEntry: Identifiable, Hashable {
    let title: String
    let url: String
    let desc: String

    var id: String { url }
}
