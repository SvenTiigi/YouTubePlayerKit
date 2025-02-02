import Foundation

// MARK: - YouTubePlayer+CaptionsTrack

public extension YouTubePlayer {
    
    /// A YouTube player captions track.
    struct CaptionsTrack: Hashable, Sendable, Identifiable {
        
        // MARK: Properties
        
        /// The identifier.
        public let id: String?
        
        /// The video subtitles system internal identifier.
        public let videoSubtitlesSystemID: String?
        
        /// The name.
        public let name: String?
        
        /// The display name.
        public let displayName: String?
        
        /// A Boolean specifying if this track is the default track.
        public let isDefault: Bool?
        
        /// A Boolean specifying if this track is servable.
        public let isServable: Bool?
        
        /// A Boolean specifying if this track is translateable.
        public let isTranslateable: Bool?
        
        /// The kind.
        public let kind: String?
        
        /// The language code.
        public let languageCode: CaptionsLanguageCode
        
        /// The language name.
        public let languageName: String
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer/CaptionsTrack``
        /// - Parameters:
        ///   - id: The identifier. Default value `nil`
        ///   - videoSubtitlesSystemID: The video subtitles system internal identifier. Default value `nil`
        ///   - name: The name. Default value `nil`
        ///   - displayName: The display name. Default value `nil`
        ///   - isDefault: A Boolean specifying if this track is the default track. Default value `nil`
        ///   - isServable: A Boolean specifying if this track is servable. Default value `nil`
        ///   - isTranslateable: A Boolean specifying if this track is translateable. Default value `nil`
        ///   - kind: The kind. Default value `nil`
        ///   - languageCode: The language code.
        ///   - languageName: The language name.
        public init(
            id: String? = nil,
            videoSubtitlesSystemID: String? = nil,
            name: String? = nil,
            displayName: String? = nil,
            isDefault: Bool? = nil,
            isServable: Bool? = nil,
            isTranslateable: Bool? = nil,
            kind: String? = nil,
            languageCode: CaptionsLanguageCode,
            languageName: String
        ) {
            self.id = id
            self.videoSubtitlesSystemID = videoSubtitlesSystemID
            self.name = name
            self.displayName = displayName
            self.isDefault = isDefault
            self.isServable = isServable
            self.isTranslateable = isTranslateable
            self.kind = kind
            self.languageCode = languageCode
            self.languageName = languageName
        }
        
    }
    
}

// MARK: - Codable

extension YouTubePlayer.CaptionsTrack: Codable {
    
    /// The CodingKeys.
    private enum CodingKeys: String, CodingKey {
        case id
        case videoSubtitlesSystemID = "vss_id"
        case name
        case displayName
        case isDefault = "is_default"
        case isServable = "is_servable"
        case isTranslateable = "is_translateable"
        case kind
        case languageCode
        case languageName
    }
    
}
