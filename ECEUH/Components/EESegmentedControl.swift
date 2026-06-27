import SwiftUI

/// iOS pill segmented control (`ee-seg`): a raised pill thumb slides under the
/// active option.
struct EESegmentedControl: View {
    let options: [String]
    @Binding var selection: String

    var body: some View {
        HStack(spacing: 2) {
            ForEach(options, id: \.self) { option in
                let active = option == selection
                Button {
                    withAnimation(.easeOut(duration: 0.18)) { selection = option }
                } label: {
                    Text(option)
                        .font(.subheadline.weight(active ? .semibold : .medium))
                        .foregroundStyle(EE.text)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .padding(.horizontal, 12)
                        .background {
                            if active {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(EE.bgCard)
                                    .shadow(color: .black.opacity(0.35), radius: 2, y: 1)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(2)
        .background(EE.bgRaised, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
