import Foundation

// MARK: - YouTubePlayer+HTML+JavaScriptEvent

extension YouTubePlayer.HTML {
    
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

// MARK: - Callback Registration

extension YouTubePlayer.HTML.JavaScriptEvent {
    
    /// The JavaScriptEvent Callback Registration Dictionary
    static var callbackRegistration: [String: String] {
        Self
            .allCases
            .filter { event in
                event != .onIframeAPIReady
                    || event != .onIframeAPIFailedToLoad
            }
            .reduce(
                into: .init()
            ) { result, event in
                result[event.rawValue] = event.rawValue
            }
    }
    
}
