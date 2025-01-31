import Combine
import Foundation

// MARK: - Playback API

public extension YouTubePlayer {
    
    /// The current YouTube player playback state, if available.
    var playbackState: PlaybackState? {
        self.playbackStateSubject.value
    }
    
    /// A Boolean value that determines if the player is currently playing.
    var isPlaying: Bool {
        self.playbackState == .playing
    }
    
    /// A Boolean value that determines if the player is currently paused.
    var isPaused: Bool {
        self.playbackState == .paused
    }
    
    /// A Boolean value that determines if the player is currently buffering.
    var isBuffering: Bool {
        self.playbackState == .buffering
    }
    
    /// A Boolean value that determines if the player is currently cued.
    var isCued: Bool {
        self.playbackState == .cued
    }
    
    /// A Boolean value that determines if the player is ended.
    var isEnded: Bool {
        self.playbackState == .ended
    }
    
    /// A Publisher that emits the current YouTube player playback state.
    var playbackStatePublisher: some Publisher<PlaybackState, Never> {
        self.playbackStateSubject
            .compactMap { $0 }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
    }
    
    /// The current YouTube player playback quality, if available.
    var playbackQuality: PlaybackQuality? {
        self.playbackQualitySubject.value
    }
    
    /// A Publisher that emits the current YouTube player playback quality.
    var playbackQualityPublisher: some Publisher<PlaybackQuality, Never> {
        self.playbackQualitySubject
            .compactMap { $0 }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
    }
    
    /// Returns a number between 0 and 1 that specifies the percentage of the video that the player shows as buffered.
    func getVideoLoadedFraction() async throws(APIError) -> Double {
        try await self.evaluate(
            javaScript: .youTubePlayer(
                functionName: "getVideoLoadedFraction"
            ),
            converter: .typeCast()
        )
    }
    
    /// A Publisher that emits a number between 0 and 1 that specifies
    /// the percentage of the video that the player shows as buffered.
    /// - Parameter updateInterval: The update TimeInterval in seconds to retrieve the percentage that the player shows as buffered. Default value `0.5`
    func videoLoadedFractionPublisher(
        updateInterval: TimeInterval = 0.5
    ) -> some Publisher<Double, Never> {
        Just(
            .init()
        )
        .append(
            Timer.publish(
                every: updateInterval,
                on: .main,
                in: .common
            )
            .autoconnect()
        )
        .flatMap { [weak self] _ -> AnyPublisher<Double, Never> in
            guard let self else {
                return Empty().eraseToAnyPublisher()
            }
            return self.playbackStatePublisher
                .filter { $0 == .playing }
                .flatMap { _ in
                    Future { promise in
                        Task { [weak self] in
                            guard let videoLoadedFraction = try? await self?.getVideoLoadedFraction() else {
                                return
                            }
                            promise(.success(videoLoadedFraction))
                        }
                    }
                }
                .eraseToAnyPublisher()
        }
        .removeDuplicates()
        .share()
    }
    
    /// Returns the playback state of the player video.
    func getPlaybackState() async throws(APIError) -> PlaybackState {
        .init(
            value: try await self.evaluate(
                javaScript: .youTubePlayer(
                    functionName: "getPlayerState"
                ),
                converter: .typeCast(
                    to: Int.self
                )
            )
        )
    }
    
    /// Returns the elapsed time in seconds since the video started playing.
    func getCurrentTime() async throws(APIError) -> Measurement<UnitDuration> {
        .init(
            value: try await self.evaluate(
                javaScript: .youTubePlayer(
                    functionName: "getCurrentTime"
                ),
                converter: .typeCast(
                    to: Double.self
                )
            ),
            unit: .seconds
        )
    }
    
    /// A Publisher that emits the current elapsed time in seconds since the video started playing.
    /// - Parameter updateInterval: The update TimeInterval in seconds to retrieve the current elapsed time. Default value `0.5`
    func currentTimePublisher(
        updateInterval: TimeInterval = 0.5
    ) -> some Publisher<Measurement<UnitDuration>, Never> {
        Just(
            .init()
        )
        .append(
            Timer.publish(
                every: updateInterval,
                on: .main,
                in: .common
            )
            .autoconnect()
        )
        .flatMap { [weak self] _ -> AnyPublisher<Measurement<UnitDuration>, Never> in
            guard let self else {
                return Empty().eraseToAnyPublisher()
            }
            return self.playbackStatePublisher
                .filter { $0 == .playing }
                .flatMap { _ in
                    Future { promise in
                        Task { [weak self] in
                            guard let currentTime = try? await self?.getCurrentTime() else {
                                return
                            }
                            promise(.success(currentTime))
                        }
                    }
                }
                .eraseToAnyPublisher()
        }
        .removeDuplicates()
        .share()
    }
    
    /// Returns the current playback metadata.
    func getPlaybackMetadata() async throws(APIError) -> PlaybackMetadata {
        try await self.evaluate(
            javaScript: .youTubePlayer(
                functionName: "getVideoData"
            ),
            converter: .typeCast(
                to: [String: Any].self
            )
            .decode(
                decoder: {
                    let jsonDecoder = JSONDecoder()
                    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                    return jsonDecoder
                }()
            )
        )
    }
    
    /// A Publisher that emits the current playback metadata.
    var playbackMetadataPublisher: some Publisher<PlaybackMetadata, Never> {
        self.javaScriptEventPublisher
            .filter { $0.name == .onApiChange }
            .flatMap { _ in
                Future { promise in
                    Task { [weak self] in
                        guard let playbackMetadata = try? await self?.getPlaybackMetadata() else {
                            return
                        }
                        promise(.success(playbackMetadata))
                    }
                }
            }
            .share()
    }
    
}
