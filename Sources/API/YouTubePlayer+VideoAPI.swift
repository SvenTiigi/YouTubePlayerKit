import Combine
import Foundation
import WebKit

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
    
    /// Pauses any current picture-in-picture and fullscreen media playback.
    func pauseMediaPlayback() async {
        await self.webView.pauseAllMediaPlayback()
    }
    
    /// Changes whether the underlying ``WKWebView`` instance is suspending playback of all media in the page.
    /// - Parameter isSuspended: A Boolean whether media playback should be suspended or resumed.
    /// - Important: Pass true to pause all media the web view is playing. Neither the user nor the webpage can resume playback until you call this method again with false.
    func setMediaPlaybackSuspended(
        _ isSuspended: Bool
    ) async {
        await self.webView.setAllMediaPlaybackSuspended(isSuspended)
    }
    
    /// Requests the media playback status of the underlying ``WKWebView`` instance.
    func requestMediaPlaybackState() async -> WebKit.WKMediaPlaybackState {
        await self.webView.requestMediaPlaybackState()
    }
    
    /// Closes any current picture-in-picture and fullscreen media presentation.
    func closeMediaPresentation() async {
        await self.webView.closeAllMediaPresentations()
    }
    
    /// Requests web fullscreen mode, applicable only if `configuration.fullscreenMode` is set to `.web`.
    /// - Important: This function only executes if the configuration's ``YouTubePlayer.FullscreenMode`` of the ``YouTubePlayer.Configuration`` is set to `.web`.
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
    
    /// The web fullscreen state of the underlying ``WKWebView`` instance.
    /// - Important: This property only indicates the fullscreen state when the ``YouTubePlayer.FullscreenMode`` of the ``YouTubePlayer.Configuration`` is set to `.web`.
    /// **It does not reflect the fullscreen state when playing a video in fullscreen using the `.system` mode.**
    @available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
    var webFullscreenState: WebKit.WKWebView.FullscreenState {
        self.webView.fullscreenState
    }
    
    /// A Publisher that emits the web fullscreen state of the underlying ``WKWebView`` instance.
    /// - Important: The value of this publisher only indicates the fullscreen state when the ``YouTubePlayer.FullscreenMode`` of the ``YouTubePlayer.Configuration`` is set to `.web`.
    /// **It does not reflect the fullscreen state when playing a video in fullscreen using the `.system` mode.**
    @available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
    var webFullScreenStatePublisher: some Publisher<WebKit.WKWebView.FullscreenState, Never> {
        self.webView
            .publisher(
                for: \.fullscreenState,
                options: [.new]
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
