import Combine
import Foundation

// MARK: - YouTubePlayer+APIPublisher

private extension YouTubePlayer {
    
    /// A Publisher that emits the `YouTubePlayerAPI` retrieved from the `api` property
    func apiPublisher() -> AnyPublisher<YouTubePlayerAPI, Never> {
        Deferred {
            Just(self.api)
        }
        .merge(
            with: self.objectWillChange
                .map { [weak self] in
                    self?.api
                }
        )
        .compactMap { $0 }
        .eraseToAnyPublisher()
    }
    
    /// A Publisher thats emit a Publisher of the `YouTubePlayerAPI` by a given KeyPath
    /// - Parameter keyPath: The KeyPath to a Publisher
    func apiPublisher<P: Publisher>(
        publisher keyPath: KeyPath<YouTubePlayerAPI, P>
    ) -> AnyPublisher<P.Output, P.Failure>
    where P.Output: Equatable, P.Failure == Never {
        self.apiPublisher()
            .flatMap { $0[keyPath: keyPath] }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
}

// MARK: - YouTubePlayer+onAPIReady

private extension YouTubePlayer {
    
    /// This functions invokes the `completion` closure as soon as a `YouTubePlayerAPI`
    /// is available and the `YouTubePlayer.State` is no longer `idle`
    /// - Parameter completion: The completion closure to invoke
    func onAPIReady(
        completion: @escaping (YouTubePlayerAPI) -> Void
    ) {
        self.apiPublisher()
            .zip(
                self.statePublisher
                    .filter { !$0.isIdle }
            )
            .prefix(1)
            .sink { api, _ in
                completion(api)
            }
            .store(in: &self.cancellables)
    }
    
}

// MARK: - YouTubePlayerConfigurationAPI

extension YouTubePlayer: YouTubePlayerConfigurationAPI {
    
    /// Update YouTubePlayer Configuration
    /// - Note: Updating the Configuration will result in a reload of the entire YouTubePlayer
    /// - Parameter configuration: The YouTubePlayer Configuration
    public func update(
        configuration: YouTubePlayer.Configuration
    ) {
        self.onAPIReady { api in
            api.update(configuration: configuration)
        }
    }
    
}

// MARK: - YouTubePlayerQueueingAPI

extension YouTubePlayer: YouTubePlayerQueueingAPI {
    
    /// Load YouTubePlayer Source
    /// - Parameter source: The YouTubePlayer Source to load
    public func load(
        source: YouTubePlayer.Source?
    ) {
        self.onAPIReady { api in
            api.load(source: source)
        }
    }
    
    /// Cue YouTubePlayer Source
    /// - Parameter source: The YouTubePlayer Source to cue
    public func cue(
        source: YouTubePlayer.Source?
    ) {
        self.onAPIReady { api in
            api.cue(source: source)
        }
    }
    
}

// MARK: - YouTubePlayerEventAPI

extension YouTubePlayer: YouTubePlayerEventAPI {
    
    /// The current YouTubePlayer State, if available
    public var state: YouTubePlayer.State? {
        self.api?.state
    }
    
    /// A Publisher that emits the current YouTubePlayer State
    public var statePublisher: AnyPublisher<YouTubePlayer.State, Never> {
        self.apiPublisher(publisher: \.statePublisher)
    }
    
    /// The current YouTubePlayer PlaybackState, if available
    public var playbackState: YouTubePlayer.PlaybackState? {
        self.api?.playbackState
    }

    /// A Publisher that emits the current YouTubePlayer PlaybackState
    public var playbackStatePublisher: AnyPublisher<YouTubePlayer.PlaybackState, Never> {
        self.apiPublisher(publisher: \.playbackStatePublisher)
    }
    
    /// The current YouTubePlayer PlaybackQuality, if available
    public var playbackQuality: YouTubePlayer.PlaybackQuality? {
        self.api?.playbackQuality
    }
    
    /// A Publisher that emits the current YouTubePlayer PlaybackQuality
    public var playbackQualityPublisher: AnyPublisher<YouTubePlayer.PlaybackQuality, Never> {
        self.apiPublisher(publisher: \.playbackQualityPublisher)
    }
    
    /// The current YouTubePlayer PlaybackRate, if available
    public var playbackRate: YouTubePlayer.PlaybackRate? {
        self.api?.playbackRate
    }
    
    /// A Publisher that emits the current YouTubePlayer PlaybackRate
    public var playbackRatePublisher: AnyPublisher<YouTubePlayer.PlaybackRate, Never> {
        self.apiPublisher(publisher: \.playbackRatePublisher)
    }
    
}

// MARK: - YouTubePlayerVideoAPI

extension YouTubePlayer: YouTubePlayerVideoAPI {
    
    /// Plays the currently cued/loaded video
    public func play() {
        self.onAPIReady { api in
            api.play()
        }
    }
    
    /// Pauses the currently playing video
    public func pause() {
        self.onAPIReady { api in
            api.pause()
        }
    }
    
    /// Stops and cancels loading of the current video
    public func stop() {
        self.onAPIReady { api in
            api.stop()
        }
    }
    
    /// Seeks to a specified time in the video
    /// - Parameters:
    ///   - seconds: The seconds parameter identifies the time to which the player should advance
    ///   - allowSeekAhead: Determines whether the player will make a new request to the server
    public func seek(
        to seconds: Double,
        allowSeekAhead: Bool
    ) {
        self.onAPIReady { api in
            api.seek(to: seconds, allowSeekAhead: allowSeekAhead)
        }
    }
    
}

// MARK: - YouTubePlayer360DegreePerspectiveAPI

extension YouTubePlayer: YouTubePlayer360DegreePerspectiveAPI {
    
    /// Retrieves properties that describe the viewer's current perspective
    /// - Parameter completion: The completion closure
    public func get360DegreePerspective(
        completion: @escaping (Result<YouTubePlayer.Perspective360Degree, YouTubePlayerAPIError>) -> Void
    ) {
        self.onAPIReady { api in
            api.get360DegreePerspective(completion: completion)
        }
    }
    
    /// Sets the video orientation for playback of a 360° video
    /// - Parameter perspective360Degree: The Perspective360Degree
    public func set(
        perspective360Degree: YouTubePlayer.Perspective360Degree
    ) {
        self.onAPIReady { api in
            api.set(perspective360Degree: perspective360Degree)
        }
    }
    
}

// MARK: - YouTubePlayerPlaylistAPI

extension YouTubePlayer: YouTubePlayerPlaylistAPI {
    
    /// This function loads and plays the next video in the playlist
    public func nextVideo() {
        self.onAPIReady { api in
            api.nextVideo()
        }
    }
    
    /// This function loads and plays the previous video in the playlist
    public func previousVideo() {
        self.onAPIReady { api in
            api.previousVideo()
        }
    }
    
    /// This function loads and plays the specified video in the playlist
    /// - Parameter index: The index of the video that you want to play in the playlist
    public func playVideo(
        at index: Int
    ) {
        self.onAPIReady { api in
            api.playVideo(at: index)
        }
    }
    
    /// This function indicates whether the video player should continuously play a playlist
    /// or if it should stop playing after the last video in the playlist ends
    /// - Parameter enabled: Bool value if is enabled
    public func setLoop(
        enabled: Bool
    ) {
        self.onAPIReady { api in
            api.setLoop(enabled: enabled)
        }
    }
    
    /// This function indicates whether a playlist's videos should be shuffled
    /// so that they play back in an order different from the one that the playlist creator designated
    /// - Parameter enabled: Bool value if is enabled
    public func setShuffle(
        enabled: Bool
    ) {
        self.onAPIReady { api in
            api.setShuffle(enabled: enabled)
        }
    }
    
    /// Retrieve an array of the video IDs in the playlist as they are currently ordered
    /// - Parameter completion: The completion closure
    public func getPlaylist(
        completion: @escaping (Result<[String], YouTubePlayerAPIError>) -> Void
    ) {
        self.onAPIReady { api in
            api.getPlaylist(completion: completion)
        }
    }
    
    /// Retrieve the index of the playlist video that is currently playing.
    /// - Parameter completion: The completion closure
    public func getPlaylistIndex(
        completion: @escaping (Result<Int, YouTubePlayerAPIError>) -> Void
    ) {
        self.onAPIReady { api in
            api.getPlaylistIndex(completion: completion)
        }
    }
    
}

// MARK: - YouTubePlayerVolumeAPI

extension YouTubePlayer: YouTubePlayerVolumeAPI {
    
    /// Mutes the player
    public func mute() {
        self.onAPIReady { api in
            api.mute()
        }
    }
    
    /// Unmutes the player
    public func unmute() {
        self.onAPIReady { api in
            api.unmute()
        }
    }
    
    /// Retrieve the Bool value if the player is muted
    /// - Parameter completion: The completion closure
    public func isMuted(
        completion: @escaping (Result<Bool, YouTubePlayerAPIError>) -> Void
    ) {
        self.onAPIReady { api in
            api.isMuted(completion: completion)
        }
    }
    
    /// Retrieve the player's current volume, an integer between 0 and 100
    /// - Parameter completion: The completion closure
    public func getVolume(
        completion: @escaping (Result<Int, YouTubePlayerAPIError>) -> Void
    ) {
        self.onAPIReady { api in
            api.getVolume(completion: completion)
        }
    }
    
    /// Sets the volume.
    /// Accepts an integer between 0 and 100
    /// - Note: This function is part of the official YouTube Player iFrame API
    ///  but due to limitations and restrictions of the underlying WKWebView
    ///  the call has no effect on the actual volume of the device
    /// - Parameter volume: The volume
    public func set(
        volume: Int
    ) {
        self.onAPIReady { api in
            api.set(volume: volume)
        }
    }
    
}

// MARK: - YouTubePlayerPlaybackRateAPI

extension YouTubePlayer: YouTubePlayerPlaybackRateAPI {
    
    /// This function retrieves the playback rate of the currently playing video
    /// - Parameter completion: The completion closure
    public func getPlaybackRate(
        completion: @escaping (Result<YouTubePlayer.PlaybackRate, YouTubePlayerAPIError>) -> Void
    ) {
        self.onAPIReady { api in
            api.getPlaybackRate(completion: completion)
        }
    }
    
    /// This function sets the suggested playback rate for the current video
    /// - Parameter playbackRate: The playback rate
    public func set(
        playbackRate: YouTubePlayer.PlaybackRate
    ) {
        self.onAPIReady { api in
            api.set(playbackRate: playbackRate)
        }
    }
    
    /// Retrieves the set of playback rates in which the current video is available
    /// - Parameter completion: The completion closure
    public func getAvailablePlaybackRates(
        completion: @escaping (Result<[YouTubePlayer.PlaybackRate], YouTubePlayerAPIError>) -> Void
    ) {
        self.onAPIReady { api in
            api.getAvailablePlaybackRates(completion: completion)
        }
    }
    
}

// MARK: - YouTubePlayerPlaybackAPI

extension YouTubePlayer: YouTubePlayerPlaybackAPI {
    
    /// Retrieve a number between 0 and 1 that specifies the percentage of the video that the player shows as buffered
    /// - Parameter completion: The completion closure
    public func getVideoLoadedFraction(
        completion: @escaping (Result<Double, YouTubePlayerAPIError>) -> Void
    ) {
        self.onAPIReady { api in
            api.getVideoLoadedFraction(completion: completion)
        }
    }
    
    /// Retrieve the PlaybackState of the player video
    /// - Parameter completion: The completion closure
    public func getPlaybackState(
        completion: @escaping (Result<YouTubePlayer.PlaybackState, YouTubePlayerAPIError>) -> Void
    ) {
        self.onAPIReady { api in
            api.getPlaybackState(completion: completion)
        }
    }
    
    /// Retrieve the elapsed time in seconds since the video started playing
    /// - Parameter completion: The completion closure
    public func getCurrentTime(
        completion: @escaping (Result<Double, YouTubePlayerAPIError>) -> Void
    ) {
        self.onAPIReady { api in
            api.getCurrentTime(completion: completion)
        }
    }
    
    /// Retrieve the current PlaybackMetadata
    /// - Parameter completion: The completion closure
    public func getPlaybackMetadata(
        completion: @escaping (Result<YouTubePlayer.PlaybackMetadata, YouTubePlayerAPIError>) -> Void
    ) {
        self.onAPIReady { api in
            api.getPlaybackMetadata(completion: completion)
        }
    }
    
}

// MARK: - YouTubePlayerVideoInformationAPI

extension YouTubePlayer: YouTubePlayerVideoInformationAPI {
    
    /// Show Stats for Nerds which displays additional video information
    public func showStatsForNerds() {
        self.onAPIReady { api in
            api.showStatsForNerds()
        }
    }
    
    /// Hide Stats for Nerds
    public func hideStatsForNerds() {
        self.onAPIReady { api in
            api.hideStatsForNerds()
        }
    }
    
    /// Retrieve the YouTubePlayer Information
    /// - Parameter completion: The completion closure
    public func getInformation(
        completion: @escaping (Result<YouTubePlayer.Information, YouTubePlayerAPIError>) -> Void
    ) {
        self.onAPIReady { api in
            api.getInformation(completion: completion)
        }
    }
    
    /// Retrieve the duration in seconds of the currently playing video
    /// - Parameter completion: The completion closure
    public func getDuration(
        completion: @escaping (Result<Double, YouTubePlayerAPIError>) -> Void
    ) {
        self.onAPIReady { api in
            api.getDuration(completion: completion)
        }
    }
    
    /// Retrieve the YouTube.com URL for the currently loaded/playing video
    /// - Parameter completion: The completion closure
    public func getVideoURL(
        completion: @escaping (Result<String, YouTubePlayerAPIError>) -> Void
    ) {
        self.onAPIReady { api in
            api.getVideoURL(completion: completion)
        }
    }
    
    /// Retrieve the embed code for the currently loaded/playing video
    /// - Parameter completion: The completion closure
    public func getVideoEmbedCode(
        completion: @escaping (Result<String, YouTubePlayerAPIError>) -> Void
    ) {
        self.onAPIReady { api in
            api.getVideoEmbedCode(completion: completion)
        }
    }
    
}
