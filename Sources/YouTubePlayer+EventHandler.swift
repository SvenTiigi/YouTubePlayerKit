import Foundation

// MARK: - YouTubePlayer+handle(webViewEvent:)

extension YouTubePlayer {
    
    /// Handle a YouTubePlayerWebView Event
    /// - Parameter webViewEvent: The YouTubePlayerWebView Event
    func handle(
        webViewEvent: YouTubePlayerWebView.Event
    ) {
        switch webViewEvent {
        case .receivedJavaScriptEvent(let javaScriptEvent):
            // Handle JavaScriptEvent
            self.handle(
                javaScriptEvent: javaScriptEvent
            )
        case .frameChanged(let frame):
            // Initialize parameters
            let parameters = [
                frame.size.width,
                frame.size.height
            ]
            .map(String.init)
            .joined(separator: ",")
            // Set YouTubePlayer Size
            self.webView.evaluate(
                javaScript: .init("setYouTubePlayerSize(\(parameters));")
            )
        case .webContentProcessDidTerminate:
            // Send web content process did terminate error
            self.playerStateSubject.send(
                .error(.webContentProcessDidTerminate)
            )
        }
    }
    
}

// MARK: - YouTubePlayer+handle(javaScriptEvent:)

private extension YouTubePlayer {
    
    /// Handle incoming JavaScriptEvent
    /// - Parameter javaScriptEvent: The YouTubePlayer JavaScriptEvent
    func handle(
        javaScriptEvent: YouTubePlayer.JavaScriptEvent
    ) {
        // Switch on Resolved JavaScriptEvent Name
        switch javaScriptEvent.name {
        case .onIframeAPIReady:
            // Simply do nothing as we only
            // perform action on an `onReady` event
            break
        case .onIframeAPIFailedToLoad:
            // Send error state
            self.playerStateSubject.send(.error(.iFrameAPIFailedToLoad))
        case .onReady:
            // Send ready state
            self.playerStateSubject.send(.ready)
            // Check if autoPlay is enabled
            if self.configuration.autoPlay == true && self.source != nil {
                // Play Video
                self.play()
            }
            // Retrieve the current PlaybackRate
            self.getPlaybackRate { [weak self] result in
                // Verify PlaybackRate is available
                guard case .success(let playbackRate) = result else {
                    // Otherwise ignore the error and return out of function
                    return
                }
                // Send PlaybackRate
                self?.playbackRateSubject.send(playbackRate)
            }
            // Retrieve the current PlaybackState
            self.getPlaybackState { [weak self] result in
                // Verify PlaybackState is available
                guard case .success(let playbackState) = result else {
                    // Otherwise ignore the error and return out of function
                    return
                }
                // Send PlaybackState
                self?.playbackStateSubject.send(playbackState)
            }
        case .onStateChange:
            // Verify YouTubePlayer PlaybackState is available
            guard let playbackState: YouTubePlayer.PlaybackState? = {
                // Verify JavaScript Event Data is available
                guard let javaScriptEventData = javaScriptEvent.data else {
                    // Otherwise return ended state
                    return .ended
                }
                // Return PlaybackState from JavaScript Event Code
                return Int(
                    javaScriptEventData
                )
                .flatMap(YouTubePlayer.PlaybackState.init)
            }() else {
                // Otherwise return out of function
                return
            }
            // Send PlaybackState
            self.playbackStateSubject.send(playbackState)
        case .onPlaybackQualityChange:
            // Send PlaybackQuality
            javaScriptEvent
                .data
                .flatMap(YouTubePlayer.PlaybackQuality.init)
                .map { self.playbackQualitySubject.send($0) }
        case .onPlaybackRateChange:
            // Send PlaybackRate
            javaScriptEvent
                .data
                .flatMap(YouTubePlayer.PlaybackRate.init)
                .map { self.playbackRateSubject.send($0) }
        case .onError:
            // Send error state
            javaScriptEvent
                .data
                .flatMap(Int.init)
                .flatMap(YouTubePlayer.Error.init)
                .map { .error($0) }
                .map { self.playerStateSubject.send($0) }
        }
    }
    
}
