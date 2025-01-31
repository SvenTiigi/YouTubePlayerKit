import Combine
import Foundation

// MARK: - Video API

public extension YouTubePlayer {
    
    /// A Publisher that emits whenever autoplay or scripted video playback features were blocked.
    var autoplayBlockedPublisher: some Publisher<Void, Never> {
        self.autoplayBlockedSubject
            .receive(on: DispatchQueue.main)
    }
    
    /// Plays the currently cued/loaded video.
    func play() async throws(APIError) {
        try await self.evaluate(
            javaScript: .youTubePlayer(
                functionName: "playVideo"
            )
        )
    }
    
    /// Pauses the currently playing video.
    func pause() async throws(APIError) {
        try await self.evaluate(
            javaScript: .youTubePlayer(
                functionName: "pauseVideo"
            )
        )
    }
    
    /// Stops and cancels loading of the current video.
    func stop() async throws(APIError) {
        try await self.evaluate(
            javaScript: .youTubePlayer(
                functionName: "stopVideo"
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
        try await self.evaluate(
            javaScript: .youTubePlayer(
                functionName: "seekTo",
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
    
    /// Requests web fullscreen mode, applicable only if `configuration.fullscreenMode` is set to `.web`.
    /// - Important: This function only executes if the configuration's fullscreen mode is set to `.web`.
    /// - Returns: A boolean value indicating whether the fullscreen request was successful:
    /// `true` if fullscreen mode was successfully requested.
    /// `false` if either the configuration doesn't allow web fullscreen or if the fullscreen API is not available
    func requestWebFullscreen() async throws(APIError) -> Bool {
        guard self.configuration.fullscreenMode == .web else {
            return false
        }
        return try await self.evaluate(
            javaScript: .init(
                """
                var iframe = document.querySelector('iframe');
                var requestFullScreen = iframe.requestFullScreen || iframe.webkitRequestFullScreen;
                if (requestFullScreen) {
                    requestFullScreen.bind(iframe)();
                    return true;
                }
                return false;
                """
            )
            .asImmediatelyInvokedFunctionExpression(),
            converter: .typeCast()
        )
    }
    
}

// MARK: - Video Information (https://developers.google.com/youtube/iframe_api_reference#Retrieving_video_information)

public extension YouTubePlayer {
    
    /// Returns a Boolean indicating if the detailed video statistics and technical information are visible.
    func isStatsForNerdsVisible() async throws(APIError) -> Bool {
        try await self.evaluate(
            javaScript: .youTubePlayer(
                functionName: "isVideoInfoVisible"
            ),
            converter: .typeCast()
        )
    }
    
    /// Toggles the visibility of detailed video statistics and technical information.
    ///
    /// This function controls the display of advanced video metrics, similar to YouTube's
    /// "Stats for Nerds" feature. When enabled, it shows technical details such as:
    /// - Video codec information
    /// - Buffer health
    /// - Connection speed
    /// - Frame drop statistics
    /// - Parameter isVisible: Controls the visibility of the statistics overlay.
    ///   - `true` to display the statistics
    ///   - `false` to hide them
    func setStatsForNerds(isVisible: Bool) async throws(APIError) {
        try await self.evaluate(
            javaScript: .youTubePlayer(
                functionName: isVisible ? "showVideoInfo" : "hideVideoInfo"
            )
        )
    }
    
    /// Retrieve the YouTube player information.
    func getInformation() async throws(APIError) -> Information {
        try await self.evaluate(
            javaScript: .youTubePlayer(operator: "playerInfo"),
            converter: .typeCast(
                to: [String: Any].self
            )
            .decode()
        )
    }
    
    /// Returns the duration in seconds of the currently playing video.
    func getDuration() async throws(APIError) -> Measurement<UnitDuration> {
        .init(
            value: try await self.evaluate(
                javaScript: .youTubePlayer(
                    functionName: "getDuration"
                ),
                converter: .typeCast(
                    to: Double.self
                )
            ),
            unit: .seconds
        )
    }
    
    /// A Publisher that emits the duration in seconds of the currently playing video.
    var durationPublisher: some Publisher<Measurement<UnitDuration>, Never> {
        self.javaScriptEventPublisher
            .filter { $0.name == .onApiChange }
            .flatMap { _ in
                Future { promise in
                    Task { [weak self] in
                        guard let duration = try? await self?.getDuration() else {
                            return
                        }
                        promise(.success(duration))
                    }
                }
            }
            .share()
    }
    
    /// Returns the YouTube.com URL for the currently loaded/playing video.
    func getVideoURL() async throws(APIError) -> String {
        try await self.evaluate(
            javaScript: .youTubePlayer(
                functionName: "getVideoUrl"
            ),
            converter: .typeCast()
        )
    }
    
    /// Returns the embed code for the currently loaded/playing video
    func getVideoEmbedCode() async throws(APIError) -> String {
        do {
            return try await self.evaluate(
                javaScript: .youTubePlayer(
                    functionName: "getVideoEmbedCode"
                ),
                converter: .typeCast()
            )
        } catch {
            // Perform fallback to retrieve the video embed code via the information
            // The `getVideoEmbedCode` sometimes fails due to an invalid width or height property
            guard let videoEmbedCode = try? await self.getInformation().videoEmbedCode else {
                // Otherwise rethrow error
                throw error
            }
            // Return video embed code
            return videoEmbedCode
        }
    }
    
}
