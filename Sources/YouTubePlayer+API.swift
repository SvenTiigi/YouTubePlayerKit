import Combine
import Foundation

// MARK: - YouTubePlayerConfigurationAPI

extension YouTubePlayer: YouTubePlayerConfigurationAPI {
    
    /// Update YouTubePlayer Configuration
    /// - Note: Updating the Configuration will result in a reload of the entire YouTubePlayer
    /// - Parameter configuration: The YouTubePlayer Configuration
    public func update(
        configuration: YouTubePlayer.Configuration
    ) {
        self.api?.update(configuration: configuration)
    }
    
}

// MARK: - YouTubePlayerLoadAPI

extension YouTubePlayer: YouTubePlayerLoadAPI {
    
    /// Load YouTubePlayer Source
    /// - Parameter source: The YouTubePlayer Source to load
    public func load(
        source: YouTubePlayer.Source?
    ) {
        self.api?.load(source: source)
    }
    
}

// MARK: - YouTubePlayerEventAPI

extension YouTubePlayer: YouTubePlayerEventAPI {
    
    /// Retrieve Publisher from API by a given KeyPath
    /// - Parameter keyPath: The KeyPath to a Publisher
    private func apiPublisher<P: Publisher>(
        _ keyPath: KeyPath<YouTubePlayerAPI, P>
    ) -> AnyPublisher<P.Output, P.Failure>
    where P.Output: Equatable, P.Failure == Never {
        Deferred {
            Just(self.api)
        }
        .merge(
            with: self.objectWillChange
                .map { [weak self] in
                    self?.api
                }
        )
        .flatMap { api in
            api?[keyPath: keyPath]
                .eraseToAnyPublisher()
                ?? Empty()
                .eraseToAnyPublisher()
        }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }
    
    /// The current YouTubePlayer State, if available
    public var state: YouTubePlayer.State? {
        self.api?.state
    }
    
    /// A Publisher that emits the current YouTubePlayer State
    public var statePublisher: AnyPublisher<YouTubePlayer.State, Never> {
        self.apiPublisher(\.statePublisher)
    }
    
    /// The current YouTubePlayer PlaybackState, if available
    public var playbackState: YouTubePlayer.PlaybackState? {
        self.api?.playbackState
    }

    /// A Publisher that emits the current YouTubePlayer PlaybackState
    public var playbackStatePublisher: AnyPublisher<YouTubePlayer.PlaybackState, Never> {
        self.apiPublisher(\.playbackStatePublisher)
    }
    
    /// The current YouTubePlayer PlaybackQuality, if available
    public var playbackQuality: YouTubePlayer.PlaybackQuality? {
        self.api?.playbackQuality
    }
    
    /// A Publisher that emits the current YouTubePlayer PlaybackQuality
    public var playbackQualityPublisher: AnyPublisher<YouTubePlayer.PlaybackQuality, Never> {
        self.apiPublisher(\.playbackQualityPublisher)
    }
    
    /// The current YouTubePlayer PlaybackRate, if available
    public var playbackRate: YouTubePlayer.PlaybackRate? {
        self.api?.playbackRate
    }
    
    /// A Publisher that emits the current YouTubePlayer PlaybackRate
    public var playbackRatePublisher: AnyPublisher<YouTubePlayer.PlaybackRate, Never> {
        self.apiPublisher(\.playbackRatePublisher)
    }
    
}

// MARK: - YouTubePlayerVideoAPI

extension YouTubePlayer: YouTubePlayerVideoAPI {
    
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
        completion: @escaping (Result<YouTubePlayer.Perspective360Degree, YouTubePlayerAPIError>) -> Void
    ) {
        self.api?.get360DegreePerspective(completion: completion)
    }
    
    /// Sets the video orientation for playback of a 360° video
    /// - Parameter perspective360Degree: The Perspective360Degree
    public func set(
        perspective360Degree: YouTubePlayer.Perspective360Degree
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
        at index: Int
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
        completion: @escaping (Result<[String], YouTubePlayerAPIError>) -> Void
    ) {
        self.api?.getPlaylist(completion: completion)
    }
    
    /// This function returns the index of the playlist video that is currently playing.
    /// - Parameter completion: The completion closure
    public func getPlayistIndex(
        completion: @escaping (Result<Int, YouTubePlayerAPIError>) -> Void
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
        completion: @escaping (Result<Bool, YouTubePlayerAPIError>) -> Void
    ) {
        self.api?.isMuted(completion: completion)
    }
    
    /// Returns the player's current volume, an integer between 0 and 100
    /// - Parameter completion: The completion closure
    public func getVolume(
        completion: @escaping (Result<Int, YouTubePlayerAPIError>) -> Void
    ) {
        self.api?.getVolume(completion: completion)
    }
    
    /// Sets the volume.
    /// Accepts an integer between 0 and 100
    /// - Parameter volume: The volume
    public func set(
        volume: Int
    ) {
        self.api?.set(volume: volume)
    }
    
}

// MARK: - YouTubePlayerPlaybackRateAPI

extension YouTubePlayer: YouTubePlayerPlaybackRateAPI {
    
    /// This function retrieves the playback rate of the currently playing video
    /// - Parameter completion: The completion closure
    public func getPlaybackRate(
        completion: @escaping (Result<YouTubePlayer.PlaybackRate, YouTubePlayerAPIError>) -> Void
    ) {
        self.api?.getPlaybackRate(completion: completion)
    }
    
    /// This function sets the suggested playback rate for the current video
    /// - Parameter playbackRate: The playback rate
    public func set(
        playbackRate: YouTubePlayer.PlaybackRate
    ) {
        self.api?.set(playbackRate: playbackRate)
    }
    
    /// This function returns the set of playback rates in which the current video is available
    /// - Parameter completion: The completion closure
    public func getAvailablePlaybackRates(
        completion: @escaping (Result<[YouTubePlayer.PlaybackRate], YouTubePlayerAPIError>) -> Void
    ) {
        self.api?.getAvailablePlaybackRates(completion: completion)
    }
    
}

// MARK: - YouTubePlayerPlaybackAPI

extension YouTubePlayer: YouTubePlayerPlaybackAPI {
    
    /// Returns a number between 0 and 1 that specifies the percentage of the video that the player shows as buffered
    /// - Parameter completion: The completion closure
    public func getVideoLoadedFraction(
        completion: @escaping (Result<Double, YouTubePlayerAPIError>) -> Void
    ) {
        self.api?.getVideoLoadedFraction(completion: completion)
    }
    
    /// Returns the PlaybackState of the player video
    /// - Parameter completion: The completion closure
    public func getPlaybackState(
        completion: @escaping (Result<YouTubePlayer.PlaybackState, YouTubePlayerAPIError>) -> Void
    ) {
        self.api?.getPlaybackState(completion: completion)
    }
    
    /// Returns the elapsed time in seconds since the video started playing
    /// - Parameter completion: The completion closure
    public func getCurrentTime(
        completion: @escaping (Result<Int, YouTubePlayerAPIError>) -> Void
    ) {
        self.api?.getCurrentTime(completion: completion)
    }
    
    /// Returns the current PlaybackMetadata
    /// - Parameter completion: The completion closure
    public func getPlaybackMetadata(
        completion: @escaping (Result<YouTubePlayer.PlaybackMetadata, YouTubePlayerAPIError>) -> Void
    ) {
        self.api?.getPlaybackMetadata(completion: completion)
    }
    
}

// MARK: - YouTubePlayerVideoInformationAPI

extension YouTubePlayer: YouTubePlayerVideoInformationAPI {
    
    /// Returns the duration in seconds of the currently playing video
    /// - Parameter completion: The completion closure
    public func getDuration(
        completion: @escaping (Result<Int, YouTubePlayerAPIError>) -> Void
    ) {
        self.api?.getDuration(completion: completion)
    }
    
    /// Returns the YouTube.com URL for the currently loaded/playing video
    /// - Parameter completion: The completion closure
    public func getVideoURL(
        completion: @escaping (Result<String, YouTubePlayerAPIError>) -> Void
    ) {
        self.api?.getVideoURL(completion: completion)
    }
    
    /// Returns the embed code for the currently loaded/playing video
    /// - Parameter completion: The completion closure
    public func getVideoEmbedCode(
        completion: @escaping (Result<String, YouTubePlayerAPIError>) -> Void
    ) {
        self.api?.getVideoEmbedCode(completion: completion)
    }
    
}
