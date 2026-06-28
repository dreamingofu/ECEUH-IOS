import SwiftUI
import PDFKit

/// Hosts the shared `PDFView` owned by a `PDFReader` — GPU-accelerated, with
/// pinch-zoom, continuous vertical scroll, text selection, and tappable links.
struct PDFKitView: UIViewRepresentable {
    let reader: PDFReader

    func makeUIView(context: Context) -> PDFView { reader.view }
    func updateUIView(_ view: PDFView, context: Context) {}
}

/// Native horizontal thumbnail strip linked to a `PDFView`; tapping a thumbnail
/// jumps the view to that page (and the current page stays highlighted).
struct PDFThumbnailStrip: UIViewRepresentable {
    let pdfView: PDFView

    func makeUIView(context: Context) -> PDFThumbnailView {
        let strip = PDFThumbnailView()
        strip.pdfView = pdfView
        strip.layoutMode = .horizontal
        strip.thumbnailSize = CGSize(width: 44, height: 58)
        strip.backgroundColor = .clear
        return strip
    }

    func updateUIView(_ strip: PDFThumbnailView, context: Context) {
        strip.pdfView = pdfView
    }
}
