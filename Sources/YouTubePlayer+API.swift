import Combine
import SwiftUI

// MARK: - Logging

public extension YouTubePlayer {
    
    /// A Boolean that controls whether logging is enabled.
    static var isLoggingEnabled: Bool {
        get {
            Logger.isEnabled
        }
        set {
            Logger.isEnabled = newValue
        }
    }
    
}

// MARK: - Reload

public extension YouTubePlayer {
    
    /// Reloads the YouTube player.
    func reload() async throws(Error) {
        // Destroy the player and discard the error
        try? await self.webView.destroyPlayer()
        // Reload
        self.webView.load()
        // Await new ready or error state
        for await state in self.stateSubject.dropFirst().values {
            // Swithc on state
            switch state {
            case .ready:
                // Success return out of function
                return
            case .error(let error):
                // Throw error
                throw error
            default:
                // Continue with next state
                continue
            }
        }
    }
    
}

// MARK: - Events (https://developers.google.com/youtube/iframe_api_reference#Events)

public extension YouTubePlayer {
    
    /// A Publisher that emits the current YouTube player source.
    var sourcePublisher: some Publisher<Source?, Never> {
        self.sourceSubject
            .receive(on: DispatchQueue.main)
    }
    
    /// The current YouTube player state.
    var state: State {
        self.stateSubject.value
    }
    
    /// A Publisher that emits the current YouTube player state.
    var statePublisher: some Publisher<State, Never> {
        self.stateSubject
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
    }
    
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
    
    /// The current YouTube player playback rate, if available.
    var playbackRate: PlaybackRate? {
        self.playbackRateSubject.value
    }
    
    /// A Publisher that emits the current YouTube player playback rate.
    var playbackRatePublisher: some Publisher<PlaybackRate, Never> {
        self.playbackRateSubject
            .compactMap { $0 }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
    }
    
    /// A Publisher that emits whenever autoplay or scripted video playback features were blocked.
    var autoplayBlockedPublisher: some Publisher<Void, Never> {
        self.autoplayBlockedSubject
            .receive(on: DispatchQueue.main)
    }
    
}

// MARK: - Playback (https://developers.google.com/youtube/iframe_api_reference#Playback_status)

public extension YouTubePlayer {
    
    /// Returns a number between 0 and 1 that specifies the percentage of the video that the player shows as buffered.
    func getVideoLoadedFraction() async throws(APIError) -> Double {
        try await self.webView.evaluate(
            javaScript: .player(
                function: "getVideoLoadedFraction"
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
        try await self.webView.evaluate(
            javaScript: .player(
                function: "getPlayerState"
            ),
            converter: .typeCast(
                to: Int.self
            )
            .map(PlaybackState.init(value:))
        )
    }
    
    /// Returns the elapsed time in seconds since the video started playing.
    func getCurrentTime() async throws(APIError) -> Measurement<UnitDuration> {
        try await self.webView.evaluate(
            javaScript: .player(
                function: "getCurrentTime"
            ),
            converter: .typeCast(
                to: Double.self
            )
            .map { seconds in
                .init(
                    value: seconds,
                    unit: .seconds
                )
            }
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
        try await self.webView.evaluate(
            javaScript: .player(
                function: "getVideoData"
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
        self.playbackStatePublisher
            .filter { $0 == .playing }
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
            .removeDuplicates()
    }
    
}

// MARK: - Playback Rate (https://developers.google.com/youtube/iframe_api_reference#Playback_rate)

public extension YouTubePlayer {
    
    /// This function retrieves the playback rate of the currently playing video.
    func getPlaybackRate() async throws(APIError) -> PlaybackRate {
        try await self.webView.evaluate(
            javaScript: .player(
                function: "getPlaybackRate"
            ),
            converter: .typeCast(
                to: Double.self
            )
            .map(PlaybackRate.init(value:))
        )
    }
    
    /// This function sets the suggested playback rate for the current video.
    /// - Parameters:
    ///   - playbackRate: The playback rate
    func set(
        playbackRate: PlaybackRate
    ) async throws(APIError) {
        try await self.webView.evaluate(
            javaScript: .player(
                function: "setPlaybackRate",
                parameters: [
                    playbackRate.value
                ]
            )
        )
    }
    
    /// This function returns the set of playback rates in which the current video is available.
    func getAvailablePlaybackRates() async throws(APIError) -> [PlaybackRate] {
        try await self.webView.evaluate(
            javaScript: .player(
                function: "getAvailablePlaybackRates"
            ),
            converter: .typeCast(
                to: [Double].self
            )
            .map { playbackRateValues in
                playbackRateValues.map(PlaybackRate.init(value:))
            }
        )
    }
    
}

// MARK: - Playlist (https://developers.google.com/youtube/iframe_api_reference#playing-a-video-in-a-playlist)

public extension YouTubePlayer {
    
    /// This function loads and plays the next video in the playlist.
    func nextVideo() async throws(APIError) {
        try await self.webView.evaluate(
            javaScript: .player(
                function: "nextVideo"
            )
        )
    }
    
    /// This function loads and plays the previous video in the playlist.
    func previousVideo() async throws(APIError) {
        try await self.webView.evaluate(
            javaScript: .player(
                function: "previousVideo"
            )
        )
    }
    
    /// This function loads and plays the specified video in the playlist.
    /// - Parameters:
    ///   - index: The index of the video that you want to play in the playlist.
    func playVideo(
        at index: Int
    ) async throws(APIError) {
        try await self.webView.evaluate(
            javaScript: .player(
                function: "playVideoAt",
                parameters: [
                    index
                ]
            )
        )
    }
    
    /// This function indicates whether the video player should continuously play a playlist
    /// or if it should stop playing after the last video in the playlist ends.
    /// - Parameters:
    ///   - enabled: Bool value if is enabled.
    func setLoop(
        enabled: Bool
    ) async throws(APIError) {
        try await self.webView.evaluate(
            javaScript: .player(
                function: "setLoop",
                parameters: [
                    enabled
                ]
            )
        )
    }
    
    /// This function indicates whether a playlist's videos should be shuffled
    /// so that they play back in an order different from the one that the playlist creator designated.
    /// - Parameters:
    ///   - enabled: Bool value if is enabled.
    func setShuffle(
        enabled: Bool
    ) async throws(APIError) {
        try await self.webView.evaluate(
            javaScript: .player(
                function: "setShuffle",
                parameters: [
                    enabled
                ]
            )
        )
    }
    
    /// This function returns an array of the video IDs in the playlist as they are currently ordered.
    func getPlaylist() async throws(APIError) -> [Source.ID]? {
        try await self.webView.evaluate(
            javaScript: .player(
                function: "getPlaylist"
            ),
            converter: .typeCast()
        )
    }
    
    /// This function returns the index of the playlist video that is currently playing.
    func getPlaylistIndex() async throws(APIError) -> Int {
        try await self.webView.evaluate(
            javaScript: .player(
                function: "getPlaylistIndex"
            ),
            converter: .typeCast()
        )
    }
    
}

// MARK: - Queueing

public extension YouTubePlayer {
    
    /// Loads a new YouTube player source.
    /// - Parameters:
    ///   - source: The new YouTube player source to load.
    ///   - startTime: The start time. Default value `nil`
    ///   - endTime: The end time. Default value `nil`
    ///   - index: The index of a video in a playlist. Default value `nil`
    func load(
        source: Source,
        startTime: Measurement<UnitDuration>? = nil,
        endTime: Measurement<UnitDuration>? = nil,
        index: Int? = nil
    ) async throws(APIError) {
        try await self.update(
            source: source,
            javaScriptFunctionName: {
                switch source {
                case .video:
                    return "loadVideoById"
                case .videos, .playlist, .channel:
                    return "loadPlaylist"
                }
            }(),
            startTime: startTime,
            endTime: endTime,
            index: index
        )
    }
    
    /// Cue a YouTube player source.
    /// - Parameters:
    ///   - source: The new YouTube player source to cue.
    ///   - startTime: The start time. Default value `nil`
    ///   - endTime: The end time. Default value `nil`
    ///   - index: The index of a video in a playlist. Default value `nil`
    func cue(
        source: Source,
        startTime: Measurement<UnitDuration>? = nil,
        endTime: Measurement<UnitDuration>? = nil,
        index: Int? = nil
    ) async throws(APIError) {
        try await self.update(
            source: source,
            javaScriptFunctionName: {
                switch source {
                case .video:
                    return "cueVideoById"
                case .videos, .playlist, .channel:
                    return "cuePlaylist"
                }
            }(),
            startTime: startTime,
            endTime: endTime,
            index: index
        )
    }
    
    /// The LoadVideoById Parameter
    private struct LoadVideoByIdParamter: Encodable {
        
        /// The video identifier
        let videoId: String
        
        /// The optional start seconds
        let startSeconds: Double?
        
        /// The optional end seconds
        let endSeconds: Double?
        
    }
    
    /// The LoadPlaylist Parameter
    private struct LoadPlaylistParameter: Encodable {
        
        /// The list
        let list: String
        
        /// The ListType
        let listType: Parameters.ListType
        
        /// The optional index
        let index: Int?
        
        /// The optional start seconds
        let startSeconds: Double?
        
    }
    
    /// Update YouTubePlayer Source with a given JavaScript function name
    /// - Parameters:
    ///   - source: The YouTubePlayer Source
    ///   - javaScriptFunctionName: The JavaScript function name
    ///   - startTime: The start time. Default value `nil`
    ///   - endTime: The end time. Default value `nil`
    ///   - index: The index of a video in a playlist. Default value `nil`
    private func update(
        source: Source,
        javaScriptFunctionName: String,
        startTime: Measurement<UnitDuration>? = nil,
        endTime: Measurement<UnitDuration>? = nil,
        index: Int? = nil
    ) async throws(APIError) {
        try await self.webView.evaluate(
            javaScript: .player(
                function: javaScriptFunctionName,
                parameter: {
                    switch source {
                    case .video(let id):
                        return LoadVideoByIdParamter(
                            videoId: id,
                            startSeconds: startTime?.converted(to: .seconds).value,
                            endSeconds: endTime?.converted(to: .seconds).value
                        )
                    case .videos(let ids):
                        return LoadPlaylistParameter(
                            list: ids.joined(separator: ","),
                            listType: .playlist,
                            index: index,
                            startSeconds: startTime?.converted(to: .seconds).value
                        )
                    case .playlist(let id):
                        return LoadPlaylistParameter(
                            list: id,
                            listType: .playlist,
                            index: index,
                            startSeconds: startTime?.converted(to: .seconds).value
                        )
                    case .channel(let name):
                        return LoadPlaylistParameter(
                            list: name,
                            listType: .channel,
                            index: index,
                            startSeconds: startTime?.converted(to: .seconds).value
                        )
                    }
                }()
            )
        )
    }
    
}

// MARK: - Video (https://developers.google.com/youtube/iframe_api_reference#Playback_controls)

public extension YouTubePlayer {
    
    /// Plays the currently cued/loaded video.
    func play() async throws(APIError) {
        try await self.webView.evaluate(
            javaScript: .player(
                function: "playVideo"
            )
        )
    }
    
    /// Pauses the currently playing video.
    func pause() async throws(APIError) {
        try await self.webView.evaluate(
            javaScript: .player(
                function: "pauseVideo"
            )
        )
    }
    
    /// Stops and cancels loading of the current video.
    func stop() async throws(APIError) {
        try await self.webView.evaluate(
            javaScript: .player(
                function: "stopVideo"
            )
        )
    }
    
    /// Seeks to a specified time in the video.
    /// - Parameters:
    ///   - time: The parameter identifies the time to which the player should advance.
    ///   - allowSeekAhead: Determines whether the player will make a new request to the server. Default value `true`
    func seek(
        to time: Measurement<UnitDuration>,
        allowSeekAhead: Bool = true
    ) async throws(APIError) {
        try await self.webView.evaluate(
            javaScript: .player(
                function: "seekTo",
                parameters: [
                    time.converted(to: .seconds).value,
                    allowSeekAhead
                ]
            )
        )
    }
    
    /// Fast forward by the given time.
    /// - Parameters:
    ///   - time: The time to fast forward.
    ///   - allowSeekAhead: Determines whether the player will make a new request to the server. Default value `true`
    func fastForward(
        by time: Measurement<UnitDuration>,
        allowSeekAhead: Bool = true
    ) async throws(APIError) {
        try await self.seek(
            to: try await self.getCurrentTime() + time,
            allowSeekAhead: allowSeekAhead
        )
    }
    
    /// Rewind by the given time.
    /// - Parameters:
    ///   - time: The time to rewind.
    ///   - allowSeekAhead: Determines whether the player will make a new request to the server. Default value `true`
    func rewind(
        by time: Measurement<UnitDuration>,
        allowSeekAhead: Bool = true
    ) async throws(APIError) {
        try await self.seek(
            to: try await self.getCurrentTime() - time,
            allowSeekAhead: allowSeekAhead
        )
    }
    
    /// Closes any current picture-in-picture video and fullscreen video.
    func closeAllMediaPresentations() async {
        await self.webView.closeAllMediaPresentations()
    }
    
}

// MARK: - Video Information (https://developers.google.com/youtube/iframe_api_reference#Retrieving_video_information)

public extension YouTubePlayer {
    
    /// Show Stats for Nerds which displays additional video information.
    func showStatsForNerds() async throws(APIError) {
        try await self.webView.evaluate(
            javaScript: .player(
                function: "showVideoInfo"
            )
        )
    }
    
    /// Hide Stats for Nerds which hides additional video information.
    func hideStatsForNerds() async throws(APIError) {
        try await self.webView.evaluate(
            javaScript: .player(
                function: "hideVideoInfo"
            )
        )
    }
    
    /// Retrieve the YouTube player information.
    func getInformation() async throws(APIError) -> Information {
        try await self.webView.evaluate(
            javaScript: .player("playerInfo"),
            converter: .typeCast(
                to: [String: Any].self
            )
            .decode()
        )
    }
    
    /// Returns the duration in seconds of the currently playing video.
    func getDuration() async throws(APIError) -> Measurement<UnitDuration> {
        try await self.webView.evaluate(
            javaScript: .player(
                function: "getDuration"
            ),
            converter: .typeCast(
                to: Double.self
            )
            .map { seconds in
                .init(
                    value: seconds,
                    unit: .seconds
                )
            }
        )
    }
    
    /// A Publisher that emits the duration in seconds of the currently playing video.
    var durationPublisher: some Publisher<Measurement<UnitDuration>, Never> {
        self.playbackStatePublisher
            .filter { $0 == .playing }
            .flatMap { [weak self] _ -> AnyPublisher<Measurement<UnitDuration>, Never> in
                guard let self else {
                    return Empty().eraseToAnyPublisher()
                }
                return Future { promise in
                    Task { [weak self] in
                        guard let duration = try? await self?.getDuration() else {
                            return
                        }
                        promise(.success(duration))
                    }
                }
                .eraseToAnyPublisher()
            }
            .removeDuplicates()
            .share()
    }
    
    /// Returns the YouTube.com URL for the currently loaded/playing video.
    func getVideoURL() async throws(APIError) -> String {
        try await self.webView.evaluate(
            javaScript: .player(
                function: "getVideoUrl"
            ),
            converter: .typeCast()
        )
    }
    
    /// Returns the embed code for the currently loaded/playing video
    func getVideoEmbedCode() async throws(APIError) -> String {
        try await self.webView.evaluate(
            javaScript: .player(
                function: "getVideoEmbedCode"
            ),
            converter: .typeCast()
        )
    }
    
}

// MARK: - Volume (https://developers.google.com/youtube/iframe_api_reference#changing-the-player-volume)

public extension YouTubePlayer {
    
    /// Mutes the player.
    func mute() async throws(APIError) {
        try await self.webView.evaluate(
            javaScript: .player(
                function: "mute"
            )
        )
    }
    
    /// Unmutes the player.
    func unmute() async throws(APIError) {
        try await self.webView.evaluate(
            javaScript: .player(
                function: "unMute"
            )
        )
    }
    
    /// Returns Bool value if the player is muted.
    func isMuted() async throws(APIError) -> Bool {
        try await self.webView.evaluate(
            javaScript: .player(
                function: "isMuted"
            ),
            converter: .typeCast()
        )
    }
    
    /// Returns the player's current volume, an integer between 0 and 100
    func getVolume() async throws(APIError) -> Int {
        try await self.webView.evaluate(
            javaScript: .player(
                function: "getVolume"
            ),
            converter: .typeCast()
        )
    }
    
}

// MARK: - Video Thumbnail

public extension YouTubePlayer {
    
    /// Returns the video thumbnail URL of the currently loaded video, if available.
    /// - Parameters:
    ///   - resolution: The resolution of the video thumbnail. Default value `.standard`
    func getVideoThumbnailURL(
        resolution: YouTubeVideoThumbnail.Resolution = .standard
    ) async throws(APIError) -> URL? {
        guard let videoID = try await self.getPlaybackMetadata().videoId else {
            return nil
        }
        return YouTubeVideoThumbnail(
            videoID: videoID,
            resolution: resolution
        )
        .url
    }
    
    /// Returns the video thumbnail of the currently loaded video, if available.
    /// - Parameters:
    ///   - resolution: The resolution of the video thumbnail. Default value `.standard`
    ///   - urlSession: The URLSession. Default value `.shared`
    func getVideoThumbnailImage(
        resolution: YouTubeVideoThumbnail.Resolution = .standard,
        urlSession: URLSession = .shared
    ) async throws -> YouTubeVideoThumbnail.Image? {
        guard let videoID = try await self.getPlaybackMetadata().videoId else {
            return nil
        }
        return try await YouTubeVideoThumbnail(
            videoID: videoID,
            resolution: resolution
        )
        .image(urlSession: urlSession)
    }
    
}
