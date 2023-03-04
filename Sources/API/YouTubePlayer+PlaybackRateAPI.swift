import Foundation

/// The YouTubePlayer PlaybackRate API
/// - Read more: https://developers.google.com/youtube/iframe_api_reference#Playback_rate
public extension YouTubePlayer {
    
    /// This function retrieves the playback rate of the currently playing video
    /// - Parameter completion: The completion closure
    func getPlaybackRate(
        completion: @escaping (Result<PlaybackRate, APIError>) -> Void
    ) {
        self.webView.evaluate(
            javaScript: .player(function: "getPlaybackRate"),
            converter: .typeCast(),
            completion: completion
        )
    }
    
    #if compiler(>=5.5) && canImport(_Concurrency)
    /// This function retrieves the playback rate of the currently playing video
    func getPlaybackRate() async throws -> PlaybackRate {
        try await withCheckedThrowingContinuation { continuation in
            self.getPlaybackRate(completion: continuation.resume)
        }
    }
    #endif
    
    /// This function sets the suggested playback rate for the current video
    /// - Parameter playbackRate: The playback rate
    func set(
        playbackRate: PlaybackRate
    ) {
        self.webView.evaluate(
            javaScript: .player(
                function: "setPlaybackRate",
                parameters: String(playbackRate)
            )
        )
    }
    
    /// Retrieves the set of playback rates in which the current video is available
    /// - Parameter completion: The completion closure
    func getAvailablePlaybackRates(
        completion: @escaping (Result<[PlaybackRate], APIError>) -> Void
    ) {
        self.webView.evaluate(
            javaScript: .player(function: "getAvailablePlaybackRates"),
            converter: .typeCast(),
            completion: completion
        )
    }
    
    #if compiler(>=5.5) && canImport(_Concurrency)
    /// This function returns the set of playback rates in which the current video is available
    func getAvailablePlaybackRates() async throws -> [PlaybackRate] {
        try await withCheckedThrowingContinuation { continuation in
            self.getAvailablePlaybackRates(completion: continuation.resume)
        }
    }
    #endif
    
}
