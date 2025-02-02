import Foundation
import WebKit

// MARK: - YouTubePlayerWebView+WKNavigationDelegate

extension YouTubePlayerWebView: WKNavigationDelegate {
    
    /// WebView did fail provisional navigation
    /// - Parameters:
    ///   - webView: The web view.
    ///   - navigation: The navigation.
    ///   - error: The error.
    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        self.eventSubject.send(
            .didFailProvisionalNavigation(error)
        )
        self.player?
            .logger()?
            .error("WKWebView did fail provisional navigation: \(error, privacy: .public)")
    }
    
    /// WebView did fail navigation.
    /// - Parameters:
    ///   - webView: The web view.
    ///   - navigation: The navigation.
    ///   - error: The error.
    func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        self.eventSubject.send(
            .didFailNavigation(error)
        )
        self.player?
            .logger()?
            .error("WKWebView did fail navigation: \(error, privacy: .public)")
    }
    
    /// WebView decide policy for NavigationAction
    /// - Parameters:
    ///   - webView: The WKWebView
    ///   - navigationAction: The WKNavigationAction
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction
    ) async -> WKNavigationActionPolicy {
        // Verify URL of request is available
        guard let url = navigationAction.request.url else {
            // Otherwise cancel navigation action
            return .cancel
        }
        // Verify url is not about:blank
        guard url.absoluteString != "about:blank" else {
            // Otherwise allow navigation
            return .allow
        }
        // Check if Request URL host is equal to origin URL host
        if url.host?.lowercased() == self.player?.parameters.originURL?.host?.lowercased() {
            // Allow navigation action
            return .allow
        }
        // Check if the scheme matches the JavaScript event callback URL scheme and if the host is a known player event name
        if url.scheme == self.player?.configuration.htmlBuilder.youTubePlayerEventCallbackURLScheme,
           let playerEventName = url.host.flatMap(YouTubePlayer.Event.Name.init) {
            // Initialize player event
            let playerEvent = YouTubePlayer.Event(
                name: playerEventName,
                data: URLComponents(
                    url: url,
                    resolvingAgainstBaseURL: true
                )?
                .queryItems?
                .first { $0.name == self.player?.configuration.htmlBuilder.youTubePlayerEventCallbackDataParameterName }
                    .flatMap(YouTubePlayer.Event.Data.init)
            )
            // Check if a logger is available and ensure event name is not equal to `videoProgress` and `loadProgress`
            // Those two events are explicitly excluded because they occur in a high frequency.
            if let logger = self.player?.logger(),
               playerEventName != .videoProgress && playerEventName != .loadProgress {
                // Log received JavaScript event
                logger.debug("Received YouTube Player Event\n\(playerEvent, privacy: .public)")
            }
            // Send received player event
            self.eventSubject.send(
                .receivedPlayerEvent(playerEvent)
            )
            // Cancel navigation action
            return .cancel
        }
        // Log url
        self.player?
            .logger()?
            .debug("WKWebView navigate to \(url, privacy: .public)")
        // Verify URL scheme is http or https
        guard url.scheme == "http" || url.scheme == "https" else {
            // Otherwise allow navigation action
            return .allow
        }
        // For each valid URL RegularExpression
        for validURLRegularExpression in Self.validURLRegularExpressions {
            // Find first match in URL
            let match = validURLRegularExpression.firstMatch(
                in: url.absoluteString,
                range: .init(
                    url.absoluteString.startIndex...,
                    in: url.absoluteString
                )
            )
            // Check if a match is available
            if match != nil {
                // Allow navigation action
                return .allow
            }
        }
        Task(priority: .userInitiated) { [weak self] in
            // Verify player is available
            guard let player = self?.player else {
                // Otherwise return out of function
                return
            }
            // Open url
            await player.configuration.openURLAction(url: url, player: player)
        }
        // Cancel navigation action
        return .cancel
    }
    
    /// Invoked when the web view's web content process is terminated.
    /// - Parameter webView: The web view whose underlying web content process was terminated.
    func webViewWebContentProcessDidTerminate(
        _ webView: WKWebView
    ) {
        // Send web content process did terminate event
        self.eventSubject.send(
            .webContentProcessDidTerminate
        )
        self.player?
            .logger()?
            .error("WKWebView web content process did terminate")
    }
    
}

// MARK: - YouTubePlayerWebView+validURLRegularExpressions

private extension YouTubePlayerWebView {
    
    /// The valid URL RegularExpressions
    /// - SeeAlso: https://github.com/youtube/youtube-ios-player-helper/blob/f57129cd4380ec0a74dd3a59da3270a1d653d59b/Sources/YTPlayerView.m#L59-L63
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
