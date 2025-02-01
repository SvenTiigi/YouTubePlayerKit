import Foundation

// MARK: - Queueing API

public extension YouTubePlayer {
    
    /// Loads a YouTube player source.
    /// - Parameters:
    ///   - source: The new YouTube player source to load.
    ///   - startTime: The start time. Default value `nil`
    ///   - endTime: The end time. Default value `nil`
    ///   - index: The index of a video in a playlist. Default value `nil`
    func load(
        source: Source,
        startTime: Measurement<UnitDuration>? = nil,
        endTime: Measurement<UnitDuration>? = nil,
        index: Int? = nil
    ) async throws(APIError) {
        try await self.update(
            source: source,
            javaScriptFunctionName: {
                switch source {
                case .video:
                    return "loadVideoById"
                case .videos, .playlist, .channel:
                    return "loadPlaylist"
                }
            }(),
            startTime: startTime,
            endTime: endTime,
            index: index
        )
    }
    
    /// Cues a YouTube player source.
    /// - Parameters:
    ///   - source: The new YouTube player source to cue.
    ///   - startTime: The start time. Default value `nil`
    ///   - endTime: The end time. Default value `nil`
    ///   - index: The index of a video in a playlist. Default value `nil`
    func cue(
        source: Source,
        startTime: Measurement<UnitDuration>? = nil,
        endTime: Measurement<UnitDuration>? = nil,
        index: Int? = nil
    ) async throws(APIError) {
        try await self.update(
            source: source,
            javaScriptFunctionName: {
                switch source {
                case .video:
                    return "cueVideoById"
                case .videos, .playlist, .channel:
                    return "cuePlaylist"
                }
            }(),
            startTime: startTime,
            endTime: endTime,
            index: index
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
        let startSeconds: Double?
        
        /// The optional end seconds
        let endSeconds: Double?
        
    }
    
    /// The LoadPlaylist Parameter
    struct LoadPlaylistParameter: Encodable {
        
        /// The list
        let list: String
        
        /// The ListType
        let listType: Parameters.ListType
        
        /// The optional index
        let index: Int?
        
        /// The optional start seconds
        let startSeconds: Double?
        
    }
    
    /// Update YouTubePlayer Source with a given JavaScript function name
    /// - Parameters:
    ///   - source: The YouTubePlayer Source
    ///   - javaScriptFunctionName: The JavaScript function name
    ///   - startTime: The start time. Default value `nil`
    ///   - endTime: The end time. Default value `nil`
    ///   - index: The index of a video in a playlist. Default value `nil`
    func update(
        source: Source,
        javaScriptFunctionName: String,
        startTime: Measurement<UnitDuration>? = nil,
        endTime: Measurement<UnitDuration>? = nil,
        index: Int? = nil
    ) async throws(APIError) {
        let javaScript: JavaScript
        do {
            javaScript = try .youTubePlayer(
                functionName: javaScriptFunctionName,
                jsonParameter: {
                    switch source {
                    case .video(let id):
                        return LoadVideoByIdParamter(
                            videoId: id,
                            startSeconds: startTime?.converted(to: .seconds).value,
                            endSeconds: endTime?.converted(to: .seconds).value
                        )
                    case .videos(let ids):
                        return LoadPlaylistParameter(
                            list: ids.joined(separator: ","),
                            listType: .playlist,
                            index: index,
                            startSeconds: startTime?.converted(to: .seconds).value
                        )
                    case .playlist(let id):
                        return LoadPlaylistParameter(
                            list: id,
                            listType: .playlist,
                            index: index,
                            startSeconds: startTime?.converted(to: .seconds).value
                        )
                    case .channel(let name):
                        return LoadPlaylistParameter(
                            list: name,
                            listType: .channel,
                            index: index,
                            startSeconds: startTime?.converted(to: .seconds).value
                        )
                    }
                }()
            )
        } catch {
            throw .init(
                underlyingError: error,
                reason: "Failed to encode parameter to update the source"
            )
        }
        try await self.evaluate(javaScript: javaScript)
        self.source = source
    }
    
}
