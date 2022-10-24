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
        // Stop Player
        self.stop()
        // Destroy Player
        self.webView.evaluate(
            javaScript: .player("destroy()"),
            converter: .empty
        ) { [weak self] _ in
            // Update YouTubePlayer Configuration
            self?.configuration = configuration
            // Check if PlayerState Subject has a current value
            if self?.playerStateSubject.value != nil {
                // Reset PlayerState Subject current value
                self?.playerStateSubject.send(nil)
            }
            // Check if PlaybackState Subject has a current value
            if self?.playbackStateSubject.value != nil {
                // Reset PlaybackState Subject current value
                self?.playbackStateSubject.send(nil)
            }
            // Check if PlaybackQuality Subject has a current value
            if self?.playbackQualitySubject.value != nil {
                // Reset PlaybackQuality Subject current value
                self?.playbackQualitySubject.send(nil)
            }
            // Check if PlaybackRate Subject has a current value
            if self?.playbackRateSubject.value != nil {
                // Reset PlaybackRate Subject current value
                self?.playbackRateSubject.send(nil)
            }
            // Re-Load Player
            self?.webView.load(using: self!)
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
        // Verify YouTubePlayer Source is available
        guard let source = source else {
            // Otherwise return out of function
            return
        }
        // Update Source
        self.update(
            source: source,
            javaScriptFunctionName: {
                switch source {
                case .video:
                    return "loadVideoById"
                case .playlist, .channel:
                    return "loadPlaylist"
                }
            }()
        )
    }
    
    /// Cue YouTubePlayer Source
    /// - Parameter source: The YouTubePlayer Source to cue
    public func cue(
        source: YouTubePlayer.Source?
    ) {
        // Verify YouTubePlayer Source is available
        guard let source = source else {
            // Otherwise return out of function
            return
        }
        // Update Source
        self.update(
            source: source,
            javaScriptFunctionName: {
                switch source {
                case .video:
                    return "cueVideoById"
                case .playlist, .channel:
                    return "cuePlaylist"
                }
            }()
        )
    }
    
    /// The LoadVideoById Parameter
    private struct LoadVideoByIdParamter: Encodable {
        
        /// The video identifier
        let videoId: String
        
        /// The optional start seconds
        let startSeconds: Int?
        
        /// The optional end seconds
        let endSeconds: Int?
        
    }
    
    /// The LoadPlaylist Parameter
    private struct LoadPlaylistParameter: Encodable {
        
        /// The list
        let list: String
        
        /// The ListType
        let listType: YouTubePlayer.Configuration.ListType
        
        /// The optional index
        let index: Int?
        
        /// The optional start seconds
        let startSeconds: Int?
        
    }
    
    /// Update YouTubePlayer Source with a given JavaScript function name
    /// - Parameters:
    ///   - source: The YouTubePlayer Source
    ///   - javaScriptFunctionName: The JavaScript function name
    private func update(
        source: YouTubePlayer.Source,
        javaScriptFunctionName: String
    ) {
        // Update YouTubePlayer Source
        self.source = source
        // Initialize parameter
        let parameter: Encodable = {
            switch source {
            case .video(let id, let startSeconds, let endSeconds):
                return LoadVideoByIdParamter(
                    videoId: id,
                    startSeconds: startSeconds,
                    endSeconds: endSeconds
                )
            case .playlist(let id, let index, let startSeconds),
                 .channel(let id, let index, let startSeconds):
                return LoadPlaylistParameter(
                    list: id,
                    listType: {
                        if case .playlist = source {
                            return .playlist
                        } else {
                            return .userUploads
                        }
                    }(),
                    index: index,
                    startSeconds: startSeconds
                )
            }
        }()
        // Verify parameter can be encoded to a JSON string
        guard let parameterJSONString = try? parameter.jsonString() else {
            // Otherwise return out of function
            return
        }
        // Evaluate JavaScript
        self.webView.evaluate(
            javaScript: .player("\(javaScriptFunctionName)(\(parameterJSONString))")
        )
    }
    
}

// MARK: - YouTubePlayerEventAPI

extension YouTubePlayer: YouTubePlayerEventAPI {
    
    /// The current YouTubePlayer State, if available
    public var state: YouTubePlayer.State? {
        self.playerStateSubject.value
    }
    
    /// A Publisher that emits the current YouTubePlayer State
    public var statePublisher: AnyPublisher<YouTubePlayer.State, Never> {
        self.playerStateSubject
            .compactMap { $0 }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    /// The current YouTubePlayer PlaybackState, if available
    public var playbackState: YouTubePlayer.PlaybackState? {
        self.playbackStateSubject.value
    }

    /// A Publisher that emits the current YouTubePlayer PlaybackState
    public var playbackStatePublisher: AnyPublisher<YouTubePlayer.PlaybackState, Never> {
        self.playbackStateSubject
            .compactMap { $0 }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    /// The current YouTubePlayer PlaybackQuality, if available
    public var playbackQuality: YouTubePlayer.PlaybackQuality? {
        self.playbackQualitySubject.value
    }
    
    /// A Publisher that emits the current YouTubePlayer PlaybackQuality
    public var playbackQualityPublisher: AnyPublisher<YouTubePlayer.PlaybackQuality, Never> {
        self.playbackQualitySubject
            .compactMap { $0 }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    /// The current YouTubePlayer PlaybackRate, if available
    public var playbackRate: YouTubePlayer.PlaybackRate? {
        self.playbackRateSubject.value
    }
    
    /// A Publisher that emits the current YouTubePlayer PlaybackRate
    public var playbackRatePublisher: AnyPublisher<YouTubePlayer.PlaybackRate, Never> {
        self.playbackRateSubject
            .compactMap { $0 }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
}

// MARK: - YouTubePlayerVideoAPI

extension YouTubePlayer: YouTubePlayerVideoAPI {
    
    /// Plays the currently cued/loaded video
    public func play() {
        self.webView.evaluate(
            javaScript: .player("playVideo()")
        )
    }
    
    /// Pauses the currently playing video
    public func pause() {
        self.webView.evaluate(
            javaScript: .player("pauseVideo()")
        )
    }
    
    /// Stops and cancels loading of the current video
    public func stop() {
        self.webView.evaluate(
            javaScript: .player("stopVideo()")
        )
    }
    
    /// Seeks to a specified time in the video
    /// - Parameters:
    ///   - seconds: The seconds parameter identifies the time to which the player should advance
    ///   - allowSeekAhead: Determines whether the player will make a new request to the server
    public func seek(
        to seconds: Double,
        allowSeekAhead: Bool
    ) {
        self.webView.evaluate(
            javaScript: .player("seekTo(\(seconds), \(String(allowSeekAhead)))")
        )
    }
    
}

// MARK: - YouTubePlayer360DegreePerspectiveAPI

extension YouTubePlayer: YouTubePlayer360DegreePerspectiveAPI {
    
    /// Retrieves properties that describe the viewer's current perspective
    /// - Parameter completion: The completion closure
    public func get360DegreePerspective(
        completion: @escaping (Result<YouTubePlayer.Perspective360Degree, YouTubePlayerAPIError>) -> Void
    ) {
        self.webView.evaluate(
            javaScript: .player("getSphericalProperties()"),
            converter: .typeCast(
                to: [String: Any].self
            )
            .decode(),
            completion: completion
        )
    }
    
    /// Sets the video orientation for playback of a 360° video
    /// - Parameter perspective360Degree: The Perspective360Degree
    public func set(
        perspective360Degree: YouTubePlayer.Perspective360Degree
    ) {
        // Verify YouTubePlayer Perspective360Degree can be decoded
        guard let jsonData = try? JSONEncoder().encode(perspective360Degree) else {
            // Otherwise return out of function
            return
        }
        // Initialize JSON string from data
        let jsonString = String(decoding: jsonData, as: UTF8.self)
        // Evaluate JavaScript
        self.webView.evaluate(
            javaScript: .player("setSphericalProperties(\(jsonString))")
        )
    }
    
}

// MARK: - YouTubePlayerPlaylistAPI

extension YouTubePlayer: YouTubePlayerPlaylistAPI {
    
    /// This function loads and plays the next video in the playlist
    public func nextVideo() {
        self.webView.evaluate(
            javaScript: .player("nextVideo()")
        )
    }
    
    /// This function loads and plays the previous video in the playlist
    public func previousVideo() {
        self.webView.evaluate(
            javaScript: .player("previousVideo()")
        )
    }
    
    /// This function loads and plays the specified video in the playlist
    /// - Parameter index: The index of the video that you want to play in the playlist
    public func playVideo(
        at index: Int
    ) {
        self.webView.evaluate(
            javaScript: .player("playVideoAt(\(index))")
        )
    }
    
    /// This function indicates whether the video player should continuously play a playlist
    /// or if it should stop playing after the last video in the playlist ends
    /// - Parameter enabled: Bool value if is enabled
    public func setLoop(
        enabled: Bool
    ) {
        self.webView.evaluate(
            javaScript: .player("setLoop(\(String(enabled)))")
        )
    }
    
    /// This function indicates whether a playlist's videos should be shuffled
    /// so that they play back in an order different from the one that the playlist creator designated
    /// - Parameter enabled: Bool value if is enabled
    public func setShuffle(
        enabled: Bool
    ) {
        self.webView.evaluate(
            javaScript: .player("setShuffle(\(String(enabled)))")
        )
    }
    
    /// Retrieve an array of the video IDs in the playlist as they are currently ordered
    /// - Parameter completion: The completion closure
    public func getPlaylist(
        completion: @escaping (Result<[String], YouTubePlayerAPIError>) -> Void
    ) {
        self.webView.evaluate(
            javaScript: .player("getPlaylist()"),
            converter: .typeCast(),
            completion: completion
        )
    }
    
    /// Retrieve the index of the playlist video that is currently playing.
    /// - Parameter completion: The completion closure
    public func getPlaylistIndex(
        completion: @escaping (Result<Int, YouTubePlayerAPIError>) -> Void
    ) {
        self.webView.evaluate(
            javaScript: .player("getPlaylistIndex()"),
            converter: .typeCast(),
            completion: completion
        )
    }
    
}

// MARK: - YouTubePlayerVolumeAPI

extension YouTubePlayer: YouTubePlayerVolumeAPI {
    
    /// Mutes the player
    public func mute() {
        self.webView.evaluate(
            javaScript: .player("mute()")
        )
    }
    
    /// Unmutes the player
    public func unmute() {
        self.webView.evaluate(
            javaScript: .player("unMute()")
        )
    }
    
    /// Retrieve the Bool value if the player is muted
    /// - Parameter completion: The completion closure
    public func isMuted(
        completion: @escaping (Result<Bool, YouTubePlayerAPIError>) -> Void
    ) {
        self.webView.evaluate(
            javaScript: .player("isMuted()"),
            converter: .typeCast(),
            completion: completion
        )
    }
    
    /// Retrieve the player's current volume, an integer between 0 and 100
    /// - Parameter completion: The completion closure
    public func getVolume(
        completion: @escaping (Result<Int, YouTubePlayerAPIError>) -> Void
    ) {
        self.webView.evaluate(
            javaScript: .player("getVolume()"),
            converter: .typeCast(),
            completion: completion
        )
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
        #if DEBUG
        print(
            "[YouTubePlayerKit] Setting the volume will have no effect on the actual volume of the device."
        )
        #endif
        let volume = max(0, min(volume, 100))
        self.webView.evaluate(
            javaScript: .player("setVolume(\(volume))")
        )
    }
    
}

// MARK: - YouTubePlayerPlaybackRateAPI

extension YouTubePlayer: YouTubePlayerPlaybackRateAPI {
    
    /// This function retrieves the playback rate of the currently playing video
    /// - Parameter completion: The completion closure
    public func getPlaybackRate(
        completion: @escaping (Result<YouTubePlayer.PlaybackRate, YouTubePlayerAPIError>) -> Void
    ) {
        self.webView.evaluate(
            javaScript: .player("getPlaybackRate()"),
            converter: .typeCast(),
            completion: completion
        )
    }
    
    /// This function sets the suggested playback rate for the current video
    /// - Parameter playbackRate: The playback rate
    public func set(
        playbackRate: YouTubePlayer.PlaybackRate
    ) {
        self.webView.evaluate(
            javaScript: .player("setPlaybackRate(\(playbackRate))")
        )
    }
    
    /// Retrieves the set of playback rates in which the current video is available
    /// - Parameter completion: The completion closure
    public func getAvailablePlaybackRates(
        completion: @escaping (Result<[YouTubePlayer.PlaybackRate], YouTubePlayerAPIError>) -> Void
    ) {
        self.webView.evaluate(
            javaScript: .player("getAvailablePlaybackRates()"),
            converter: .typeCast(),
            completion: completion
        )
    }
    
}

// MARK: - YouTubePlayerPlaybackAPI

extension YouTubePlayer: YouTubePlayerPlaybackAPI {
    
    /// Retrieve a number between 0 and 1 that specifies the percentage of the video that the player shows as buffered
    /// - Parameter completion: The completion closure
    public func getVideoLoadedFraction(
        completion: @escaping (Result<Double, YouTubePlayerAPIError>) -> Void
    ) {
        self.webView.evaluate(
            javaScript: .player("getVideoLoadedFraction()"),
            converter: .typeCast(),
            completion: completion
        )
    }
    
    /// Retrieve the PlaybackState of the player video
    /// - Parameter completion: The completion closure
    public func getPlaybackState(
        completion: @escaping (Result<YouTubePlayer.PlaybackState, YouTubePlayerAPIError>) -> Void
    ) {
        self.webView.evaluate(
            javaScript: .player("getPlayerState()"),
            converter: .typeCast(
                to: Int.self
            )
            .rawRepresentable(),
            completion: completion
        )
    }
    
    /// Retrieve the elapsed time in seconds since the video started playing
    /// - Parameter completion: The completion closure
    public func getCurrentTime(
        completion: @escaping (Result<Double, YouTubePlayerAPIError>) -> Void
    ) {
        self.webView.evaluate(
            javaScript: .player("getCurrentTime()"),
            converter: .typeCast(),
            completion: completion
        )
    }
    
    /// Retrieve the current PlaybackMetadata
    /// - Parameter completion: The completion closure
    public func getPlaybackMetadata(
        completion: @escaping (Result<YouTubePlayer.PlaybackMetadata, YouTubePlayerAPIError>) -> Void
    ) {
        self.webView.evaluate(
            javaScript: .player("getVideoData()"),
            converter: .typeCast(
                to: [String: Any].self
            )
            .decode(),
            completion: completion
        )
    }
    
}

// MARK: - YouTubePlayerVideoInformationAPI

extension YouTubePlayer: YouTubePlayerVideoInformationAPI {
    
    /// Show Stats for Nerds which displays additional video information
    public func showStatsForNerds() {
        self.webView.evaluate(
            javaScript: .player("showVideoInfo()")
        )
    }
    
    /// Hide Stats for Nerds
    public func hideStatsForNerds() {
        self.webView.evaluate(
            javaScript: .player("hideVideoInfo()")
        )
    }
    
    /// Retrieve the YouTubePlayer Information
    /// - Parameter completion: The completion closure
    public func getInformation(
        completion: @escaping (Result<YouTubePlayer.Information, YouTubePlayerAPIError>) -> Void
    ) {
        self.webView.evaluate(
            javaScript: .player("playerInfo"),
            converter: .typeCast(
                to: [String: Any].self
            )
            .decode(),
            completion: completion
        )
    }
    
    /// Retrieve the duration in seconds of the currently playing video
    /// - Parameter completion: The completion closure
    public func getDuration(
        completion: @escaping (Result<Double, YouTubePlayerAPIError>) -> Void
    ) {
        self.webView.evaluate(
            javaScript: .player("getDuration()"),
            converter: .typeCast(),
            completion: completion
        )
    }
    
    /// Retrieve the YouTube.com URL for the currently loaded/playing video
    /// - Parameter completion: The completion closure
    public func getVideoURL(
        completion: @escaping (Result<String, YouTubePlayerAPIError>) -> Void
    ) {
        self.webView.evaluate(
            javaScript: .player("getVideoUrl()"),
            converter: .typeCast(),
            completion: completion
        )
    }
    
    /// Retrieve the embed code for the currently loaded/playing video
    /// - Parameter completion: The completion closure
    public func getVideoEmbedCode(
        completion: @escaping (Result<String, YouTubePlayerAPIError>) -> Void
    ) {
        self.webView.evaluate(
            javaScript: .player("getVideoEmbedCode()"),
            converter: .typeCast(),
            completion: completion
        )
    }
    
}
