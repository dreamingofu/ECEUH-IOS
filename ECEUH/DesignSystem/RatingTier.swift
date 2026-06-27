import SwiftUI

/// Quality tier for a professor's overall RateMyProfessors score:
/// green (good ≥ 4.0), amber (medium 3.0–3.9), red (low < 3.0), gray (unrated).
enum RatingTier {
    case good, medium, bad, unrated

    init(overall: Double?) {
        guard let overall else { self = .unrated; return }
        switch overall {
        case 4.0...:    self = .good
        case 3.0..<4.0: self = .medium
        default:        self = .bad
        }
    }

    /// Solid tier color (score, rating-bar fills, tab dots).
    var color: Color {
        switch self {
        case .good:    EE.good      // green
        case .medium:  EE.warn      // amber
        case .bad:     EE.accent    // red
        case .unrated: EE.textDim   // gray
        }
    }

    /// Avatar gradient — a brighter top stop into the tier color.
    var gradient: LinearGradient {
        let stops: [Color]
        switch self {
        case .good:    stops = [Color(hex: 0x6EE7B7), Color(hex: 0x34D399), Color(hex: 0x059669)]
        case .medium:  stops = [Color(hex: 0xFCD34D), Color(hex: 0xFBBF24), Color(hex: 0xD97706)]
        case .bad:     stops = [Color(hex: 0xFF6B7A), Color(hex: 0xEC1B34), Color(hex: 0xB0122A)]
        case .unrated: stops = [Color(hex: 0x8E8E93), Color(hex: 0x636366), Color(hex: 0x48484A)]
        }
        return LinearGradient(colors: stops, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    /// Short label for accessibility / chips.
    var label: String {
        switch self {
        case .good:    "Highly rated"
        case .medium:  "Mixed reviews"
        case .bad:     "Low rated"
        case .unrated: "Unrated"
        }
    }
}
