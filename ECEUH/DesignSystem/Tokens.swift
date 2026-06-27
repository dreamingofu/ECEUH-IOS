import CoreGraphics

/// Spacing scale — 8pt base unit, ported from the Flutter `Spacing` tokens.
enum Spacing {
    static let s1: CGFloat = 8
    static let s2: CGFloat = 16
    static let s3: CGFloat = 24
    static let s4: CGFloat = 32
    static let s5: CGFloat = 40
    static let s6: CGFloat = 48
}

/// Corner-radius scale, ported from the Flutter `Radii` tokens.
enum Radii {
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let pill: CGFloat = 999
}
