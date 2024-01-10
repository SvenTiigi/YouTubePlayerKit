import Foundation

/// The YouTubePlayer Volume API
/// - Read more: https://developers.google.com/youtube/iframe_api_reference#changing-the-player-volume
public extension YouTubePlayer {
    
    /// Mutes the player
    /// - Parameter completion: The completion closure
    func mute(
        completion: ((Result<Void, APIError>) -> Void)? = nil
    ) {
        self.webView.evaluate(
            javaScript: .player(function: "mute"),
            completion: completion
        )
    }
    
    #if compiler(>=5.5) && canImport(_Concurrency)
    /// Mutes the player
    func mute() async throws {
        try await withCheckedThrowingContinuation { continuation in
            self.mute(
                completion: continuation.resume(with:)
            )
        }
    }
    #endif
    
    /// Unmutes the player
    /// - Parameter completion: The completion closure
    func unmute(
        completion: ((Result<Void, APIError>) -> Void)? = nil
    ) {
        self.webView.evaluate(
            javaScript: .player(function: "unMute"),
            completion: completion
        )
    }
    
    #if compiler(>=5.5) && canImport(_Concurrency)
    /// Unmutes the player
    func unmute() async throws {
        try await withCheckedThrowingContinuation { continuation in
            self.unmute(
                completion: continuation.resume(with:)
            )
        }
    }
    #endif
    
    /// Retrieve the Bool value if the player is muted
    /// - Parameter completion: The completion closure
    func isMuted(
        completion: @escaping (Result<Bool, APIError>) -> Void
    ) {
        self.webView.evaluate(
            javaScript: .player(function: "isMuted"),
            converter: .typeCast(),
            completion: completion
        )
    }
    
    #if compiler(>=5.5) && canImport(_Concurrency)
    /// Returns Bool value if the player is muted
    func isMuted() async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            self.isMuted(completion: continuation.resume)
        }
    }
    #endif
    
    /// Retrieve the player's current volume, an integer between 0 and 100
    /// - Parameter completion: The completion closure
    func getVolume(
        completion: @escaping (Result<Int, APIError>) -> Void
    ) {
        self.webView.evaluate(
            javaScript: .player(function: "getVolume"),
            converter: .typeCast(),
            completion: completion
        )
    }
    
    #if compiler(>=5.5) && canImport(_Concurrency)
    /// Returns the player's current volume, an integer between 0 and 100
    func getVolume() async throws -> Int {
        try await withCheckedThrowingContinuation { continuation in
            self.getVolume(completion: continuation.resume)
        }
    }
    #endif
    
    /// Sets the volume.
    /// Accepts an integer between 0 and 100
    /// - Note: This function is part of the official YouTube Player iFrame API
    ///  but due to limitations and restrictions of the underlying WKWebView
    ///  the call has no effect on the actual volume of the device
    /// - Parameters:
    ///   - volume: The volume
    ///   - completion: The completion closure
    func set(
        volume: Int,
        completion: ((Result<Void, APIError>) -> Void)? = nil
    ) {
        #if DEBUG
        print(
            "[YouTubePlayerKit] Setting the volume will have no effect on the actual volume of the device."
        )
        #endif
        let volume = max(0, min(volume, 100))
        self.webView.evaluate(
            javaScript: .player(
                function: "setVolume",
                parameters: String(volume)
            ),
            completion: completion
        )
    }
    
    #if compiler(>=5.5) && canImport(_Concurrency)
    /// Sets the volume.
    /// Accepts an integer between 0 and 100
    /// - Note: This function is part of the official YouTube Player iFrame API
    ///  but due to limitations and restrictions of the underlying WKWebView
    ///  the call has no effect on the actual volume of the device
    /// - Parameters:
    ///   - volume: The volume
    func set(
        volume: Int
    ) async throws {
        try await withCheckedThrowingContinuation { continuation in
            self.set(
                volume: volume,
                completion: continuation.resume(with:)
            )
        }
    }
    #endif
    
}
