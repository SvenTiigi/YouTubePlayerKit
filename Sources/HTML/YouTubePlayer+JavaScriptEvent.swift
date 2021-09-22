import Foundation

// MARK: - YouTubePlayer+JavaScriptEvent

extension YouTubePlayer {
    
    /// The YouTubePlayer HTML JavaScript Event
    enum JavaScriptEvent: String, Codable, Hashable, CaseIterable {
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

// MARK: - JavaScriptEvent+scheme

extension YouTubePlayer.JavaScriptEvent {
    
    /// The Scheme
    static let scheme = "youtubeplayer"
    
}

// MARK: - JavaScriptEvent+dataParameterName

extension YouTubePlayer.JavaScriptEvent {
    
    /// The data parameter name
    static let dataParameterName = "data"
    
}
