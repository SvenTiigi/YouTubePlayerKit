import Foundation

// MARK: - YouTubePlayer+JavaScriptEvent

extension YouTubePlayer {
    
    /// A YouTubePlayer JavaScriptEvent
    struct JavaScriptEvent: Codable, Hashable, Sendable {
        
        /// The JavaScriptEvent Name
        let name: Name
        
        /// The optional data payload
        var data: String?
        
    }
    
}

// MARK: - CustomStringConvertible

extension YouTubePlayer.JavaScriptEvent: CustomStringConvertible {
    
    /// A textual representation of this instance.
    var description: String {
        """
        Name: \(self.name.rawValue)
        Data: \(self.data ?? "nil")
        """
    }
    
}

// MARK: - Name

extension YouTubePlayer.JavaScriptEvent {
    
    /// The YouTubePlayer JavaScriptEvent Name
    enum Name: String, Codable, Hashable, Sendable, CaseIterable {
        /// iFrame Api is ready
        case onIframeApiReady
        /// iFrame Api failed to load
        case onIframeApiFailedToLoad
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
        /// API Change
        case onApiChange
        /// Autoplay blocked
        case onAutoplayBlocked
    }
    
}
