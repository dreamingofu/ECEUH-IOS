import Foundation

/// Central mapping from the Flutter Material icon names used in the source app
/// to SF Symbol names. Club models store the original Material `IconData` key as
/// a string; `SFSymbol.forClub` resolves it to a symbol.
enum SFSymbol {
    /// Maps a club's Material icon key to an SF Symbol.
    static func forClub(_ key: String) -> String {
        switch key {
        case "electrical_services":      return "bolt.fill"
        case "workspace_premium":        return "rosette"
        case "precision_manufacturing":  return "gearshape.2.fill"
        case "groups":                   return "person.3.fill"
        case "people_alt":               return "person.2.fill"
        case "star_outline":             return "star"
        case "code":                     return "chevron.left.forwardslash.chevron.right"
        default:                         return "building.columns.fill"
        }
    }

    /// Maps a Material file-type-ish or UI icon to an SF Symbol (extended as screens land).
    static func forUI(_ key: String) -> String {
        switch key {
        case "menu_book":        return "book.fill"
        case "school":           return "graduationcap.fill"
        case "link":             return "link"
        case "folder":           return "folder.fill"
        case "open_in_new":      return "arrow.up.forward.app"
        case "share":            return "square.and.arrow.up"
        case "download":         return "arrow.down.to.line"
        case "search":           return "magnifyingglass"
        default:                 return "questionmark.circle"
        }
    }
}
