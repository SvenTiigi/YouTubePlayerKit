import Foundation

// MARK: - YouTubePlayer

public extension YouTubePlayer {
    
    /// A YouTube player fullscreen state.
    struct FullscreenState: Hashable, Sendable {
        
        // MARK: Properties
        
        /// A Boolean indicating whether it is in fullscreen or not.
        public let isFullscreen: Bool
        
        /// The video identifier.
        public let videoID: String?
        
        /// The time.
        public let time: Measurement<UnitDuration>?
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer/FullscreenState``
        /// - Parameters:
        ///   - isFullscreen: A Boolean indicating whether it is in fullscreen or not.
        ///   - videoID: The video identifier. Default value `nil`
        ///   - time: The time. Default value `nil`
        public init(
            isFullscreen: Bool,
            videoID: String? = nil,
            time: Measurement<UnitDuration>? = nil
        ) {
            self.isFullscreen = isFullscreen
            self.videoID = videoID
            self.time = time
        }
        
    }
    
}

// MARK: - Codable

extension YouTubePlayer.FullscreenState: Codable {
    
    /// The coding keys.
    private enum CodingKeys: String, CodingKey {
        case isFullscreen = "fullscreen"
        case videoID = "videoId"
        case time
    }
    
    /// Creates a new instance of ``YouTubePlayer/FullscreenState``
    /// - Parameter decoder: The decoder.
    public init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            isFullscreen: container.decode(Bool.self, forKey: .isFullscreen),
            videoID: container.decodeIfPresent(String.self, forKey: .videoID),
            time: container.decodeIfPresent(Double.self, forKey: .time).flatMap { .init(value: $0, unit: .seconds) }
        )
    }
    
    /// Encode.
    /// - Parameter encoder: The encoder.
    public func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.isFullscreen, forKey: .isFullscreen)
        try container.encode(self.videoID, forKey: .videoID)
        try container.encode(self.time?.converted(to: .seconds).value, forKey: .time)
    }
    
}

// MARK: - ExpressibleByBooleanLiteral

extension YouTubePlayer.FullscreenState: ExpressibleByBooleanLiteral {
    
    /// Creates a new instance of ``YouTubePlayer/FullscreenState``
    /// - Parameter isFullscreen: A Boolean indicating whether it is in fullscreen or not.
    public init(
        booleanLiteral isFullscreen: Bool
    ) {
        self.init(
            isFullscreen: isFullscreen
        )
    }
    
}
