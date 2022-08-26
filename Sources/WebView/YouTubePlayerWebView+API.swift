import Combine
import Foundation
import WebKit

// MARK: - YouTubePlayerConfigurationAPI

extension YouTubePlayerWebView: YouTubePlayerConfigurationAPI {
    
    /// Update YouTubePlayer Configuration
    /// - Note: Updating the Configuration will result in a reload of the entire YouTubePlayer
    /// - Parameter configuration: The YouTubePlayer Configuration
    func update(
        configuration: YouTubePlayer.Configuration
    ) {
        // Stop Player
        self.stop()
        // Destroy Player
        self.evaluate(
            javaScript: "player.destroy();",
            converter: .empty
        ) { [weak self] _ in
            // Update YouTubePlayer Configuration
            self?.player.configuration = configuration
            // Re-Load Player
            self?.loadPlayer()
        }
    }
    
}

// MARK: - YouTubePlayerQueueingAPI

extension YouTubePlayerWebView: YouTubePlayerQueueingAPI {
    
    /// Load YouTubePlayer Source
    /// - Parameter source: The YouTubePlayer Source to load
    func load(
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
    func cue(
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
        self.player.source = source
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
        self.evaluate(
            javaScript: "player.\(javaScriptFunctionName)(\(parameterJSONString));"
        )
    }
    
}

// MARK: - YouTubePlayerEventAPI

extension YouTubePlayerWebView: YouTubePlayerEventAPI {
    
    /// The current YouTubePlayer State, if available
    var state: YouTubePlayer.State? {
        self.playerStateSubject.value
    }
    
    /// A Publisher that emits the current YouTubePlayer State
    var statePublisher: AnyPublisher<YouTubePlayer.State, Never> {
        self.playerStateSubject
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    /// The current YouTubePlayer PlaybackState, if available
    var playbackState: YouTubePlayer.PlaybackState? {
        self.playbackStateSubject.value
    }
    
    /// A Publisher that emits the current YouTubePlayer PlaybackState
    var playbackStatePublisher: AnyPublisher<YouTubePlayer.PlaybackState, Never> {
        self.playbackStateSubject
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    /// The current YouTubePlayer PlaybackQuality, if available
    var playbackQuality: YouTubePlayer.PlaybackQuality? {
        self.playbackQualitySubject.value
    }
    
    /// A Publisher that emits the current YouTubePlayer PlaybackQuality
    var playbackQualityPublisher: AnyPublisher<YouTubePlayer.PlaybackQuality, Never> {
        self.playbackQualitySubject
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    /// The current YouTubePlayer PlaybackRate, if available
    var playbackRate: YouTubePlayer.PlaybackRate? {
        self.playbackRateSubject.value
    }
    
    /// A Publisher that emits the current YouTubePlayer PlaybackRate
    var playbackRatePublisher: AnyPublisher<YouTubePlayer.PlaybackRate, Never> {
        self.playbackRateSubject
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
}

// MARK: - YouTubePlayerVideoAPI

extension YouTubePlayerWebView: YouTubePlayerVideoAPI {
    
    /// Plays the currently cued/loaded video
    func play() {
        self.evaluate(
            javaScript: "player.playVideo();"
        )
    }
    
    /// Pauses the currently playing video
    func pause() {
        self.evaluate(
            javaScript: "player.pauseVideo();"
        )
    }
    
    /// Stops and cancels loading of the current video
    func stop() {
        self.evaluate(
            javaScript: "player.stopVideo();"
        )
    }
    
    /// Seeks to a specified time in the video
    /// - Parameters:
    ///   - seconds: The seconds parameter identifies the time to which the player should advance
    ///   - allowSeekAhead: Determines whether the player will make a new request to the server
    func seek(
        to seconds: Double,
        allowSeekAhead: Bool
    ) {
        self.evaluate(
            javaScript: "player.seekTo(\(seconds), \(String(allowSeekAhead)));"
        )
    }
    
}

// MARK: - YouTubePlayer360DegreePerspectiveAPI

extension YouTubePlayerWebView: YouTubePlayer360DegreePerspectiveAPI {
    
    /// Retrieves properties that describe the viewer's current perspective
    /// - Parameter completion: The completion closure
    func get360DegreePerspective(
        completion: @escaping (Result<YouTubePlayer.Perspective360Degree, YouTubePlayerAPIError>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getSphericalProperties();",
            converter: JavaScriptEvaluationResponseConverter<YouTubePlayer.Perspective360Degree>
                .typeCast(to: [String: Any].self)
                .decode(),
            completion: completion
        )
    }
    
    /// Sets the video orientation for playback of a 360° video
    /// - Parameter perspective360Degree: The Perspective360Degree
    func set(
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
        self.evaluate(
            javaScript: "player.setSphericalProperties(\(jsonString));"
        )
    }
    
}

// MARK: - YouTubePlayerPlaylistAPI

extension YouTubePlayerWebView: YouTubePlayerPlaylistAPI {
    
    /// This function loads and plays the next video in the playlist
    func nextVideo() {
        self.evaluate(
            javaScript: "player.nextVideo();"
        )
    }
    
    /// This function loads and plays the previous video in the playlist
    func previousVideo() {
        self.evaluate(
            javaScript: "player.previousVideo();"
        )
    }
    
    /// This function loads and plays the specified video in the playlist
    /// - Parameter index: The index of the video that you want to play in the playlist
    func playVideo(
        at index: Int
    ) {
        self.evaluate(
            javaScript: "player.playVideoAt(\(index));"
        )
    }
    
    /// This function indicates whether the video player should continuously play a playlist
    /// or if it should stop playing after the last video in the playlist ends
    /// - Parameter enabled: Bool value if is enabled
    func setLoop(
        enabled: Bool
    ) {
        self.evaluate(
            javaScript: "player.setLoop(\(String(enabled)));"
        )
    }
    
    /// This function indicates whether a playlist's videos should be shuffled
    /// so that they play back in an order different from the one that the playlist creator designated
    /// - Parameter enabled: Bool value if is enabled
    func setShuffle(
        enabled: Bool
    ) {
        self.evaluate(
            javaScript: "player.setShuffle(\(String(enabled)));"
        )
    }
    
    /// Retrieve an array of the video IDs in the playlist as they are currently ordered
    /// - Parameter completion: The completion closure
    func getPlaylist(
        completion: @escaping (Result<[String], YouTubePlayerAPIError>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getPlaylist();",
            converter: .typeCast(),
            completion: completion
        )
    }
    
    /// Retrieve the index of the playlist video that is currently playing.
    /// - Parameter completion: The completion closure
    func getPlaylistIndex(
        completion: @escaping (Result<Int, YouTubePlayerAPIError>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getPlaylistIndex();",
            converter: .typeCast(),
            completion: completion
        )
    }
    
}

// MARK: - YouTubePlayerVolumeAPI

extension YouTubePlayerWebView: YouTubePlayerVolumeAPI {
    
    /// Mutes the player
    func mute() {
        self.evaluate(
            javaScript: "player.mute();"
        )
    }
    
    /// Unmutes the player
    func unmute() {
        self.evaluate(
            javaScript: "player.unMute();"
        )
    }
    
    /// Retrieve a Bool value if the player is muted
    /// - Parameter completion: The completion closure
    func isMuted(
        completion: @escaping (Result<Bool, YouTubePlayerAPIError>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.isMuted();",
            converter: .typeCast(),
            completion: completion
        )
    }
    
    /// Retrieve the player's current volume, an integer between 0 and 100
    /// - Parameter completion: The completion closure
    func getVolume(
        completion: @escaping (Result<Int, YouTubePlayerAPIError>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getVolume();",
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
    func set(
        volume: Int
    ) {
        #if DEBUG
        print(
            "[YouTubePlayerKit] Setting the volume will have no effect on the actual volume of the device."
        )
        #endif
        let volume = max(0, min(volume, 100))
        self.evaluate(
            javaScript: "player.setVolume(\(volume));"
        )
    }
    
}

// MARK: - YouTubePlayerPlaybackRateAPI

extension YouTubePlayerWebView: YouTubePlayerPlaybackRateAPI {
    
    /// This function retrieves the playback rate of the currently playing video
    /// - Parameter completion: The completion closure
    func getPlaybackRate(
        completion: @escaping (Result<YouTubePlayer.PlaybackRate, YouTubePlayerAPIError>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getPlaybackRate();",
            converter: .typeCast(),
            completion: completion
        )
    }
    
    /// This function sets the suggested playback rate for the current video
    /// - Parameter playbackRate: The playback rate
    func set(
        playbackRate: YouTubePlayer.PlaybackRate
    ) {
        self.evaluate(
            javaScript: "player.setPlaybackRate(\(playbackRate));"
        )
    }
    
    /// Retrieve the set of playback rates in which the current video is available
    /// - Parameter completion: The completion closure
    func getAvailablePlaybackRates(
        completion: @escaping (Result<[YouTubePlayer.PlaybackRate], YouTubePlayerAPIError>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getAvailablePlaybackRates();",
            converter: .typeCast(),
            completion: completion
        )
    }
    
}

// MARK: - YouTubePlayerPlaybackAPI

extension YouTubePlayerWebView: YouTubePlayerPlaybackAPI {
    
    /// Retrieve a number between 0 and 1 that specifies the percentage of the video that the player shows as buffered
    /// - Parameter completion: The completion closure
    func getVideoLoadedFraction(
        completion: @escaping (Result<Double, YouTubePlayerAPIError>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getVideoLoadedFraction();",
            converter: .typeCast(),
            completion: completion
        )
    }
    
    /// Retrieve the PlaybackState of the player video
    /// - Parameter completion: The completion closure
    func getPlaybackState(
        completion: @escaping (Result<YouTubePlayer.PlaybackState, YouTubePlayerAPIError>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getPlayerState();",
            converter: JavaScriptEvaluationResponseConverter<YouTubePlayer.PlaybackState>
                .typeCast(to: Int.self)
                .rawRepresentable(),
            completion: completion
        )
    }
    
    /// Retrieve the elapsed time in seconds since the video started playing
    /// - Parameter completion: The completion closure
    func getCurrentTime(
        completion: @escaping (Result<Double, YouTubePlayerAPIError>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getCurrentTime();",
            converter: .typeCast(),
            completion: completion
        )
    }
    
    /// Retrieve the current PlaybackMetadata
    /// - Parameter completion: The completion closure
    func getPlaybackMetadata(
        completion: @escaping (Result<YouTubePlayer.PlaybackMetadata, YouTubePlayerAPIError>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getVideoData();",
            converter: JavaScriptEvaluationResponseConverter<YouTubePlayer.PlaybackMetadata>
                .typeCast(to: [String: Any].self)
                .decode(),
            completion: completion
        )
    }
    
}

// MARK: - YouTubePlayerVideoInformationAPI

extension YouTubePlayerWebView: YouTubePlayerVideoInformationAPI {
    
    /// Show Stats for Nerds which displays additional video information
    func showStatsForNerds() {
        self.evaluate(
            javaScript: "player.showVideoInfo();"
        )
    }
    
    /// Hide Stats for Nerds
    func hideStatsForNerds() {
        self.evaluate(
            javaScript: "player.hideVideoInfo();"
        )
    }
    
    /// Retrieve the YouTubePlayer Information
    /// - Parameter completion: The completion closure
    func getInformation(
        completion: @escaping (Result<YouTubePlayer.Information, YouTubePlayerAPIError>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.playerInfo;",
            converter: JavaScriptEvaluationResponseConverter<YouTubePlayer.PlaybackMetadata>
                .typeCast(to: [String: Any].self)
                .decode(),
            completion: completion
        )
    }
    
    /// Retrieve the duration in seconds of the currently playing video
    /// - Parameter completion: The completion closure
    func getDuration(
        completion: @escaping (Result<Double, YouTubePlayerAPIError>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getDuration();",
            converter: .typeCast(),
            completion: completion
        )
    }
    
    /// Retrieve the YouTube.com URL for the currently loaded/playing video
    /// - Parameter completion: The completion closure
    func getVideoURL(
        completion: @escaping (Result<String, YouTubePlayerAPIError>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getVideoUrl();",
            converter: .typeCast(),
            completion: completion
        )
    }
    
    /// Retrieve the embed code for the currently loaded/playing video
    /// - Parameter completion: The completion closure
    func getVideoEmbedCode(
        completion: @escaping (Result<String, YouTubePlayerAPIError>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getVideoEmbedCode();",
            converter: .typeCast(),
            completion: completion
        )
    }
    
}
