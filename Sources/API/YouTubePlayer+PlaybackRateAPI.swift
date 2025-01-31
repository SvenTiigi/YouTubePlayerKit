import Combine
import Foundation

// MARK: - Playback Rate API

public extension YouTubePlayer {
    
    /// The current YouTube player playback rate, if available.
    var playbackRate: PlaybackRate? {
        self.playbackRateSubject.value
    }
    
    /// A Publisher that emits the current YouTube player playback rate.
    var playbackRatePublisher: some Publisher<PlaybackRate, Never> {
        self.playbackRateSubject
            .compactMap { $0 }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
    }
    
    /// This function retrieves the playback rate of the currently playing video.
    func getPlaybackRate() async throws(APIError) -> PlaybackRate {
        .init(
            value: try await self.evaluate(
                javaScript: .youTubePlayer(
                    functionName: "getPlaybackRate"
                ),
                converter: .typeCast(
                    to: Double.self
                )
            )
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
        )
        .map(PlaybackRate.init(value:))
    }
    
}
