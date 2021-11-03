import Foundation

// MARK: - YouTubePlayer.JavaScriptEvent+Name

extension YouTubePlayer.JavaScriptEvent {
    
    /// The YouTubePlayer JavaScriptEvent Name
    enum Name: String, Codable, Hashable, CaseIterable {
        /// iFrame API is ready
        case onIframeAPIReady
        /// iFrame API failed to load
        case onIframeAPIFailedToLoad
        /// Ready
        case onReady
        /// State change
        case onStateChange
        /// Playback quality change
        case onPlaybackQualityChange
        /// Playback rate change
        case onPlaybackRateChange
        /// Error
        case onError
    }
    
}
