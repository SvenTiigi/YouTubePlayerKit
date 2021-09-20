import Combine
import Foundation

// MARK: - YouTubePlayer

/// A YouTubePlayer
public final class YouTubePlayer: ObservableObject {
    
    // MARK: Properties
    
    /// The optional YouTubePlayer Source
    public let source: Source?
    
    /// The YouTubePlayer Configuration
    public let configuration: Configuration
    
    /// The  YouTubePlayerAPI
    weak var api: YouTubePlayerAPI? {
        didSet {
            self.objectWillChange.send()
        }
    }
    
    // MARK: Initializer
    
    /// Creates a new instance of `YouTubePlayer`
    /// - Parameters:
    ///   - source: The optional YouTubePlayer Source. Default value `nil`
    ///   - configuration: The YouTubePlayer Configuration. Default value `.init()`
    public init(
        source: Source? = nil,
        configuration: Configuration = .init()
    ) {
        self.source = source
        self.configuration = configuration
    }
    
}

// MARK: - ExpressibleByStringLiteral

extension YouTubePlayer: ExpressibleByStringLiteral {
    
    /// Creates an instance initialized to the given string value.
    /// - Parameter value: The value of the new instance
    public convenience init(
        stringLiteral value: String
    ) {
        self.init(
            source: .url(value)
        )
    }
    
}

// MARK: - Equatable

extension YouTubePlayer: Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (
        lhs: YouTubePlayer,
        rhs: YouTubePlayer
    ) -> Bool {
        lhs.source == rhs.source
            && lhs.configuration == rhs.configuration
    }

}

// MARK: - YouTubePlayerEventAPI

extension YouTubePlayer: YouTubePlayerEventAPI {
    
    /// A Publisher that emits the current YouTubePlayer State
    public var statePublisher: AnyPublisher<State, Never> {
        self.objectWillChange
            .flatMap { [weak self] in
                self?.api?.statePublisher
                    ?? Empty().eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    /// A Publisher that emits the current YouTubePlayer VideoState
    public var videoStatePublisher: AnyPublisher<VideoState, Never> {
        self.objectWillChange
            .flatMap { [weak self] in
                self?.api?.videoStatePublisher
                    ?? Empty().eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    /// A Publisher that emits the current YouTubePlayer PlaybackQuality
    public var playbackQualityPublisher: AnyPublisher<PlaybackQuality, Never> {
        self.objectWillChange
            .flatMap { [weak self] in
                self?.api?.playbackQualityPublisher
                    ?? Empty().eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    /// A Publisher that emits the current YouTubePlayer PlaybackRate
    public var playbackRatePublisher: AnyPublisher<PlaybackRate, Never> {
        self.objectWillChange
            .flatMap { [weak self] in
                self?.api?.playbackRatePublisher
                    ?? Empty().eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
}

// MARK: - YouTubePlayerVideoAPI

extension YouTubePlayer: YouTubePlayerVideoAPI {
    
    /// Load YouTubePlayer Source
    /// - Parameter source: The YouTubePlayer Source to load
    public func load(
        source: YouTubePlayer.Source
    ) {
        self.api?.load(source: source)
    }
    
    /// Plays the currently cued/loaded video
    public func play() {
        self.api?.play()
    }
    
    /// Pauses the currently playing video
    public func pause() {
        self.api?.pause()
    }
    
    /// Stops and cancels loading of the current video
    public func stop() {
        self.api?.stop()
    }
    
    /// Seeks to a specified time in the video
    /// - Parameters:
    ///   - seconds: The seconds parameter identifies the time to which the player should advance
    ///   - allowSeekAhead: Determines whether the player will make a new request to the server
    public func seek(
        to seconds: Double,
        allowSeekAhead: Bool
    ) {
        self.api?.stop()
    }
    
}

// MARK: - YouTubePlayer360DegreePerspectiveAPI

extension YouTubePlayer: YouTubePlayer360DegreePerspectiveAPI {
    
    /// Retrieves properties that describe the viewer's current perspective
    /// - Parameter completion: The completion closure
    public func get360DegreePerspective(
        completion: @escaping (Result<Perspective360Degree, Swift.Error>) -> Void
    ) {
        self.api?.get360DegreePerspective(completion: completion)
    }
    
    /// Sets the video orientation for playback of a 360° video
    /// - Parameter perspective360Degree: The Perspective360Degree
    public func set(
        perspective360Degree: Perspective360Degree
    ) {
        self.api?.set(perspective360Degree: perspective360Degree)
    }
    
}

// MARK: - YouTubePlayerPlaylistAPI

extension YouTubePlayer: YouTubePlayerPlaylistAPI {
    
    /// This function loads and plays the next video in the playlist
    public func nextVideo() {
        self.api?.nextVideo()
    }
    
    /// This function loads and plays the previous video in the playlist
    public func previousVideo() {
        self.api?.previousVideo()
    }
    
    /// This function loads and plays the specified video in the playlist
    /// - Parameter index: The index of the video that you want to play in the playlist
    public func playVideo(
        at index: UInt
    ) {
        self.api?.playVideo(at: index)
    }
    
    /// This function indicates whether the video player should continuously play a playlist
    /// or if it should stop playing after the last video in the playlist ends
    /// - Parameter enabled: Bool value if is enabled
    public func setLoop(
        enabled: Bool
    ) {
        self.api?.setLoop(enabled: enabled)
    }
    
    /// This function indicates whether a playlist's videos should be shuffled
    /// so that they play back in an order different from the one that the playlist creator designated
    /// - Parameter enabled: Bool value if is enabled
    public func setShuffle(
        enabled: Bool
    ) {
        self.api?.setShuffle(enabled: enabled)
    }
    
    /// This function returns an array of the video IDs in the playlist as they are currently ordered
    /// - Parameter completion: The completion closure
    public func getPlaylist(
        completion: @escaping (Result<[String], Swift.Error>) -> Void
    ) {
        self.api?.getPlaylist(completion: completion)
    }
    
    /// This function returns the index of the playlist video that is currently playing.
    /// - Parameter completion: The completion closure
    public func getPlayistIndex(
        completion: @escaping (Result<UInt, Swift.Error>) -> Void
    ) {
        self.api?.getPlayistIndex(completion: completion)
    }
    
}

// MARK: - YouTubePlayerVolumeAPI

extension YouTubePlayer: YouTubePlayerVolumeAPI {
    
    /// Mutes the player
    public func mute() {
        self.api?.mute()
    }
    
    /// Unmutes the player
    public func unmute() {
        self.api?.unmute()
    }
    
    /// Returns Bool value if the player is muted
    /// - Parameter completion: The completion closure
    public func isMuted(
        completion: @escaping (Result<Bool, Swift.Error>) -> Void
    ) {
        self.api?.isMuted(completion: completion)
    }
    
    /// Returns the player's current volume, an integer between 0 and 100
    /// - Parameter completion: The completion closure
    public func getVolume(
        completion: @escaping (Result<UInt, Swift.Error>) -> Void
    ) {
        self.api?.getVolume(completion: completion)
    }
    
    /// Sets the volume.
    /// Accepts an integer between 0 and 100
    /// - Parameter volume: The volume
    public func set(
        volume: UInt
    ) {
        self.api?.set(volume: volume)
    }
    
}

// MARK: - YouTubePlayerPlaybackRateAPI

extension YouTubePlayer: YouTubePlayerPlaybackRateAPI {
    
    /// This function retrieves the playback rate of the currently playing video
    /// - Parameter completion: The completion closure
    public func getPlaybackRate(
        completion: @escaping (Result<PlaybackRate, Swift.Error>) -> Void
    ) {
        self.api?.getPlaybackRate(completion: completion)
    }
    
    /// This function sets the suggested playback rate for the current video
    /// - Parameter playbackRate: The playback rate
    public func set(
        playbackRate: PlaybackRate
    ) {
        self.api?.set(playbackRate: playbackRate)
    }
    
    /// This function returns the set of playback rates in which the current video is available
    /// - Parameter completion: The completion closure
    public func getAvailablePlaybackRates(
        completion: @escaping (Result<[PlaybackRate], Swift.Error>) -> Void
    ) {
        self.api?.getAvailablePlaybackRates(completion: completion)
    }
    
}

// MARK: - YouTubePlayerPlaybackAPI

extension YouTubePlayer: YouTubePlayerPlaybackAPI {
    
    /// Returns a number between 0 and 1 that specifies the percentage of the video that the player shows as buffered
    /// - Parameter completion: The completion closure
    public func getVideoLoadedFraction(
        completion: @escaping (Result<Double, Swift.Error>) -> Void
    ) {
        self.api?.getVideoLoadedFraction(completion: completion)
    }
    
    /// Returns the state of the player video
    /// - Parameter completion: The completion closure
    public func getVideoState(
        completion: @escaping (Result<VideoState, Swift.Error>) -> Void
    ) {
        self.api?.getVideoState(completion: completion)
    }
    
    /// Returns the elapsed time in seconds since the video started playing
    /// - Parameter completion: The completion closure
    public func getCurrentTime(
        completion: @escaping (Result<UInt, Swift.Error>) -> Void
    ) {
        self.api?.getCurrentTime(completion: completion)
    }
    
}

// MARK: - YouTubePlayerVideoInformationAPI

extension YouTubePlayer: YouTubePlayerVideoInformationAPI {
    
    /// Returns the duration in seconds of the currently playing video
    /// - Parameter completion: The completion closure
    public func getDuration(
        completion: @escaping (Result<UInt, Swift.Error>) -> Void
    ) {
        self.api?.getDuration(completion: completion)
    }
    
    /// Returns the YouTube.com URL for the currently loaded/playing video
    /// - Parameter completion: The completion closure
    public func getVideoURL(
        completion: @escaping (Result<String, Swift.Error>) -> Void
    ) {
        self.api?.getVideoURL(completion: completion)
    }
    
    /// Returns the embed code for the currently loaded/playing video
    /// - Parameter completion: The completion closure
    public func getVideoEmbedCode(
        completion: @escaping (Result<String, Swift.Error>) -> Void
    ) {
        self.api?.getVideoEmbedCode(completion: completion)
    }
    
}
