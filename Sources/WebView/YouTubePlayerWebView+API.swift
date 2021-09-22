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
        // Destroy Player
        self.destroyPlayer { [weak self] in
            // Update YouTubePlayer Configuration
            self?.player.configuration = configuration
            // Re-Load Player
            self?.loadPlayer()
        }
    }
    
}

// MARK: - YouTubePlayerLoadAPI

extension YouTubePlayerWebView: YouTubePlayerLoadAPI {
    
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
        // Update YouTubePlayer Source
        self.player.source = source
        // Switch on Source
        switch source {
        case .video(let id, let startSeconds, let endSeconds):
            var parameters = ["videoId": "'\(id)'"]
            if let startSeconds = startSeconds {
                parameters["startSeconds"] = .init(startSeconds)
            }
            if let endSeconds = endSeconds {
                parameters["endSeconds"] = .init(endSeconds)
            }
            let parameterObject = parameters
                .map { "\($0): \($1)" }
                .joined(separator: ", ")
            self.evaluate(
                javaScript: "player.loadVideoById({\(parameterObject)});"
            )
        case .playlist(let id, let index, let startSeconds),
             .channel(let id, let index, let startSeconds):
            var parameters: [String: String] = .init()
            parameters["list"] = "'\(id)'"
            parameters["listType"] = {
                if case .playlist = source {
                    return "'playlist'"
                } else {
                    return "'user_uploads'"
                }
            }()
            if let index = index {
                parameters["index"] = .init(index)
            }
            if let startSeconds = startSeconds {
                parameters["startSeconds"] = .init(startSeconds)
            }
            let parameterObject = parameters
                .map { "\($0): \($1)" }
                .joined(separator: ", ")
            self.evaluate(
                javaScript: "player.loadPlaylist({\(parameterObject)});"
            )
        }
    }
    
}

// MARK: - YouTubePlayerEventAPI

extension YouTubePlayerWebView: YouTubePlayerEventAPI {
    
    /// The current YouTubePlayer State, if available
    var state: YouTubePlayer.State? {
        self.stateSubject.value
    }
    
    /// A Publisher that emits the current YouTubePlayer State
    var statePublisher: AnyPublisher<YouTubePlayer.State, Never> {
        self.stateSubject
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    /// The current YouTubePlayer VideoState, if available
    var videoState: YouTubePlayer.VideoState? {
        self.videoStateSubject.value
    }
    
    /// A Publisher that emits the current YouTubePlayer VideoState
    var videoStatePublisher: AnyPublisher<YouTubePlayer.VideoState, Never> {
        self.videoStateSubject
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
            responseType: String.self
        ) { result, javaScript in
            switch result {
            case .success(let string):
                // Declare a YouTubePlayer Perspective360Degree
                let perspective360Degree: YouTubePlayer.Perspective360Degree
                do {
                    // Try to decode JSON object as YouTubePlayer Perspective360Degree
                    perspective360Degree = try JSONDecoder().decode(
                        YouTubePlayer.Perspective360Degree.self,
                        from: .init(string.utf8)
                    )
                } catch {
                    // Complete with failure
                    return completion(
                        .failure(
                            .init(
                                javaScript: javaScript,
                                javaScriptResponse: string,
                                underlyingError: error
                            )
                        )
                    )
                }
                // Complete with success
                completion(.success(perspective360Degree))
            case .failure(let error):
                // Complete with failure
                completion(.failure(error))
            }
        }
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
    
    /// This function returns an array of the video IDs in the playlist as they are currently ordered
    /// - Parameter completion: The completion closure
    func getPlaylist(
        completion: @escaping (Result<[String], YouTubePlayerAPIError>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getPlaylist();",
            responseType: [String].self
        ) { result, _ in
            // Invoke completion
            completion(result)
        }
    }
    
    /// This function returns the index of the playlist video that is currently playing.
    /// - Parameter completion: The completion closure
    func getPlayistIndex(
        completion: @escaping (Result<Int, YouTubePlayerAPIError>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getPlaylistIndex();",
            responseType: Int.self
        ) { result, _ in
            completion(result)
        }
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
    
    /// Returns Bool value if the player is muted
    /// - Parameter completion: The completion closure
    func isMuted(
        completion: @escaping (Result<Bool, YouTubePlayerAPIError>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.isMuted();",
            responseType: Bool.self
        ) { result, _ in
            // Invoke completion
            completion(result)
        }
    }
    
    /// Returns the player's current volume, an integer between 0 and 100
    /// - Parameter completion: The completion closure
    func getVolume(
        completion: @escaping (Result<Int, YouTubePlayerAPIError>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getVolume();",
            responseType: Int.self
        ) { result, _ in
            completion(result)
        }
    }
    
    /// Sets the volume.
    /// Accepts an integer between 0 and 100
    /// - Parameter volume: The volume
    func set(
        volume: Int
    ) {
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
            responseType: Double.self
        ) { result, _ in
            completion(result)
        }
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
    
    /// This function returns the set of playback rates in which the current video is available
    /// - Parameter completion: The completion closure
    func getAvailablePlaybackRates(
        completion: @escaping (Result<[YouTubePlayer.PlaybackRate], YouTubePlayerAPIError>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getAvailablePlaybackRates();",
            responseType: [Double].self
        ) { result, _ in
            completion(result)
        }
    }
    
}

// MARK: - YouTubePlayerPlaybackAPI

extension YouTubePlayerWebView: YouTubePlayerPlaybackAPI {
    
    /// Returns a number between 0 and 1 that specifies the percentage of the video that the player shows as buffered
    /// - Parameter completion: The completion closure
    func getVideoLoadedFraction(
        completion: @escaping (Result<Double, YouTubePlayerAPIError>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getVideoLoadedFraction();",
            responseType: Double.self
        ) { result, _ in
            // Invoke completion
            completion(result)
        }
    }
    
    /// Returns the state of the player video
    /// - Parameter completion: The completion closure
    func getVideoState(
        completion: @escaping (Result<YouTubePlayer.VideoState, YouTubePlayerAPIError>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getPlayerState();",
            responseType: Int.self
        ) { result, javaScript in
            switch result {
            case .success(let value):
                // Verify VideoState enum can be initialized from raw value
                guard let videoState = YouTubePlayer.VideoState(rawValue: value) else {
                    // Otherwise complete with failure
                    return completion(
                        .failure(
                            .init(
                                javaScript: javaScript,
                                javaScriptResponse: value,
                                reason: "Unknown VideoState: \(value)"
                            )
                        )
                    )
                }
                // Complete with success
                completion(.success(videoState))
            case .failure(let error):
                // Complete with failure
                completion(.failure(error))
            }
        }
    }
    
    /// Returns the elapsed time in seconds since the video started playing
    /// - Parameter completion: The completion closure
    func getCurrentTime(
        completion: @escaping (Result<Int, YouTubePlayerAPIError>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getCurrentTime();",
            responseType: Int.self
        ) { result, _ in
            completion(result)
        }
    }
    
}

// MARK: - YouTubePlayerVideoInformationAPI

extension YouTubePlayerWebView: YouTubePlayerVideoInformationAPI {
    
    /// Returns the duration in seconds of the currently playing video
    /// - Parameter completion: The completion closure
    func getDuration(
        completion: @escaping (Result<Int, YouTubePlayerAPIError>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getDuration();",
            responseType: Int.self
        ) { result, _ in
            completion(result)
        }
    }
    
    /// Returns the YouTube.com URL for the currently loaded/playing video
    /// - Parameter completion: The completion closure
    func getVideoURL(
        completion: @escaping (Result<String, YouTubePlayerAPIError>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getVideoUrl();",
            responseType: String.self
        ) { result, _ in
            completion(result)
        }
    }
    
    /// Returns the embed code for the currently loaded/playing video
    /// - Parameter completion: The completion closure
    func getVideoEmbedCode(
        completion: @escaping (Result<String, YouTubePlayerAPIError>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getVideoEmbedCode();",
            responseType: String.self
        ) { result, _ in
            completion(result)
        }
    }
    
}
