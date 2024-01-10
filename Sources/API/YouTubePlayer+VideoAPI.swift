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
    ///   - seconds: The seconds parameter identifies the time to which the player should advance
    ///   - allowSeekAhead: Determines whether the player will make a new request to the server
    ///   - completion: The completion closure
    func seek(
        to seconds: Double,
        allowSeekAhead: Bool,
        completion: ((Result<Void, APIError>) -> Void)? = nil
    ) {
        self.webView.evaluate(
            javaScript: .player(
                function: "seekTo",
                parameters: String(seconds), String(allowSeekAhead)
            ),
            completion: completion
        )
    }
    
    #if compiler(>=5.5) && canImport(_Concurrency)
    /// Seeks to a specified time in the video
    /// - Parameters:
    ///   - seconds: The seconds parameter identifies the time to which the player should advance
    ///   - allowSeekAhead: Determines whether the player will make a new request to the server
    ///   - completion: The completion closure
    func seek(
        to seconds: Double,
        allowSeekAhead: Bool
    ) async throws {
        try await withCheckedThrowingContinuation { continuation in
            self.seek(
                to: seconds, 
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
    
}
