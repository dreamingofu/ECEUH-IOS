import SwiftUI
import UIKit

/// Imperative share sheet (UIActivityViewController) for presenting via
/// `.sheet(item:)` from a button action.
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
