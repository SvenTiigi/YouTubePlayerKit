import Foundation

// MARK: - YouTubePlayer+CaptionsTranslationLanguage

public extension YouTubePlayer {
    
    /// A YouTube player captions translation language
    struct CaptionsTranslationLanguage: Codable, Hashable, Sendable {
        
        // MARK: Properties
        
        /// The language code.
        public let languageCode: CaptionsLanguageCode
        
        /// The language name.
        public let languageName: String
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer/CaptionsTranslationLanguage``
        /// - Parameters:
        ///   - languageCode: The language code.
        ///   - languageName: The language name.
        public init(
            languageCode: CaptionsLanguageCode,
            languageName: String
        ) {
            self.languageCode = languageCode
            self.languageName = languageName
        }
        
    }
    
}

// MARK: - CustomStringConvertible

extension YouTubePlayer.CaptionsTranslationLanguage: CustomStringConvertible {
    
    /// A textual representation of this instance.
    public var description: String {
        self.languageCode.localizedString() ?? self.languageName
    }
    
}
