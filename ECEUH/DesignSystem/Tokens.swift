import CoreGraphics

/// Spacing scale — 8px base unit (`tokens/spacing.css`).
enum Spacing {
    static let s1: CGFloat = 8
    static let s2: CGFloat = 16
    static let s3: CGFloat = 24
    static let s4: CGFloat = 32
    static let s5: CGFloat = 40
    static let s6: CGFloat = 48

    static let gutter: CGFloat = 16  // screen side margin
    static let inset: CGFloat = 20   // card inner padding
}

/// Continuous-corner radius scale (`tokens/spacing.css`).
enum Radii {
    static let sm: CGFloat = 10    // chips, small tiles
    static let md: CGFloat = 14    // buttons, controls, list cells
    static let lg: CGFloat = 18    // grouped list containers
    static let card: CGFloat = 22  // primary cards
    static let xl: CGFloat = 28    // hero cards, sheets
    static let pill: CGFloat = 999
}
