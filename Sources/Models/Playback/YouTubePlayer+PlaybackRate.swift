import Foundation

// MARK: - YouTubePlayer+PlaybackRate

public extension YouTubePlayer {
    
    /// The YouTube player playback rate.
    struct PlaybackRate: Hashable, Sendable {
        
        // MARK: Properties
        
        /// The value.
        public let value: Double
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer/PlaybackRate``
        /// - Parameter value: The value.
        public init(
            value: Double
        ) {
            self.value = value
        }
        
    }
    
}

// MARK: - Codable

extension YouTubePlayer.PlaybackRate: Codable {
    
    /// Creates a new instance of ``YouTubePlayer/PlaybackRate``
    /// - Parameter decoder: The decoder.
    public init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.singleValueContainer()
        self.init(
            value: try container.decode(Double.self)
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

extension YouTubePlayer.PlaybackRate: ExpressibleByFloatLiteral {
    
    /// Creates a new instance of ``YouTubePlayer/PlaybackRate``
    /// - Parameter value: The value.
    public init(
        floatLiteral value: Double
    ) {
        self.init(
            value: value
        )
    }
    
}

// MARK: - Comparable

extension YouTubePlayer.PlaybackRate: Comparable {
    
    /// Returns a Boolean value indicating whether the value of the first
    /// argument is less than that of the second argument.
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func < (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        lhs.value < rhs.value
    }
    
}

// MARK: - CustomStringConvertible

extension YouTubePlayer.PlaybackRate: CustomStringConvertible {
    
    /// A textual representation of this instance.
    public var description: String {
        "\(Decimal(self.value))x"
    }
    
}

// MARK: - CaseIterable

extension YouTubePlayer.PlaybackRate: CaseIterable {
    
    /// A collection of all known values of this type.
    public static let allCases: [Self] = [
        .quarterSpeed,
        .halfSpeed,
        .threeQuarterSpeed,
        .normal,
        .oneQuarterFaster,
        .oneHalfFaster,
        .threeQuarterFaster,
        .double
    ]
    
    /// Playback rate 0.25x
    public static let quarterSpeed: Self = 0.25
    
    /// Playback rate 0.5x
    public static let halfSpeed: Self = 0.5
    
    /// Playback rate 0.75x
    public static let threeQuarterSpeed: Self = 0.75
    
    /// Playback rate 1.0x
    public static let normal: Self = 1.0
    
    /// Playback rate 1.25x
    public static let oneQuarterFaster: Self = 1.25
    
    /// Playback rate 1.5x
    public static let oneHalfFaster: Self = 1.5
    
    /// Playback rate 1.75x
    public static let threeQuarterFaster: Self = 1.75
    
    /// Playback rate 2.0x
    public static let double: Self = 2.0
    
}
