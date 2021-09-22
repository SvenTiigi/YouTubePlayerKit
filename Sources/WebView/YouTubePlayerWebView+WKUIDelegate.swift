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
        // Open URL if available
        navigationAction
            .request
            .url
            .flatMap(self.open)
        // Return nil as the URL has already been handled
        return nil
    }
    
}
