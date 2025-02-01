import Foundation

// MARK: - Playlist API

public extension YouTubePlayer {
    
    /// This function loads and plays the next video in the playlist.
    func nextVideoInPlaylist() async throws(APIError) {
        try await self.evaluate(
            javaScript: .youTubePlayer(
                functionName: "nextVideo"
            )
        )
    }
    
    /// This function loads and plays the previous video in the playlist.
    func previousVideoInPlaylist() async throws(APIError) {
        try await self.evaluate(
            javaScript: .youTubePlayer(
                functionName: "previousVideo"
            )
        )
    }
    
    /// This function loads and plays the specified video in the playlist.
    /// - Parameters:
    ///   - index: The index of the video that you want to play in the playlist.
    func playVideoInPlaylist(
        at index: Int
    ) async throws(APIError) {
        try await self.evaluate(
            javaScript: .youTubePlayer(
                functionName: "playVideoAt",
                parameters: [
                    index
                ]
            )
        )
    }
    
    /// This function indicates whether the video player should continuously play a playlist
    /// or if it should stop playing after the last video in the playlist ends.
    /// - Parameters:
    ///   - enabled: Bool value if is enabled.
    func setLoopPlaylist(
        enabled: Bool
    ) async throws(APIError) {
        try await self.evaluate(
            javaScript: .youTubePlayer(
                functionName: "setLoop",
                parameters: [
                    enabled
                ]
            )
        )
    }
    
    /// This function indicates whether a playlist's videos should be shuffled
    /// so that they play back in an order different from the one that the playlist creator designated.
    /// - Parameters:
    ///   - enabled: Bool value if is enabled.
    func setShufflePlaylist(
        enabled: Bool
    ) async throws(APIError) {
        try await self.evaluate(
            javaScript: .youTubePlayer(
                functionName: "setShuffle",
                parameters: [
                    enabled
                ]
            )
        )
    }
    
    /// This function returns an array of the video IDs in the playlist as they are currently ordered.
    func getPlaylist() async throws(APIError) -> [Source.ID]? {
        try await self.evaluate(
            javaScript: .youTubePlayer(
                functionName: "getPlaylist"
            ),
            converter: .typeCast()
        )
    }
    
    /// This function returns the index of the playlist video that is currently playing.
    func getPlaylistIndex() async throws(APIError) -> Int {
        try await self.evaluate(
            javaScript: .youTubePlayer(
                functionName: "getPlaylistIndex"
            ),
            converter: .typeCast()
        )
    }
    
    /// This function returns the identifier of the playlist video that is currently playing.
    func getPlaylistID() async throws(APIError) -> Source.ID {
        try await self.evaluate(
            javaScript: .youTubePlayer(
                functionName: "getPlaylistId"
            ),
            converter: .typeCast()
        )
    }
    
}
