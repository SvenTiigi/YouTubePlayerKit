import Foundation
import WebKit

// MARK: - YouTubePlayerWebView+WKUIDelegate

extension YouTubePlayerWebView: WKUIDelegate {
    
    /// WebView create WebView with configuration for navigation action
    /// - Parameters:
    ///   - webView: The WKWebView
    ///   - configuration: The WKWebViewConfiguration
    ///   - navigationAction: The WKNavigationAction
    ///   - windowFeatures: The WKWindowFeatures
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        // Check if the request url is available
        if let url = navigationAction.request.url {
            self.player?
                .logger()?
                .debug("Open URL \(url, privacy: .public)")
            // Open URL
            Task(priority: .userInitiated) { [weak self] in
                await self?.player?.configuration.openURLAction(url)
            }
        }
        // Return nil as the URL has already been handled
        return nil
    }
    
    /// WebView should preview element.
    /// - Parameters:
    ///   - webView: The web view.
    ///   - elementInfo: The element info.
    func webView(
        _ webView: WKWebView,
        shouldPreviewElement elementInfo: WKPreviewElementInfo
    ) -> Bool {
        // Disable long press preview
        false
    }
    
}
