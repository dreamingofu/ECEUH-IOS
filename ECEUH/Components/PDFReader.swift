import SwiftUI
import PDFKit

/// Owns a single `PDFView` and the reading state around it — current page, page
/// count, and in-document find — so the preview screen, page indicator,
/// thumbnail strip, and search bar all drive one shared view.
///
/// Find uses PDFKit's asynchronous `beginFindString` (matches stream in on the
/// main queue via notifications) so searching a large PDF never blocks the UI.
@MainActor
@Observable
final class PDFReader {
    let view = PDFView()

    var currentPage = 1
    var pageCount = 0
    var matchCount = 0
    var currentMatch = 0

    @ObservationIgnored private var matches: [PDFSelection] = []
    @ObservationIgnored private var pageObserver: NSObjectProtocol?
    @ObservationIgnored private var matchObserver: NSObjectProtocol?

    init() {
        view.autoScales = true
        view.displayMode = .singlePageContinuous
        view.displayDirection = .vertical
        view.pageShadowsEnabled = true
        view.backgroundColor = UIColor(EE.bg)
        view.maxScaleFactor = 6
        pageObserver = NotificationCenter.default.addObserver(
            forName: .PDFViewPageChanged, object: view, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.syncPage() }
        }
    }

    func setDocument(_ document: PDFDocument) {
        view.document = document
        syncPage()
    }

    private func syncPage() {
        guard let document = view.document, let page = view.currentPage else { return }
        pageCount = document.pageCount
        currentPage = document.index(for: page) + 1
    }

    // MARK: Find in document (async, non-blocking)

    func search(_ raw: String) {
        let query = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let document = view.document else { return }
        document.cancelFindString()
        resetMatches()
        guard query.count >= 2 else { return }

        matchObserver = NotificationCenter.default.addObserver(
            forName: .PDFDocumentDidFindMatch, object: document, queue: .main
        ) { [weak self] note in
            MainActor.assumeIsolated {
                guard let self,
                      let selection = note.userInfo?["PDFDocumentFoundSelection"] as? PDFSelection
                else { return }
                selection.color = UIColor(EE.warn).withAlphaComponent(0.5)
                self.matches.append(selection)
                self.matchCount = self.matches.count
                self.view.highlightedSelections = self.matches
                if self.matches.count == 1 {
                    self.currentMatch = 1
                    self.focus(selection)
                }
            }
        }
        document.beginFindString(query, withOptions: [.caseInsensitive, .diacriticInsensitive])
    }

    func nextMatch() {
        guard !matches.isEmpty else { return }
        currentMatch = currentMatch % matches.count + 1
        focus(matches[currentMatch - 1])
    }

    func prevMatch() {
        guard !matches.isEmpty else { return }
        currentMatch = (currentMatch - 2 + matches.count) % matches.count + 1
        focus(matches[currentMatch - 1])
    }

    func clearSearch() {
        view.document?.cancelFindString()
        resetMatches()
    }

    private func resetMatches() {
        if let matchObserver { NotificationCenter.default.removeObserver(matchObserver) }
        matchObserver = nil
        matches = []
        matchCount = 0
        currentMatch = 0
        view.highlightedSelections = nil
        view.clearSelection()
    }

    private func focus(_ selection: PDFSelection) {
        view.setCurrentSelection(selection, animate: true)
        view.go(to: selection)
    }

    deinit {
        if let pageObserver { NotificationCenter.default.removeObserver(pageObserver) }
        if let matchObserver { NotificationCenter.default.removeObserver(matchObserver) }
    }
}
