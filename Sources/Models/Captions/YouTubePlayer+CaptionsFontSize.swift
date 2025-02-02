import Foundation

// MARK: - YouTubePlayer+CaptionsFontSize

public extension YouTubePlayer {
    
    /// The YouTube player captions font size.
    struct CaptionsFontSize: Hashable, Sendable {
        
        // MARK: Properties
        
        /// The value.
        public let value: Int
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer/CaptionsFontSize``
        /// - Parameter value: The value.
        public init(
            value: Int
        ) {
            self.value = value
        }
        
    }
    
}

// MARK: - Codable

extension YouTubePlayer.CaptionsFontSize: Codable {
    
    /// Creates a new instance of ``YouTubePlayer/CaptionsFontSize``
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

extension YouTubePlayer.CaptionsFontSize: ExpressibleByIntegerLiteral {
    
    /// Creates a new instance of ``YouTubePlayer/CaptionsFontSize``
    /// - Parameter value: The value.
    public init(
        integerLiteral value: Int
    ) {
        self.init(
            value: value
        )
    }
    
}

// MARK: - Comparable

extension YouTubePlayer.CaptionsFontSize: Comparable {
    
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

// MARK: - CaseIterable

extension YouTubePlayer.CaptionsFontSize: CaseIterable {
    
    /// A collection of all known values of this type.
    public static let allCases: [Self] = [
        .small,
        .default,
        .medium,
        .large,
        .extraLarge
    ]
    
    /// Small.
    public static let small: Self = -1
    
    /// Default.
    public static let `default`: Self = 0
    
    /// Medium.
    public static let medium: Self = 1
    
    /// Large.
    public static let large: Self = 2
    
    /// Extra large.
    public static let extraLarge: Self = 3
    
}

// MARK: - CustomStringConvertible

extension YouTubePlayer.CaptionsFontSize: CustomStringConvertible {
    
    /// A textual representation of this instance.
    public var description: String {
        switch self {
        case .small:
            return "Small"
        case .default:
            return "Default"
        case .medium:
            return "Medium"
        case .large:
            return "Large"
        case .extraLarge:
            return "Extra Large"
        default:
            return "Unknown: \(self.value)"
        }
    }
    
}
