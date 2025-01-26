import Foundation

/// The YouTubePlayer Video API
/// - Read more: https://developers.google.com/youtube/iframe_api_reference#Playback_controls
public extension YouTubePlayer {
    
    /// Plays the currently cued/loaded video
    /// - Parameter completion: The completion closure
    func play(
        completion: ((Result<Void, APIError>) -> Void)? = nil
    ) {
        self.webView.evaluate(
            javaScript: .player(function: "playVideo"),
            completion: completion
        )
    }
    
    #if compiler(>=5.5) && canImport(_Concurrency)
    /// Plays the currently cued/loaded video
    func play() async throws {
        try await withCheckedThrowingContinuation { continuation in
            self.play(
                completion: continuation.resume(with:)
            )
        }
    }
    #endif
    
    /// Pauses the currently playing video
    /// - Parameter completion: The completion closure
    func pause(
        completion: ((Result<Void, APIError>) -> Void)? = nil
    ) {
        self.webView.evaluate(
            javaScript: .player(function: "pauseVideo"),
            completion: completion
        )
    }
    
    #if compiler(>=5.5) && canImport(_Concurrency)
    /// Pauses the currently playing video
    func pause() async throws {
        try await withCheckedThrowingContinuation { continuation in
            self.pause(
                completion: continuation.resume(with:)
            )
        }
    }
    #endif
    
    /// Stops and cancels loading of the current video
    /// - Parameter completion: The completion closure
    func stop(
        completion: ((Result<Void, APIError>) -> Void)? = nil
    ) {
        self.webView.evaluate(
            javaScript: .player(function: "stopVideo"),
            completion: completion
        )
    }
    
    #if compiler(>=5.5) && canImport(_Concurrency)
    /// Stops and cancels loading of the current video
    func stop() async throws {
        try await withCheckedThrowingContinuation { continuation in
            self.stop(
                completion: continuation.resume(with:)
            )
        }
    }
    #endif
    
    /// Seeks to a specified time in the video
    /// - Parameters:
    ///   - time: The parameter identifies the time to which the player should advance
    ///   - allowSeekAhead: Determines whether the player will make a new request to the server. Default value `true`
    ///   - completion: The completion closure
    func seek(
        to time: Measurement<UnitDuration>,
        allowSeekAhead: Bool = true,
        completion: ((Result<Void, APIError>) -> Void)? = nil
    ) {
        self.webView.evaluate(
            javaScript: .player(
                function: "seekTo",
                parameters: String(time.converted(to: .seconds).value), String(allowSeekAhead)
            ),
            completion: completion
        )
    }
    
    #if compiler(>=5.5) && canImport(_Concurrency)
    /// Seeks to a specified time in the video
    /// - Parameters:
    ///   - time: The parameter identifies the time to which the player should advance
    ///   - allowSeekAhead: Determines whether the player will make a new request to the server. Default value `true`
    ///   - completion: The completion closure
    func seek(
        to time: Measurement<UnitDuration>,
        allowSeekAhead: Bool = true
    ) async throws {
        try await withCheckedThrowingContinuation { continuation in
            self.seek(
                to: time,
                allowSeekAhead: allowSeekAhead,
                completion: continuation.resume(with:)
            )
        }
    }
    #endif
    
    /// Fast forward by the given time.
    /// - Parameters:
    ///   - time: The time to fast forward.
    ///   - allowSeekAhead: Determines whether the player will make a new request to the server. Default value `true`
    ///   - completion: The completion closure.
    func fastForward(
        by time: Measurement<UnitDuration>,
        allowSeekAhead: Bool = true,
        completion: ((Result<Void, APIError>) -> Void)? = nil
    ) {
        self.getCurrentTime { result in
            switch result {
            case .success(let currentTime):
                self.seek(
                    to: currentTime + time,
                    allowSeekAhead: allowSeekAhead,
                    completion: completion
                )
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
    
    #if compiler(>=5.5) && canImport(_Concurrency)
    /// Fast forward by the given time.
    /// - Parameters:
    ///   - time: The time to fast forward.
    ///   - allowSeekAhead: Determines whether the player will make a new request to the server. Default value `true`
    func fastForward(
        by time: Measurement<UnitDuration>,
        allowSeekAhead: Bool = true
    ) async throws {
        try await withCheckedThrowingContinuation { continuation in
            self.fastForward(
                by: time,
                allowSeekAhead: allowSeekAhead,
                completion: continuation.resume(with:)
            )
        }
    }
    #endif
    
    /// Rewind by the given time.
    /// - Parameters:
    ///   - time: The time to rewind.
    ///   - allowSeekAhead: Determines whether the player will make a new request to the server. Default value `true`
    ///   - completion: The completion closure.
    func rewind(
        by time: Measurement<UnitDuration>,
        allowSeekAhead: Bool = true,
        completion: ((Result<Void, APIError>) -> Void)? = nil
    ) {
        self.getCurrentTime { result in
            switch result {
            case .success(let currentTime):
                self.seek(
                    to: currentTime - time,
                    allowSeekAhead: allowSeekAhead,
                    completion: completion
                )
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
    
    #if compiler(>=5.5) && canImport(_Concurrency)
    /// Rewind by the given time.
    /// - Parameters:
    ///   - time: The time to rewind.
    ///   - allowSeekAhead: Determines whether the player will make a new request to the server. Default value `true`
    func rewind(
        by time: Measurement<UnitDuration>,
        allowSeekAhead: Bool = true
    ) async throws {
        try await withCheckedThrowingContinuation { continuation in
            self.rewind(
                by: time,
                allowSeekAhead: allowSeekAhead,
                completion: continuation.resume(with:)
            )
        }
    }
    #endif
    
    /// Closes any current picture-in-picture video and fullscreen video.
    /// - Parameter completionHandler: A closure the system executes after it completes closing all media presentations.
    @available(iOS 15.0, macOS 12.0, *)
    func closeAllMediaPresentations(
        completionHandler: (() -> Void)? = nil
    ) {
        self.webView.closeAllMediaPresentations(completionHandler: completionHandler)
    }
    
    #if compiler(>=5.5) && canImport(_Concurrency)
    /// Closes any current picture-in-picture video and fullscreen video.
    @available(iOS 15.0, macOS 12.0, *)
    @MainActor
    func closeAllMediaPresentations() async {
        await self.webView.closeAllMediaPresentations()
    }
    #endif
    
#if compiler(>=5.5) && canImport(_Concurrency)
    /// Stops and cancels loading of the current video
    func fullScreen() async throws {
        try await withCheckedThrowingContinuation { continuation in
            self.fullScreen(
                completion: continuation.resume(with:)
            )
        }
    }
#endif
    
    /// Pauses the currently playing video
    /// - Parameter completion: The completion closure
    func fullScreen(
        completion: ((Result<Void, APIError>) -> Void)? = nil
    ) {
        self.webView.evaluate(
            javaScript: .init(
                "setFullScreen();"
            ),
            completion: completion
        )
    }
}
