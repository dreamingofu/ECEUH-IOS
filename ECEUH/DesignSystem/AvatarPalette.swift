import SwiftUI

/// Decorative avatar gradients — a luxury visual, independent of a professor's
/// rating. Six rich multi-stop gradients; each professor gets a stable one
/// (deterministically chosen from their name).
enum AvatarPalette {
    static let gradients: [LinearGradient] = [
        gradient(0xFF6B7A, 0xEC1B34, 0xB0122A), // scarlet
        gradient(0xA78BFA, 0x8B5CF6, 0x6D28D9), // royal purple
        gradient(0x60A5FA, 0x3B82F6, 0x1D4ED8), // ocean blue
        gradient(0x5EEAD4, 0x14B8A6, 0x0F766E), // teal
        gradient(0xFCD34D, 0xF59E0B, 0xB45309), // gold
        gradient(0xF0ABFC, 0xD946EF, 0xA21CAF), // magenta
    ]

    /// Stable gradient for a seed string (e.g. a professor's name).
    static func gradient(for seed: String) -> LinearGradient {
        var hash = 0
        for scalar in seed.unicodeScalars {
            hash = (hash &* 31 &+ Int(scalar.value)) & 0x7FFFFFFF
        }
        return gradients[hash % gradients.count]
    }

    private static func gradient(_ a: UInt32, _ b: UInt32, _ c: UInt32) -> LinearGradient {
        LinearGradient(colors: [Color(hex: a), Color(hex: b), Color(hex: c)],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
