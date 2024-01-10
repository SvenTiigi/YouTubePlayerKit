import Foundation

// MARK: - YouTubePlayer+Options

extension YouTubePlayer {
    
    /// The YouTubePlayer Options
    struct Options: Hashable, Sendable {
        
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
    ///   - playerSource: The optional YouTubePlayer Source
    ///   - playerConfiguration: The YouTubePlayer Configuration
    ///   - originURL: The optional origin URL
    /// - Throws: If Options failed to construct
    init(
        playerSource: YouTubePlayer.Source?,
        playerConfiguration: YouTubePlayer.Configuration,
        originURL: URL?
    ) throws {
        // Retrieve Player Configuration as JSON
        var playerConfigurationJSON = try playerConfiguration.json()
        // Initialize Configuration
        var configuration: [String: Any] = [
            CodingKeys.width.rawValue: "100%",
            CodingKeys.height.rawValue: "100%",
            CodingKeys.events.rawValue: YouTubePlayer
                .JavaScriptEvent
                .Name
                .allCases
                .filter { event in
                    // Exclude onIframeAPIReady and onIframeAPIFailedToLoad
                    event != .onIframeAPIReady || event != .onIframeAPIFailedToLoad
                }
                .reduce(
                    into: [String: String]()
                ) { result, event in
                    result[event.rawValue] = event.rawValue
                }
        ]
        // Switch on Source
        switch playerSource {
        case .video(let id, let startSeconds, _):
            // Set video id
            configuration[CodingKeys.videoId.rawValue] = id
            // Check if a start seconds are available
            if let startSeconds = startSeconds {
                // Set start time on player configuration
                playerConfigurationJSON[
                    YouTubePlayer.Configuration.CodingKeys.startTime.rawValue
                ] = startSeconds
            }
            // Check if loop is enabled
            if playerConfiguration.loopEnabled == true {
                // Add playlist parameter with video id
                // as this parameter is required to make looping work
                playerConfigurationJSON[YouTubePlayer.Configuration.ListType.playlist.rawValue] = id
            }
        case .playlist(let id, _, _):
            // Set playlist
            playerConfigurationJSON[
                YouTubePlayer.Configuration.CodingKeys.listType.rawValue
            ] = YouTubePlayer.Configuration.ListType.playlist.rawValue
            // Set playlist id
            playerConfigurationJSON[
                YouTubePlayer.Configuration.CodingKeys.list.rawValue
            ] = id
        case .channel(let name, _, _):
            // Set user uploads
            playerConfigurationJSON[
                YouTubePlayer.Configuration.CodingKeys.listType.rawValue
            ] = YouTubePlayer.Configuration.ListType.userUploads.rawValue
            // Set channel id
            playerConfigurationJSON[
                YouTubePlayer.Configuration.CodingKeys.list.rawValue
            ] = name
        case nil:
            // Simply do nothing
            break
        }
        // Check if an origin URL is available
        // and the player configuration doesn't contain an origin
        if let originURL = originURL,
           playerConfigurationJSON[YouTubePlayer.Configuration.CodingKeys.origin.rawValue] == nil {
            // Set origin URL
            playerConfigurationJSON[
                YouTubePlayer.Configuration.CodingKeys.origin.rawValue
            ] = originURL.absoluteString
        }
        // Set Player Configuration
        configuration[CodingKeys.playerVars.rawValue] = playerConfigurationJSON
        // Make JSON string from Configuration
        self.json = try configuration.jsonString()
    }
    
}
