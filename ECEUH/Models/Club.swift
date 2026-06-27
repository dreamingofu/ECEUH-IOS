import Foundation

/// A student organization. 1:1 port of `lib/models/club.dart`.
/// The Flutter `IconData` becomes `iconKey` (the original Material icon name);
/// `symbolName` resolves it to an SF Symbol via `SFSymbol.forClub`.
struct Club: Identifiable, Hashable {
    let name: String
    let slug: String
    let description: String
    let iconKey: String
    let tags: [String]
    var logoAsset: String? = nil
    var meetingTime: String? = nil
    var location: String? = nil
    var contactEmail: String? = nil
    var instagramUrl: String? = nil
    var discordUrl: String? = nil
    var websiteUrl: String? = nil

    var id: String { slug }

    var symbolName: String { SFSymbol.forClub(iconKey) }

    var hasLinks: Bool {
        instagramUrl != nil || discordUrl != nil || websiteUrl != nil || contactEmail != nil
    }
}
