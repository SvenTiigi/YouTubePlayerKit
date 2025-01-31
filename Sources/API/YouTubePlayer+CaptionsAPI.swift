import Foundation

// MARK: - Captions API

public extension YouTubePlayer {
    
    /// Sets the font size of the captions displayed in the player.
    /// - Parameter fontSize: The font size
    func setCaptions(
        fontSize: CaptionsFontSize
    ) async throws(APIError) {
        try await self.setModuleOption(
            module: .captions,
            option: .fontSize,
            value: fontSize.value
        )
    }
    
    /// Reloads the captions data for the video that is currently playing.
    func reloadCaptions() async throws(APIError) {
        try await self.setModuleOption(
            module: .captions,
            option: .reload,
            value: true
        )
    }
    
    /// Sets the language of the captions.
    /// - Parameter languageCode: The language code.
    func setCaptions(
        languageCode: CaptionsLanguageCode
    ) async throws(APIError) {
        try await self.setModuleOption(
            module: .captions,
            option: .track,
            value: String(
                decoding: try { () throws(APIError) -> Data in
                    struct LanguageCodeParameter: Encodable {
                        let languageCode: CaptionsLanguageCode
                    }
                    do {
                        return try JSONEncoder()
                            .encode(
                                LanguageCodeParameter(
                                    languageCode: languageCode
                                )
                            )
                    } catch {
                        throw .init(
                            underlyingError: error,
                            reason: "Failed to encode language code parameter"
                        )
                    }
                }(),
                as: UTF8.self
            )
        )
    }
    
    /// Returns the current captions track.
    func getCaptionsTrack() async throws(APIError) -> CaptionsTrack {
        try await self.getModuleOption(
            module: .captions,
            option: .track,
            converter: .typeCast(
                to: [String: Any].self
            )
            .decode()
        )
    }
    
    /// Returns the captions tracks.
    func getCaptionsTracks() async throws(APIError) -> [CaptionsTrack] {
        try await self.getModuleOption(
            module: .captions,
            option: .tracklist,
            converter: .typeCast(
                to: [[String: Any]].self
            )
            .decode()
        )
    }
    
    /// Returns the captions translation languges.
    func getCaptionsTranslationLanguages() async throws(APIError) -> [CaptionsTranslationLanguage] {
        try await self.getModuleOption(
            module: .captions,
            option: .translationLanguages,
            converter: .typeCast(
                to: [[String: Any]].self
            )
            .decode()
        )
    }
    
}
