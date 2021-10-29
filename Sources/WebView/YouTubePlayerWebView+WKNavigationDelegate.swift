import Foundation
import WebKit

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
        // Check if a Resolved JavaScriptEvent can be initialized from request URL
        if let resolvedJavaScriptEvent = YouTubePlayer.HTML.JavaScriptEvent.Resolved(url: url) {
            // Handle JavaScriptEvent
            self.handle(
                resolvedJavaScriptEvent: resolvedJavaScriptEvent
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
        self.open(url: url)
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

// MARK: - Handle resolved YouTube Player Event Callback

private extension YouTubePlayerWebView {
    
    /// Handle resolved YouTubePlayer HTML JavaScriptEvent
    /// - Parameters:
    ///   - resolvedJavaScriptEvent: The Resolved JavaScriptEvent
    func handle(
        resolvedJavaScriptEvent: YouTubePlayer.HTML.JavaScriptEvent.Resolved
    ) {
        // Switch on Resolved JavaScriptEvent
        switch resolvedJavaScriptEvent.event {
        case .onIframeAPIReady:
            // Simply do nothing
            break
        case .onIframeAPIFailedToLoad:
            // Send error state
            self.playerStateSubject.send(.error(.iFrameAPIFailedToLoad))
        case .onReady:
            // Send ready state
            self.playerStateSubject.send(.ready)
            // Check if autoPlay is enabled
            if self.player.configuration.autoPlay == true {
                // Play Video
                self.play()
            }
            // Retrieve the current PlaybackRate
            self.player.getPlaybackRate { [weak self] result in
                // Verify PlaybackRate is available
                guard case .success(let playbackRate) = result else {
                    // Otherwise ignore the error and return out of function
                    return
                }
                // Send PlaybackRate
                self?.playbackRateSubject.send(playbackRate)
            }
            // Retrieve the current PlaybackState
            self.player.getPlaybackState { [weak self] result in
                // Verify PlaybackState is available
                guard case .success(let playbackState) = result else {
                    // Otherwise ignore the error and return out of function
                    return
                }
                // Send PlaybackState
                self?.playbackStateSubject.send(playbackState)
            }
        case .onStateChange:
            // Send PlaybackState
            resolvedJavaScriptEvent
                .data
                .flatMap(Int.init)
                .flatMap(YouTubePlayer.PlaybackState.init)
                .map(self.playbackStateSubject.send)
        case .onPlaybackQualityChange:
            // Send PlaybackQuality
            resolvedJavaScriptEvent
                .data
                .flatMap(YouTubePlayer.PlaybackQuality.init)
                .map(self.playbackQualitySubject.send)
        case .onPlaybackRateChange:
            // Send PlaybackRate
            resolvedJavaScriptEvent
                .data
                .flatMap(YouTubePlayer.PlaybackRate.init)
                .map(self.playbackRateSubject.send)
        case .onError:
            // Send error state
            resolvedJavaScriptEvent
                .data
                .flatMap(Int.init)
                .flatMap(YouTubePlayer.Error.init)
                .map { .error($0) }
                .map(self.playerStateSubject.send)
        }
    }
    
}
