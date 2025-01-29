import Foundation

// MARK: - YouTubePlayer+JavaScriptEvent

public extension YouTubePlayer {
    
    /// A YouTubePlayer JavaScriptEvent
    struct JavaScriptEvent: Codable, Hashable, Sendable {
        
        // MARK: Properties
        
        /// The name.
        public var name: Name
        
        /// The optional data.
        public var data: String?
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer.JavaScriptEvent``
        /// - Parameters:
        ///   - name: The name.
        ///   - data: The optional data. Default value `nil`
        public init(
            name: Name,
            data: String? = nil
        ) {
            self.name = name
            self.data = data
        }
        
    }
    
}

// MARK: - CustomStringConvertible

extension YouTubePlayer.JavaScriptEvent: CustomStringConvertible {
    
    /// A textual representation of this instance.
    public var description: String {
        """
        Name: \(self.name.rawValue)
        Data: \(self.data ?? "nil")
        """
    }
    
}

// MARK: - Name

public extension YouTubePlayer.JavaScriptEvent {
    
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
