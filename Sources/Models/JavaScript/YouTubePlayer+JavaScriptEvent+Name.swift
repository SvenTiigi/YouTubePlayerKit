import Foundation

// MARK: - Name

public extension YouTubePlayer.JavaScriptEvent {
    
    /// The YouTubePlayer JavaScriptEvent Name
    enum Name: String, Codable, Hashable, Sendable, CaseIterable {
        /// iFrame Api is ready
        case onIframeApiReady
        /// iFrame Api failed to load
        case onIframeApiFailedToLoad
        /// Error
        case onError
        /// Ready
        case onReady
        /// API Change
        case onApiChange
        /// Autoplay blocked
        case onAutoplayBlocked
        /// State change
        case onStateChange
        /// Playback quality change
        case onPlaybackQualityChange
        /// Playback rate change
        case onPlaybackRateChange
        /// Fullscreen change
        case onFullscreenChange
    }
    
}
