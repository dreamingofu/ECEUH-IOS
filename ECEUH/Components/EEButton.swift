import SwiftUI

enum EEButtonVariant { case primary, tinted, gray, plain }
enum EEButtonSize { case small, regular, large }

/// iOS-style button: sentence case, rounded rect, gradient primary with a red
/// glow, plus tinted / gray / plain variants (`ee-btn`).
struct EEButton: View {
    let title: String
    var icon: String? = nil
    var iconRight: String? = nil
    var variant: EEButtonVariant = .primary
    var size: EEButtonSize = .regular
    var block: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 7) {
                if let icon { Image(systemName: icon).imageScale(iconScale) }
                Text(title)
                if let iconRight { Image(systemName: iconRight).imageScale(iconScale) }
            }
            .font(font)
            .frame(maxWidth: block ? .infinity : nil)
            .padding(.vertical, vPad)
            .padding(.horizontal, hPad)
            .frame(minHeight: variant == .plain ? nil : 44)
            .foregroundStyle(foreground)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .modifier(GlowIf(on: variant == .primary))
        }
        .buttonStyle(PressScaleStyle())
    }

    private var font: Font {
        switch size {
        case .small:   .subheadline.weight(.semibold)
        case .regular: .body.weight(.semibold)
        case .large:   .body.weight(.semibold)
        }
    }
    private var iconScale: Image.Scale { size == .small ? .small : .medium }
    private var vPad: CGFloat { variant == .plain ? 6 : (size == .small ? 9 : (size == .large ? 16 : 13)) }
    private var hPad: CGFloat { variant == .plain ? 8 : (size == .small ? 14 : (size == .large ? 22 : 20)) }
    private var radius: CGFloat { variant == .plain ? 0 : (size == .small ? Radii.sm : Radii.md) }

    private var foreground: Color {
        switch variant {
        case .primary: EE.onAccent
        case .tinted, .plain: EE.accent
        case .gray: EE.text
        }
    }

    @ViewBuilder private var background: some View {
        switch variant {
        case .primary: EE.accentGrad
        case .tinted:  EE.accentTint
        case .gray:    EE.bgRaised
        case .plain:   Color.clear
        }
    }
}

/// Scales to 0.96 on press (`--ee-press`).
struct PressScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeOut(duration: 0.18), value: configuration.isPressed)
    }
}

private struct GlowIf: ViewModifier {
    let on: Bool
    func body(content: Content) -> some View {
        if on { content.eeGlowSoft() } else { content }
    }
}
