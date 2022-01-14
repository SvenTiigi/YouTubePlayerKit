import Foundation

// MARK: - YouTubePlayerWebView+handle(javaScriptEvent:)

extension YouTubePlayerWebView {
    
    /// Handle YouTubePlayer JavaScriptEvent
    /// - Parameters:
    ///   - javaScriptEvent: The YouTubePlayer JavaScriptEvent
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
                .map(self.playbackQualitySubject.send)
        case .onPlaybackRateChange:
            // Send PlaybackRate
            javaScriptEvent
                .data
                .flatMap(YouTubePlayer.PlaybackRate.init)
                .map(self.playbackRateSubject.send)
        case .onError:
            // Send error state
            javaScriptEvent
                .data
                .flatMap(Int.init)
                .flatMap(YouTubePlayer.Error.init)
                .map { .error($0) }
                .map(self.playerStateSubject.send)
        }
    }
    
}
