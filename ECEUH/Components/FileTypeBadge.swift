import SwiftUI

/// Colored badge for a file's type. Colors carried over from the Flutter
/// `file_card.dart` type palette.
struct FileTypeBadge: View {
    let type: FileType

    var body: some View {
        Text(type.label)
            .font(.caption2.weight(.bold))
            .textCase(.uppercase)
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15), in: Capsule())
    }

    private var color: Color {
        switch type {
        case .quiz:      .accentColor
        case .exam:      Color(hex: 0xB27A00)
        case .homework:  Color(hex: 0x16A34A)
        case .classwork: Color(hex: 0x2563EB)
        case .lab:       Color(hex: 0x7C3AED)
        case .reference: .secondary
        }
    }
}
