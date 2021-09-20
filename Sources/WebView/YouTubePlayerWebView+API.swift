import Combine
import Foundation
import WebKit

// MARK: - YouTubePlayerLoadAPI

extension YouTubePlayerWebView: YouTubePlayerLoadAPI {
    
    /// Load YouTubePlayer Source
    /// - Parameter source: The YouTubePlayer Source to load
    func load(
        source: YouTubePlayer.Source
    ) {
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
    
    /// A Publisher that emits the current YouTubePlayer State
    var statePublisher: AnyPublisher<YouTubePlayer.State, Never> {
        self.stateSubject
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    /// A Publisher that emits the current YouTubePlayer VideoState
    var videoStatePublisher: AnyPublisher<YouTubePlayer.VideoState, Never> {
        self.videoStateSubject
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    /// A Publisher that emits the current YouTubePlayer PlaybackQuality
    var playbackQualityPublisher: AnyPublisher<YouTubePlayer.PlaybackQuality, Never> {
        self.playbackQualitySubject
            .compactMap { $0 }
            .eraseToAnyPublisher()
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
        completion: @escaping (Result<YouTubePlayer.Perspective360Degree, Error>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getSphericalProperties();"
        ) { result in
            switch result {
            case .success(let value):
                guard let object = value as? String,
                      let perspective360Degree = try? JSONDecoder().decode(
                        YouTubePlayer.Perspective360Degree.self,
                        from: .init(object.utf8)
                      )  else {
                    return completion(
                        .failure(
                            JavaScriptError(reason: "Perspective360Degree unavailable")
                        )
                    )
                }
                completion(.success(perspective360Degree))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Sets the video orientation for playback of a 360° video
    /// - Parameter perspective360Degree: The Perspective360Degree
    func set(
        perspective360Degree: YouTubePlayer.Perspective360Degree
    ) {
        guard let jsonData = try? JSONEncoder().encode(perspective360Degree) else {
            return
        }
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
        at index: UInt
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
        completion: @escaping (Result<[String], Error>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getPlaylist();"
        ) { result in
            switch result {
            case .success(let value):
                guard let playlistIds = value as? [String] else {
                    return completion(
                        .failure(
                            JavaScriptError(reason: "Playlist identifiers are unavailable")
                        )
                    )
                }
                completion(.success(playlistIds))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// This function returns the index of the playlist video that is currently playing.
    /// - Parameter completion: The completion closure
    func getPlayistIndex(
        completion: @escaping (Result<UInt, Error>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getPlaylistIndex();"
        ) { result in
            switch result {
            case .success(let value):
                guard let index = value as? Int else {
                    return completion(
                        .failure(
                            JavaScriptError(reason: "Playlist index is unavailable")
                        )
                    )
                }
                completion(.success(.init(index)))
            case .failure(let error):
                completion(.failure(error))
            }
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
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.isMuted();"
        ) { result in
            switch result {
            case .success(let value):
                guard let isMuted = value as? Bool else {
                    return completion(
                        .failure(
                            JavaScriptError(reason: "isMuted is unavailable")
                        )
                    )
                }
                completion(.success(isMuted))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Returns the player's current volume, an integer between 0 and 100
    /// - Parameter completion: The completion closure
    func getVolume(
        completion: @escaping (Result<UInt, Error>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getVolume();"
        ) { result in
            switch result {
            case .success(let value):
                guard let volume = value as? Int else {
                    return completion(
                        .failure(
                            JavaScriptError(reason: "Volume is unavailable")
                        )
                    )
                }
                completion(.success(.init(volume)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Sets the volume.
    /// Accepts an integer between 0 and 100
    /// - Parameter volume: The volume
    func set(
        volume: UInt
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
        completion: @escaping (Result<YouTubePlayer.PlaybackRate, Error>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getPlaybackRate();"
        ) { result in
            switch result {
            case .success(let value):
                guard let playbackRate = value as? Double else {
                    return completion(
                        .failure(
                            JavaScriptError(reason: "PlaybackRate is unavailable")
                        )
                    )
                }
                completion(.success(playbackRate))
            case .failure(let error):
                completion(.failure(error))
            }
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
        completion: @escaping (Result<[YouTubePlayer.PlaybackRate], Error>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getAvailablePlaybackRates();"
        ) { result in
            switch result {
            case .success(let value):
                guard let playbackRates = value as? [Double] else {
                    return completion(
                        .failure(
                            JavaScriptError(reason: "PlaybackRates are unavailable")
                        )
                    )
                }
                completion(.success(playbackRates))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}

// MARK: - YouTubePlayerPlaybackAPI

extension YouTubePlayerWebView: YouTubePlayerPlaybackAPI {
    
    /// Returns a number between 0 and 1 that specifies the percentage of the video that the player shows as buffered
    /// - Parameter completion: The completion closure
    func getVideoLoadedFraction(
        completion: @escaping (Result<Double, Error>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getVideoLoadedFraction();"
        ) { result in
            switch result {
            case .success(let value):
                guard let fraction = value as? Double else {
                    return completion(
                        .failure(
                            JavaScriptError(reason: "Fraction is unavailable")
                        )
                    )
                }
                completion(.success(fraction))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Returns the state of the player video
    /// - Parameter completion: The completion closure
    func getVideoState(
        completion: @escaping (Result<YouTubePlayer.VideoState, Error>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getPlayerState();"
        ) { result in
            switch result {
            case .success(let value):
                guard let value = value as? Int,
                      let videoState = YouTubePlayer.VideoState(rawValue: value) else {
                    return completion(
                        .failure(
                            JavaScriptError(reason: "VideoState is unavailable")
                        )
                    )
                }
                completion(.success(videoState))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Returns the elapsed time in seconds since the video started playing
    /// - Parameter completion: The completion closure
    func getCurrentTime(
        completion: @escaping (Result<UInt, Error>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getCurrentTime();"
        ) { result in
            switch result {
            case .success(let value):
                guard let currentTime = value as? Int else {
                    return completion(
                        .failure(
                            JavaScriptError(reason: "CurrentTime is unavailable")
                        )
                    )
                }
                completion(.success(.init(currentTime)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}

// MARK: - YouTubePlayerVideoInformationAPI

extension YouTubePlayerWebView: YouTubePlayerVideoInformationAPI {
    
    /// Returns the duration in seconds of the currently playing video
    /// - Parameter completion: The completion closure
    func getDuration(
        completion: @escaping (Result<UInt, Error>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getDuration();"
        ) { result in
            switch result {
            case .success(let value):
                guard let duration = value as? Int else {
                    return completion(
                        .failure(
                            JavaScriptError(reason: "Duration is unavailable")
                        )
                    )
                }
                completion(.success(.init(duration)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Returns the YouTube.com URL for the currently loaded/playing video
    /// - Parameter completion: The completion closure
    func getVideoURL(
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getVideoUrl();"
        ) { result in
            switch result {
            case .success(let value):
                guard let videoUrl = value as? String else {
                    return completion(
                        .failure(
                            JavaScriptError(reason: "Video URL is unavailable")
                        )
                    )
                }
                completion(.success(videoUrl))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Returns the embed code for the currently loaded/playing video
    /// - Parameter completion: The completion closure
    func getVideoEmbedCode(
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        self.evaluate(
            javaScript: "player.getVideoEmbedCode();"
        ) { result in
            switch result {
            case .success(let value):
                guard let embedCode = value as? String else {
                    return completion(
                        .failure(
                            JavaScriptError(reason: "Embed Code is unavailable")
                        )
                    )
                }
                completion(.success(embedCode))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
