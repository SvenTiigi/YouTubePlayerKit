import Foundation
import WebKit

// MARK: - YouTubePlayerWebView+WKNavigationDelegate

extension YouTubePlayerWebView: WKNavigationDelegate {
    
    /// WebView decide policy for NavigationAction
    /// - Parameters:
    ///   - webView: The WKWebView
    ///   - navigationAction: The WKNavigationAction
    ///   - decisionHandler: The decision handler
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        // Verify URL of request is available
        guard let url = navigationAction.request.url else {
            // Otherwise cancel navigation action
            return decisionHandler(.cancel)
        }
        // Check if a JavaScriptEvent can be initialized from request URL
        if let javaScriptEvent = YouTubePlayer.JavaScriptEvent(url: url) {
            // Handle JavaScriptEvent
            self.handle(
                javaScriptEvent: javaScriptEvent
            )
            // Cancel navigation action
            return decisionHandler(.cancel)
        }
        // Check if Request URL host is equal to origin URL host
        if url.host?.lowercased() == self.originURL?.host?.lowercased() {
            // Allow navigation action
            return decisionHandler(.allow)
        }
        // Verify URL scheme is http or https
        guard url.scheme == "http" || url.scheme == "https" else {
            // Otherwise allow navigation action
            return decisionHandler(.allow)
        }
        // For each valid URL RegularExpression
        for validURLRegularExpression in Self.validURLRegularExpressions {
            // Find first match in URL
            let match = validURLRegularExpression.firstMatch(
                in: url.absoluteString,
                options: .init(),
                range: .init(
                    location: 0,
                    length: url.absoluteString.count
                )
            )
            // Check if a match is available
            if match != nil {
                // Allow navigation action
                return decisionHandler(.allow)
            }
        }
        // Open URL
        self.player.configuration.openURLAction(url)
        // Cancel navigation action
        decisionHandler(.cancel)
    }
    
    /// Invoked when the web view's web content process is terminated.
    /// - Parameter webView: The web view whose underlying web content process was terminated.
    func webViewWebContentProcessDidTerminate(
        _ webView: WKWebView
    ) {
        // Send error state
        self.playerStateSubject.send(
            .error(
                .webContentProcessDidTerminate
            )
        )
    }
    
}

// MARK: - YouTubePlayerWebView+validURLRegularExpressions

private extension YouTubePlayerWebView {
    
    /// The valid URL RegularExpressions
    /// Source: https://github.com/youtube/youtube-ios-player-helper/blob/ff5991e6e3188867fe2738aa92913a37127f8f1d/Classes/YTPlayerView.m#L59
    static let validURLRegularExpressions: [NSRegularExpression] = [
        "^http(s)://(www.)youtube.com/embed/(.*)$",
        "^http(s)://pubads.g.doubleclick.net/pagead/conversion/",
        "^http(s)://accounts.google.com/o/oauth2/(.*)$",
        "^https://content.googleapis.com/static/proxy.html(.*)$",
        "^https://tpc.googlesyndication.com/sodar/(.*).html$"
    ]
    .compactMap { pattern in
        try? .init(
            pattern: pattern,
            options: .caseInsensitive
        )
    }
    
}
