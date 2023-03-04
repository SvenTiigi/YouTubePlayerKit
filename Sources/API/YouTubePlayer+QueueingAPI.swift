import Foundation

/// The YouTubePlayer Queueing API
/// - Read more: https://developers.google.com/youtube/iframe_api_reference#Queueing_Functions
public extension YouTubePlayer {
    
    /// Load YouTubePlayer Source
    /// - Parameter source: The YouTubePlayer Source to load
    func load(
        source: Source?
    ) {
        // Verify YouTubePlayer Source is available
        guard let source = source else {
            // Otherwise return out of function
            return
        }
        // Update Source
        self.update(
            source: source,
            javaScriptFunctionName: {
                switch source {
                case .video:
                    return "loadVideoById"
                case .playlist, .channel:
                    return "loadPlaylist"
                }
            }()
        )
    }
    
    /// Cue YouTubePlayer Source
    /// - Parameter source: The YouTubePlayer Source to cue
    func cue(
        source: Source?
    ) {
        // Verify YouTubePlayer Source is available
        guard let source = source else {
            // Otherwise return out of function
            return
        }
        // Update Source
        self.update(
            source: source,
            javaScriptFunctionName: {
                switch source {
                case .video:
                    return "cueVideoById"
                case .playlist, .channel:
                    return "cuePlaylist"
                }
            }()
        )
    }
    
}

// MARK: - Update Source

private extension YouTubePlayer {
    
    /// The LoadVideoById Parameter
    struct LoadVideoByIdParamter: Encodable {
        
        /// The video identifier
        let videoId: String
        
        /// The optional start seconds
        let startSeconds: Int?
        
        /// The optional end seconds
        let endSeconds: Int?
        
    }
    
    /// The LoadPlaylist Parameter
    struct LoadPlaylistParameter: Encodable {
        
        /// The list
        let list: String
        
        /// The ListType
        let listType: Configuration.ListType
        
        /// The optional index
        let index: Int?
        
        /// The optional start seconds
        let startSeconds: Int?
        
    }
    
    /// Update YouTubePlayer Source with a given JavaScript function name
    /// - Parameters:
    ///   - source: The YouTubePlayer Source
    ///   - javaScriptFunctionName: The JavaScript function name
    func update(
        source: Source,
        javaScriptFunctionName: String
    ) {
        // Update YouTubePlayer Source
        self.source = source
        // Initialize parameter
        let parameter: Encodable = {
            switch source {
            case .video(let id, let startSeconds, let endSeconds):
                return LoadVideoByIdParamter(
                    videoId: id,
                    startSeconds: startSeconds,
                    endSeconds: endSeconds
                )
            case .playlist(let id, let index, let startSeconds),
                 .channel(let id, let index, let startSeconds):
                return LoadPlaylistParameter(
                    list: id,
                    listType: {
                        if case .playlist = source {
                            return .playlist
                        } else {
                            return .userUploads
                        }
                    }(),
                    index: index,
                    startSeconds: startSeconds
                )
            }
        }()
        // Verify parameter can be encoded to a JSON string
        guard let parameterJSONString = try? parameter.jsonString() else {
            // Otherwise return out of function
            return
        }
        // Evaluate JavaScript
        self.webView.evaluate(
            javaScript: .player(
                function: javaScriptFunctionName,
                parameters: parameterJSONString
            )
        )
    }
    
}
