import Combine
import Foundation

/// The YouTubePlayer Playback API
/// - Read more: https://developers.google.com/youtube/iframe_api_reference#Playback_status
public extension YouTubePlayer {
    
    /// Retrieve a number between 0 and 1 that specifies the percentage of the video that the player shows as buffered
    /// - Parameter completion: The completion closure
    func getVideoLoadedFraction(
        completion: @escaping (Result<Double, APIError>) -> Void
    ) {
        self.webView.evaluate(
            javaScript: .player(function: "getVideoLoadedFraction"),
            converter: .typeCast(),
            completion: completion
        )
    }
    
    #if compiler(>=5.5) && canImport(_Concurrency)
    /// Returns a number between 0 and 1 that specifies the percentage of the video that the player shows as buffered
    func getVideoLoadedFraction() async throws -> Double {
        try await withCheckedThrowingContinuation { continuation in
            self.getVideoLoadedFraction(completion: continuation.resume)
        }
    }
    #endif
    
    /// A Publisher that emits a number between 0 and 1 that specifies
    /// the percentage of the video that the player shows as buffered
    /// - Parameter updateInterval: The update TimeInterval in seconds to retrieve the percentage that the player shows as buffered. Default value `0.5`
    func videoLoadedFractionPublisher(
        updateInterval: TimeInterval = 0.5
    ) -> AnyPublisher<Double, Never> {
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
        .flatMap { _ in
            self.playbackStatePublisher
                .filter { $0 == .playing }
                .removeDuplicates()
        }
        .flatMap { _ in
            Future { [weak self] promise in
                self?.getVideoLoadedFraction { result in
                    guard case .success(let fraction) = result else {
                        return
                    }
                    promise(.success(fraction))
                }
            }
        }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }
    
    /// Retrieve the PlaybackState of the player video
    /// - Parameter completion: The completion closure
    func getPlaybackState(
        completion: @escaping (Result<PlaybackState, APIError>) -> Void
    ) {
        self.webView.evaluate(
            javaScript: .player(function: "getPlayerState"),
            converter: .typeCast(
                to: Int.self
            )
            .rawRepresentable(),
            completion: completion
        )
    }
    
    #if compiler(>=5.5) && canImport(_Concurrency)
    /// Returns the PlaybackState of the player video
    func getPlaybackState() async throws -> PlaybackState {
        try await withCheckedThrowingContinuation { continuation in
            self.getPlaybackState(completion: continuation.resume)
        }
    }
    #endif
    
    /// Retrieve the elapsed time in seconds since the video started playing
    /// - Parameter completion: The completion closure
    func getCurrentTime(
        completion: @escaping (Result<Double, APIError>) -> Void
    ) {
        self.webView.evaluate(
            javaScript: .player(function: "getCurrentTime"),
            converter: .typeCast(),
            completion: completion
        )
    }
    
    #if compiler(>=5.5) && canImport(_Concurrency)
    /// Returns the elapsed time in seconds since the video started playing
    func getCurrentTime() async throws -> Double {
        try await withCheckedThrowingContinuation { continuation in
            self.getCurrentTime(completion: continuation.resume)
        }
    }
    #endif
    
    /// A Publisher that emits the current elapsed time in seconds since the video started playing
    /// - Parameter updateInterval: The update TimeInterval in seconds to retrieve the current elapsed time. Default value `0.5`
    func currentTimePublisher(
        updateInterval: TimeInterval = 0.5
    ) -> AnyPublisher<Double, Never> {
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
        .flatMap { _ in
            self.playbackStatePublisher
                .filter { $0 == .playing }
                .removeDuplicates()
        }
        .flatMap { _ in
            Future { [weak self] promise in
                self?.getCurrentTime { result in
                    guard case .success(let currentTime) = result else {
                        return
                    }
                    promise(.success(currentTime))
                }
            }
        }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }
    
    /// Retrieve the current PlaybackMetadata
    /// - Parameter completion: The completion closure
    func getPlaybackMetadata(
        completion: @escaping (Result<PlaybackMetadata, APIError>) -> Void
    ) {
        self.webView.evaluate(
            javaScript: .player(function: "getVideoData"),
            converter: .typeCast(
                to: [String: Any].self
            )
            .decode(),
            completion: completion
        )
    }
    
    #if compiler(>=5.5) && canImport(_Concurrency)
    /// Returns the current PlaybackMetadata
    func getPlaybackMetadata() async throws -> PlaybackMetadata {
        try await withCheckedThrowingContinuation { continuation in
            self.getPlaybackMetadata(completion: continuation.resume)
        }
    }
    #endif
    
    /// A Publisher that emits the current PlaybackMetadata
    var playbackMetadataPublisher: AnyPublisher<PlaybackMetadata, Never> {
        self.playbackStatePublisher
            .filter { $0 == .playing }
            .flatMap { _ in
                Future { [weak self] promise in
                    self?.getPlaybackMetadata { result in
                        guard case .success(let playbackMetadata) = result else {
                            return
                        }
                        promise(.success(playbackMetadata))
                    }
                }
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
}
