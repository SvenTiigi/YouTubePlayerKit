import Foundation

// MARK: - YouTubePlayer+PlaybackState

public extension YouTubePlayer {
    
    /// The YouTube player playback state.
    struct PlaybackState: Hashable, Sendable {
        
        // MARK: Properties
        
        /// The value.
        public let value: Int
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer/PlaybackState``
        /// - Parameter value: The value.
        public init(
            value: Int
        ) {
            self.value = value
        }
        
    }
    
}

// MARK: - Codable

extension YouTubePlayer.PlaybackState: Codable {
    
    /// Creates a new instance of ``YouTubePlayer/PlaybackState``
    /// - Parameter decoder: The decoder.
    public init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.singleValueContainer()
        self.init(
            value: try container.decode(Int.self)
        )
    }
    
    /// Encode.
    /// - Parameter encoder: The encoder.
    public func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.value)
    }
    
}

// MARK: - ExpressibleByStringLiteral

extension YouTubePlayer.PlaybackState: ExpressibleByIntegerLiteral {
    
    /// Creates a new instance of ``YouTubePlayer/PlaybackState``
    /// - Parameter value: The value.
    public init(
        integerLiteral value: Int
    ) {
        self.init(
            value: value
        )
    }
    
}

// MARK: - CustomStringConvertible

extension YouTubePlayer.PlaybackState: CustomStringConvertible {
    
    /// A textual representation of this instance.
    public var description: String {
        switch self {
        case .unstarted:
            return "Unstarted"
        case .ended:
            return "Ended"
        case .playing:
            return "Playing"
        case .paused:
            return "Paused"
        case .buffering:
            return "Buffering"
        case .cued:
            return "Cued"
        default:
            return "Unknown: \(self.value)"
        }
    }
    
}

// MARK: - CaseIterable

extension YouTubePlayer.PlaybackState: CaseIterable {
    
    /// A collection of all known values of this type.
    public static let allCases: [Self] = [
        .unstarted,
        .ended,
        .playing,
        .paused,
        .buffering,
        .cued
    ]
    
    /// Unstarted.
    public static let unstarted: Self = -1
    
    /// Ended.
    public static let ended: Self = 0
    
    /// Playing.
    public static let playing: Self = 1
    
    /// Paused.
    public static let paused: Self = 2
    
    /// Buffering.
    public static let buffering: Self = 3
    
    /// Video cued.
    public static let cued: Self = 5
    
}
