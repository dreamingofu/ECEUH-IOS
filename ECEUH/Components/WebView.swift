import SwiftUI
import WebKit

/// WKWebView wrapper that reports load failures so the preview can fall back to
/// QuickLook over a downloaded copy.
struct WebView: UIViewRepresentable {
    let url: URL
    var onError: () -> Void = {}

    func makeCoordinator() -> Coordinator { Coordinator(onError: onError) }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate {
        let onError: () -> Void
        init(onError: @escaping () -> Void) { self.onError = onError }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            onError()
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            onError()
        }
    }
}
