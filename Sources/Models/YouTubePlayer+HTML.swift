import Foundation

// MARK: - YouTubePlayer+HTML

extension YouTubePlayer {
    
    /// The YouTubePlayer HTML
    enum HTML {}
    
}

// MARK: - Contents

extension YouTubePlayer.HTML {
    
    /// Retrieve contents of YouTubePlayer HTML for a given YouTubePlayer, if available
    /// - Parameters:
    ///   - player: The YouTubePlayer
    ///   - bundle: The Bundle. Default value `.module`
    /// - Returns: The optional contents of the YouTubePlayer HTML
    static func contents(
        for player: YouTubePlayer,
        originURL: URL?,
        from bundle: Bundle = .module
    ) -> String? {
        bundle.url(
            forResource: "YouTubePlayer",
            withExtension: "html"
        )
        .flatMap { url in
            try? String(
                contentsOf: url,
                encoding: .utf8
            )
        }
        .flatMap { html in
            // Verify JavaScript Configuration can be encoded
            guard let javaScripConfiguration = try? player
                    .encodeJavaScriptConfiguration(originURL: originURL) else {
                // Otherwise return nil
                return nil
            }
            // Replace Tokenizer with JavaScript Configuration
            return html.replacingOccurrences(
                of: "YOUTUBE_PLAYER_CONFIGURATION",
                with: javaScripConfiguration
            )
        }
    }
    
}

// MARK: - YouTubePlayer+encodeJavaScriptConfiguration

private extension YouTubePlayer {
    
    /// Encode JavaScript Configuration
    /// - Parameter originURL: The origin URL
    func encodeJavaScriptConfiguration(
        originURL: URL?
    ) throws -> String? {
        // Retrieve Player Configuration as JSON
        var playerConfiguration = try self.configuration.json()
        // Initialize Configuration
        var configuration: [String: Any] = [
            "width": "100%",
            "height": "100%",
            "events": YouTubePlayer.JavaScriptEvent.supportedEvents
        ]
        // Switch on Source
        switch self.source {
        case .video(let id, let startTime):
            // Set video id
            configuration["videoId"] = id
            // Check if a start time is available
            if let startTime = startTime {
                // Set start time on player configuration
                playerConfiguration[
                    YouTubePlayer.Configuration.CodingKeys.startTime.rawValue
                ] = startTime
            }
        case .playlist(let id):
            // Set playlist
            playerConfiguration["listType"] = "playlist"
            // Set playlist id
            playerConfiguration["list"] = id
        case .channel(let id):
            // Set user uploads
            playerConfiguration["listType"] = "user_uploads"
            // Set channel id
            playerConfiguration["list"] = id
        case nil:
            // Simply do nothing
            break
        }
        // Check if an origin URL is available
        if let originURL = originURL {
            // Set origin URL
            playerConfiguration["origin"] = originURL.absoluteString
        }
        // Set Player Configuration
        configuration["playerVars"] = playerConfiguration
        // Make JSON string from Configuration
        return try configuration.json()
    }
    
}

// MARK: - YouTubePlayer+JavaScriptEvent+events

private extension YouTubePlayer.JavaScriptEvent {
    
    /// The supported Events Dictionary
    static var supportedEvents: [String: String] {
        YouTubePlayer
            .JavaScriptEvent
            .allCases
            .filter { event in
                event != .onIframeAPIReady
                    || event != .onIframeAPIFailedToLoad
            }
            .reduce(
                into: .init()
            ) { result, event in
                result[event.rawValue] = event.rawValue
            }
    }
    
}

// MARK: - Encodable+JSON

private extension Encodable {
    
    /// Make JSON Dictionary
    func json() throws -> [String: Any] {
        // Initialize JSONEncoder
        let encoder = JSONEncoder()
        // Set without escaping slashes output formatting
        encoder.outputFormatting = .withoutEscapingSlashes
        // Encode
        let jsonData = try encoder.encode(self)
        // Serialize to JSON object
        let jsonObject = try JSONSerialization.jsonObject(
           with: jsonData,
           options: .allowFragments
        )
        // Verify JSON object can be casted to a Dictionary
        guard let jsonDictionary = jsonObject as? [String: Any] else {
            // Otherwise throw Error
            throw DecodingError.typeMismatch(
                [String: Any].self,
                .init(
                    codingPath: .init(),
                    debugDescription: "Malformed JSON object"
                )
            )
        }
        // Return JSON Dictionary
        return jsonDictionary
    }
    
}

// MARK: - Dictionary+JSON

private extension Dictionary {
    
    /// Make JSON String
    func json() throws -> String {
        .init(
            decoding: try JSONSerialization.data(
                withJSONObject: self,
                options: .init()
            ),
            as: UTF8.self
        )
    }
    
}
