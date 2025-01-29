import Foundation

// MARK: - Captions

public extension YouTubePlayer {
    
    /// Sets the font size of the captions displayed in the player.
    /// - Parameter fontSize: The font size
    func setCaptions(
        fontSize: CaptionsFontSize
    ) async throws(APIError) {
        try await self.evaluate(
            javaScript: .youTubePlayer(
                functionName: "setOption",
                parameters: [
                    "'captions'",
                    "'fontSize'",
                    String(fontSize.value)
                ]
            )
        )
    }
    
    /// Reloads the captions data for the video that is currently playing.
    func reloadCaptions() async throws(APIError) {
        try await self.evaluate(
            javaScript: .youTubePlayer(
                functionName: "setOption",
                parameters: [
                    "'captions'",
                    "'reload'",
                    true
                ]
            )
        )
    }
    
    /// Sets the language of the captions.
    /// - Parameter languageCode: The language code.
    func setCaptions(
        languageCode: CaptionsLanguageCode
    ) async throws(APIError) {
        struct LanguageCodeParameter: Encodable {
            let languageCode: CaptionsLanguageCode
        }
        let encodedLanguageCodeParameter: Data
        do {
            encodedLanguageCodeParameter = try JSONEncoder()
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
        try await self.evaluate(
            javaScript: .youTubePlayer(
                functionName: "setOption",
                parameters: [
                    "'captions'",
                    "'track'",
                    String(
                        decoding: encodedLanguageCodeParameter,
                        as: UTF8.self
                    )
                ]
            )
        )
    }
    
    /// Returns the current captions track.
    func getCaptionsTrack() async throws(APIError) -> CaptionsTrack {
        try await self.evaluate(
            javaScript: .youTubePlayer(
                functionName: "getOption",
                parameters: [
                    "'captions'",
                    "'track'"
                ]
            ),
            converter: .typeCast(
                to: [String: Any].self
            )
            .decode()
        )
    }
    
    /// Returns the captions tracks.
    func getCaptionsTracks() async throws(APIError) -> [CaptionsTrack] {
        try await self.evaluate(
            javaScript: .youTubePlayer(
                functionName: "getOption",
                parameters: [
                    "'captions'",
                    "'tracklist'"
                ]
            ),
            converter: .typeCast(
                to: [[String: Any]].self
            )
            .decode()
        )
    }
    
    /// Returns the captions translation languges.
    func getCaptionsTranslationLanguages() async throws(APIError) -> [CaptionsTranslationLanguage] {
        try await self.evaluate(
            javaScript: .youTubePlayer(
                functionName: "getOption",
                parameters: [
                    "'captions'",
                    "'translationLanguages'"
                ]
            ),
            converter: .typeCast(
                to: [[String: Any]].self
            )
            .decode()
        )
    }
    
}
