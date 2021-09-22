import Foundation

// MARK: - YouTubePlayer+Options

extension YouTubePlayer {
    
    /// The YouTubePlayer Options
    struct Options: Hashable {
        
        /// The JSON string representation
        let json: String
        
    }
    
}

// MARK: - Options+CodingKeys

private extension YouTubePlayer.Options {
    
    /// The CodingKeys
    enum CodingKeys: String {
        case width
        case height
        case events
        case videoId
        case playerVars
    }
    
}

// MARK: - Options+init

extension YouTubePlayer.Options {
    
    /// Creates a new instance of `YouTubePlayer.Options`
    /// - Parameters:
    ///   - player: The YouTubePlayer
    ///   - originURL: The optional origin URL
    /// - Throws: If Options failed to construct
    init(
        player: YouTubePlayer,
        originURL: URL?
    ) throws {
        // Retrieve Player Configuration as JSON
        var playerConfiguration = try player.configuration.json()
        // Initialize Configuration
        var configuration: [String: Any] = [
            CodingKeys.width.rawValue: "100%",
            CodingKeys.height.rawValue: "100%",
            CodingKeys.events.rawValue: YouTubePlayer.JavaScriptEvent.supportedEvents
        ]
        // Switch on Source
        switch player.source {
        case .video(let id, let startSeconds, _):
            // Set video id
            configuration[CodingKeys.videoId.rawValue] = id
            // Check if a start seconds are available
            if let startSeconds = startSeconds {
                // Set start time on player configuration
                playerConfiguration[
                    YouTubePlayer.Configuration.CodingKeys.startTime.rawValue
                ] = startSeconds
            }
        case .playlist(let id, _, _):
            // Set playlist
            playerConfiguration[
                YouTubePlayer.Configuration.CodingKeys.listType.rawValue
            ] = YouTubePlayer.Configuration.ListType.playlist.rawValue
            // Set playlist id
            playerConfiguration[
                YouTubePlayer.Configuration.CodingKeys.list.rawValue
            ] = id
        case .channel(let name, _, _):
            // Set user uploads
            playerConfiguration[
                YouTubePlayer.Configuration.CodingKeys.listType.rawValue
            ] = YouTubePlayer.Configuration.ListType.userUploads.rawValue
            // Set channel id
            playerConfiguration[
                YouTubePlayer.Configuration.CodingKeys.list.rawValue
            ] = name
        case nil:
            // Simply do nothing
            break
        }
        // Check if an origin URL is available
        if let originURL = originURL {
            // Set origin URL
            playerConfiguration[
                YouTubePlayer.Configuration.CodingKeys.origin.rawValue
            ] = originURL.absoluteString
        }
        // Set Player Configuration
        configuration[CodingKeys.playerVars.rawValue] = playerConfiguration
        // Make JSON string from Configuration
        self.json = try configuration.json()
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
