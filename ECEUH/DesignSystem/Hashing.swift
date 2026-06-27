import SwiftUI

/// Deterministic hashing for stable generated colors. Swift's `hashValue` is
/// randomized per launch, which would scramble cover/avatar colors; this gives
/// the same hue for the same string every time.
enum Hashing {
    /// Stable rolling hash over Unicode scalars (mirrors the Dart `h*31 + unit`).
    static func stableHash(_ s: String) -> Int {
        var hash = 0
        for scalar in s.unicodeScalars {
            hash = (hash &* 31 &+ Int(scalar.value)) & 0x7FFFFFFF
        }
        return hash
    }

    /// A stable hue in [0, 360) derived from a string.
    static func hue(for s: String) -> Double {
        Double(stableHash(s) % 360)
    }
}

extension Color {
    /// Create a Color from HSL (hue in degrees 0–360, saturation/lightness 0–1).
    /// SwiftUI's `Color(hue:saturation:brightness:)` is HSB, not HSL, so this does
    /// the HSL→RGB conversion to match the Flutter `HSLColor` cover gradients.
    init(h: Double, s: Double, l: Double, opacity: Double = 1) {
        let hue = (h.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360) / 360
        let (r, g, b) = Color.hslToRGB(h: hue, s: s, l: l)
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }

    private static func hslToRGB(h: Double, s: Double, l: Double) -> (Double, Double, Double) {
        guard s != 0 else { return (l, l, l) }
        let q = l < 0.5 ? l * (1 + s) : l + s - l * s
        let p = 2 * l - q
        func hue2rgb(_ t0: Double) -> Double {
            var t = t0
            if t < 0 { t += 1 }
            if t > 1 { t -= 1 }
            if t < 1 / 6 { return p + (q - p) * 6 * t }
            if t < 1 / 2 { return q }
            if t < 2 / 3 { return p + (q - p) * (2 / 3 - t) * 6 }
            return p
        }
        return (hue2rgb(h + 1 / 3), hue2rgb(h), hue2rgb(h - 1 / 3))
    }
}
