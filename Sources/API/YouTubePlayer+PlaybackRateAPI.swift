import Foundation

// MARK: - Playback Rate (https://developers.google.com/youtube/iframe_api_reference#Playback_rate)

public extension YouTubePlayer {
    
    /// This function retrieves the playback rate of the currently playing video.
    func getPlaybackRate() async throws(APIError) -> PlaybackRate {
        try await self.evaluate(
            javaScript: .youTubePlayer(
                functionName: "getPlaybackRate"
            ),
            converter: .typeCast(
                to: Double.self
            )
            .map(PlaybackRate.init(value:))
        )
    }
    
    /// This function sets the suggested playback rate for the current video.
    /// - Parameters:
    ///   - playbackRate: The playback rate
    func set(
        playbackRate: PlaybackRate
    ) async throws(APIError) {
        try await self.evaluate(
            javaScript: .youTubePlayer(
                functionName: "setPlaybackRate",
                parameters: [
                    playbackRate.value
                ]
            )
        )
    }
    
    /// This function returns the set of playback rates in which the current video is available.
    func getAvailablePlaybackRates() async throws(APIError) -> [PlaybackRate] {
        try await self.evaluate(
            javaScript: .youTubePlayer(
                functionName: "getAvailablePlaybackRates"
            ),
            converter: .typeCast(
                to: [Double].self
            )
            .map { playbackRateValues in
                playbackRateValues.map(PlaybackRate.init(value:))
            }
        )
    }
    
}
