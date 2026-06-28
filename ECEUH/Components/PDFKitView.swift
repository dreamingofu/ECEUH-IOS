import SwiftUI
import PDFKit

/// Native PDF renderer (`PDFKit.PDFView`) — GPU-accelerated, with pinch-zoom,
/// continuous vertical scroll, text selection, and tappable links. The fast,
/// responsive, fully-native viewer for an iOS-only app.
struct PDFKitView: UIViewRepresentable {
    let document: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.document = document
        view.autoScales = true                 // fit-to-width, then free pinch-zoom
        view.displayMode = .singlePageContinuous
        view.displayDirection = .vertical
        view.pageShadowsEnabled = true          // frame each page on the dark bg
        view.backgroundColor = UIColor(EE.bg)
        view.maxScaleFactor = 6
        return view
    }

    func updateUIView(_ view: PDFView, context: Context) {
        if view.document !== document { view.document = document }
    }
}
