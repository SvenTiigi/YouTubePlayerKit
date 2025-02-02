import Foundation

// MARK: - YouTubePlayer+CaptionsLanguageCode

public extension YouTubePlayer {
    
    /// A YouTube player captions language code.
    struct CaptionsLanguageCode: Hashable, Sendable, Identifiable {
        
        // MARK: Properties
        
        /// The identifier / language code.
        public let id: String
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer/CaptionsLanguageCode``
        /// - Parameter id: The identifier / language code.
        public init(
            id: String
        ) {
            self.id = id
        }
        
    }
    
}

// MARK: - Codable

extension YouTubePlayer.CaptionsLanguageCode: Codable {
    
    /// Creates a new instance of ``YouTubePlayer/CaptionsLanguageCode``
    /// - Parameter decoder: The decoder.
    public init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.singleValueContainer()
        self.init(
            id: try container.decode(String.self)
        )
    }
    
    /// Encode.
    /// - Parameter encoder: The encoder.
    public func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.id)
    }
    
}

// MARK: - ExpressibleByStringLiteral

extension YouTubePlayer.CaptionsLanguageCode: ExpressibleByStringLiteral {
    
    /// Creates a new instance of ``YouTubePlayer/CaptionsLanguageCode``
    /// - Parameter id: The identifier / language code.
    public init(
        stringLiteral id: String
    ) {
        self.init(
            id: id
        )
    }
    
}

// MARK: - CustomStringConvertible

extension YouTubePlayer.CaptionsLanguageCode: CustomStringConvertible {
    
    /// A textual representation of this instance.
    public var description: String {
        self.localizedString() ?? self.id
    }
    
}

// MARK: - Localized String

public extension YouTubePlayer.CaptionsLanguageCode {
    
    /// Returns a localized string, if available.
    /// - Parameter locale: The `Locale`. Default value `.current`
    func localizedString(
        locale: Locale = .current
    ) -> String? {
        locale.localizedString(
            forLanguageCode: self.id
        )
    }
    
}

// MARK: - Well-Known

public extension YouTubePlayer.CaptionsLanguageCode {
    
    /// Arabic
    static let arabic: Self = "ar"

    /// Chinese (Simplified)
    static let chineseSimplified: Self = "zh-Hans"

    /// Chinese (Traditional)
    static let chineseTraditional: Self = "zh-Hant"

    /// Czech
    static let czech: Self = "cs"

    /// Danish
    static let danish: Self = "da"

    /// Dutch
    static let dutch: Self = "nl"

    /// English
    static let english: Self = "en"

    /// English (United States)
    static let englishUS: Self = "en-US"

    /// Finnish
    static let finnish: Self = "fi"

    /// French
    static let french: Self = "fr"

    /// German
    static let german: Self = "de"

    /// Greek
    static let greek: Self = "el"

    /// Hebrew
    static let hebrew: Self = "iw"

    /// Hindi
    static let hindi: Self = "hi"

    /// Hungarian
    static let hungarian: Self = "hu"

    /// Indonesian
    static let indonesian: Self = "id"

    /// Italian
    static let italian: Self = "it"

    /// Japanese
    static let japanese: Self = "ja"

    /// Korean
    static let korean: Self = "ko"

    /// Malay
    static let malay: Self = "ms"

    /// Norwegian
    static let norwegian: Self = "no"

    /// Polish
    static let polish: Self = "pl"

    /// Portuguese
    static let portuguese: Self = "pt"

    /// Portuguese (Portugal)
    static let portuguesePortugal: Self = "pt-PT"

    /// Romanian
    static let romanian: Self = "ro"

    /// Russian
    static let russian: Self = "ru"

    /// Spanish
    static let spanish: Self = "es"

    /// Spanish (Latin America)
    static let spanishLatinAmerica: Self = "es-419"

    /// Swedish
    static let swedish: Self = "sv"

    /// Thai
    static let thai: Self = "th"

    /// Turkish
    static let turkish: Self = "tr"

    /// Ukrainian
    static let ukrainian: Self = "uk"

    /// Vietnamese
    static let vietnamese: Self = "vi"
    
}
