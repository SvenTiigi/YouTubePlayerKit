import Combine
import Foundation

// MARK: - YouTubePlayerPlaybackAPI+currentTimePublisher

public extension YouTubePlayerPlaybackAPI where Self: YouTubePlayerEventAPI {
    
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
    
}

// MARK: - YouTubePlayerPlaybackAPI+videoLoadedFractionPublisher

public extension YouTubePlayerPlaybackAPI where Self: YouTubePlayerEventAPI {
    
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
    
}

// MARK: - YouTubePlayerPlaybackAPI+playbackMetadataPublisher

public extension YouTubePlayerPlaybackAPI where Self: YouTubePlayerEventAPI {
    
    /// A Publisher that emits the current PlaybackMetadata
    var playbackMetadataPublisher: AnyPublisher<YouTubePlayer.PlaybackMetadata, Never> {
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

// MARK: - YouTubePlayerVideoInformationAPI+durationPublisher

public extension YouTubePlayerVideoInformationAPI where Self: YouTubePlayerEventAPI {
    
    /// A Publisher that emits the duration in seconds of the currently playing video
    var durationPublisher: AnyPublisher<Double, Never> {
        self.playbackStatePublisher
            .filter { $0 == .playing }
            .flatMap { _ in
                Future { [weak self] promise in
                    self?.getDuration { result in
                        guard case .success(let duration) = result else {
                            return
                        }
                        promise(.success(duration))
                    }
                }
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
}
