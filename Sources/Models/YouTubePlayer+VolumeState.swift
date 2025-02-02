import Foundation

// MARK: - YouTubePlayer+VolumeState

public extension YouTubePlayer {
    
    /// A YouTube player volume state.
    struct VolumeState: Hashable, Sendable {
        
        // MARK: Properties
        
        /// A Boolean indicating if the player is muted or not.
        public let isMuted: Bool
        
        /// The volume from 0 to 100.
        public let volume: Int?
        
        /// A Boolean if the volume is unstorable.
        public let isUnstorable: Bool?
        
        /// Creates a new instance of ``YouTubePlayer/VolumeState``
        /// - Parameters:
        ///   - isMuted: A Boolean indicating if the player is muted or not.
        ///   - volume: The volume from 0 to 100. Default value `nil`
        ///   - isUnstorable: A Boolean if the volume is unstorable. Default value `nil`
        public init(
            isMuted: Bool,
            volume: Int? = nil,
            isUnstorable: Bool? = nil
        ) {
            self.isMuted = isMuted
            self.volume = volume
            self.isUnstorable = isUnstorable
        }
        
    }
    
}

// MARK: - Codable

extension YouTubePlayer.VolumeState: Codable {
    
    /// The coding keys.
    private enum CodingKeys: String, CodingKey {
        case isMuted = "muted"
        case volume
        case isUnstorable = "unstorable"
    }
    
    /// Creates a new instance of ``YouTubePlayer/VolumeState``
    /// - Parameter decoder: The decoder.
    public init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            isMuted: container.decode(Bool.self, forKey: .isMuted),
            volume: container.decodeIfPresent(Int.self, forKey: .volume),
            isUnstorable: container.decodeIfPresent(Bool.self, forKey: .isUnstorable)
        )
    }
    
    /// Encode.
    /// - Parameter encoder: The encoder.
    public func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.isMuted, forKey: .isMuted)
        try container.encode(self.volume, forKey: .volume)
        try container.encode(self.isUnstorable, forKey: .isUnstorable)
    }
    
}

// MARK: - ExpressibleByBooleanLiteral

extension YouTubePlayer.VolumeState: ExpressibleByBooleanLiteral {
    
    /// Creates a new instance of ``YouTubePlayer/VolumeState``
    /// - Parameter isMuted: A Boolean indicating whether it is in fullscreen or not.
    public init(
        booleanLiteral isMuted: Bool
    ) {
        self.init(
            isMuted: isMuted
        )
    }
    
}
