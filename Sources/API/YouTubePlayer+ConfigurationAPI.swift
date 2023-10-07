import Foundation

/// The YouTubePlayer Configuration API
public extension YouTubePlayer {
    
    /// Update YouTubePlayer Configuration
    /// - Note: Updating the Configuration will result in a reload of the entire YouTubePlayer
    /// - Parameter configuration: The YouTubePlayer Configuration
    func update(
        configuration: Configuration
    ) {
        // Stop Player
        self.stop()
        // Destroy Player
        self.webView.evaluate(
            javaScript: .player(function: "destroy"),
            converter: .empty
        ) { [weak self] _ in
            // Verify self is available
            guard let self = self else {
                // Otherwise return out of function
                return
            }
            // Update YouTubePlayer Configuration
            self.configuration = configuration
            // Check if PlayerState Subject has a current value
            if self.playerStateSubject.value != nil {
                // Reset PlayerState Subject current value
                self.playerStateSubject.send(nil)
            }
            // Check if PlaybackState Subject has a current value
            if self.playbackStateSubject.value != nil {
                // Reset PlaybackState Subject current value
                self.playbackStateSubject.send(nil)
            }
            // Check if PlaybackQuality Subject has a current value
            if self.playbackQualitySubject.value != nil {
                // Reset PlaybackQuality Subject current value
                self.playbackQualitySubject.send(nil)
            }
            // Check if PlaybackRate Subject has a current value
            if self.playbackRateSubject.value != nil {
                // Reset PlaybackRate Subject current value
                self.playbackRateSubject.send(nil)
            }
            // Re-Load Player
            self.webView.load(using: self)
        }
    }
    
    /// Reloads the YouTubePlayer.
    func reload() {
        self.update(
            configuration: self.configuration
        )
    }
    
}
