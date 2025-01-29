import Foundation

// MARK: - YouTubePlayer+CaptionsLanguageCode

public extension YouTubePlayer {
    
    /// A YouTube player captions language code.
    struct CaptionsLanguageCode: Hashable, Sendable, Identifiable {
        
        // MARK: Properties
        
        /// The identifier / language code.
        public let id: String
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer.CaptionsLanguageCode``
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
    
    /// Creates a new instance of ``YouTubePlayer.CaptionsLanguageCode``
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
    
    /// Creates a new instance of ``YouTubePlayer.CaptionsLanguageCode``
    /// - Parameter id: The identifier / language code.
    public init(
        stringLiteral id: String
    ) {
        self.init(
            id: id
        )
    }
    
}

// MARK: - Localized String

public extension YouTubePlayer.CaptionsLanguageCode {
    
    /// Returns a localized string, if available.
    /// - Parameter locale: The ``Locale``. Default value `.current`
    func localizedString(
        locale: Locale = .current
    ) -> String? {
        locale.localizedString(
            forLanguageCode: self.id
        )
    }
    
}

// MARK: - Well-Known

extension YouTubePlayer.CaptionsLanguageCode {
    
    /// Arabic
    public static let arabic: Self = "ar"

    /// Chinese (Simplified)
    public static let chineseSimplified: Self = "zh-Hans"

    /// Chinese (Traditional)
    public static let chineseTraditional: Self = "zh-Hant"

    /// Czech
    public static let czech: Self = "cs"

    /// Danish
    public static let danish: Self = "da"

    /// Dutch
    public static let dutch: Self = "nl"

    /// English
    public static let english: Self = "en"

    /// English (United States)
    public static let englishUS: Self = "en-US"

    /// Finnish
    public static let finnish: Self = "fi"

    /// French
    public static let french: Self = "fr"

    /// German
    public static let german: Self = "de"

    /// Greek
    public static let greek: Self = "el"

    /// Hebrew
    public static let hebrew: Self = "iw"

    /// Hindi
    public static let hindi: Self = "hi"

    /// Hungarian
    public static let hungarian: Self = "hu"

    /// Indonesian
    public static let indonesian: Self = "id"

    /// Italian
    public static let italian: Self = "it"

    /// Japanese
    public static let japanese: Self = "ja"

    /// Korean
    public static let korean: Self = "ko"

    /// Malay
    public static let malay: Self = "ms"

    /// Norwegian
    public static let norwegian: Self = "no"

    /// Polish
    public static let polish: Self = "pl"

    /// Portuguese
    public static let portuguese: Self = "pt"

    /// Portuguese (Portugal)
    public static let portuguesePortugal: Self = "pt-PT"

    /// Romanian
    public static let romanian: Self = "ro"

    /// Russian
    public static let russian: Self = "ru"

    /// Spanish
    public static let spanish: Self = "es"

    /// Spanish (Latin America)
    public static let spanishLatinAmerica: Self = "es-419"

    /// Swedish
    public static let swedish: Self = "sv"

    /// Thai
    public static let thai: Self = "th"

    /// Turkish
    public static let turkish: Self = "tr"

    /// Ukrainian
    public static let ukrainian: Self = "uk"

    /// Vietnamese
    public static let vietnamese: Self = "vi"
    
}
