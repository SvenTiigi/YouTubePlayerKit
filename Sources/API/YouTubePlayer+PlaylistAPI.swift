import Foundation

/// The YouTubePlayer Playlist API
/// - Read more: https://developers.google.com/youtube/iframe_api_reference#playing-a-video-in-a-playlist
public extension YouTubePlayer {
    
    /// This function loads and plays the next video in the playlist
    /// - Parameter completion: The completion closure
    func nextVideo(
        completion: ((Result<Void, APIError>) -> Void)? = nil
    ) {
        self.webView.evaluate(
            javaScript: .player(function: "nextVideo"),
            completion: completion
        )
    }
    
    #if compiler(>=5.5) && canImport(_Concurrency)
    /// This function loads and plays the next video in the playlist
    func nextVideo() async throws {
        try await withCheckedThrowingContinuation { continuation in
            self.nextVideo(
                completion: continuation.resume(with:)
            )
        }
    }
    #endif
    
    /// This function loads and plays the previous video in the playlist
    /// - Parameter completion: The completion closure
    func previousVideo(
        completion: ((Result<Void, APIError>) -> Void)? = nil
    ) {
        self.webView.evaluate(
            javaScript: .player(function: "previousVideo"),
            completion: completion
        )
    }
    
    #if compiler(>=5.5) && canImport(_Concurrency)
    /// This function loads and plays the previous video in the playlist
    func previousVideo() async throws {
        try await withCheckedThrowingContinuation { continuation in
            self.previousVideo(
                completion: continuation.resume(with:)
            )
        }
    }
    #endif
    
    /// This function loads and plays the specified video in the playlist
    /// - Parameters:
    ///   - index: The index of the video that you want to play in the playlist
    ///   - completion: The completion closure
    func playVideo(
        at index: Int,
        completion: ((Result<Void, APIError>) -> Void)? = nil
    ) {
        self.webView.evaluate(
            javaScript: .player(
                function: "playVideoAt",
                parameters: String(index)
            ),
            completion: completion
        )
    }
    
    #if compiler(>=5.5) && canImport(_Concurrency)
    /// This function loads and plays the specified video in the playlist
    /// - Parameters:
    ///   - index: The index of the video that you want to play in the playlist
    func playVideo(
        at index: Int
    ) async throws {
        try await withCheckedThrowingContinuation { continuation in
            self.playVideo(
                at: index,
                completion: continuation.resume(with:)
            )
        }
    }
    #endif
    
    /// This function indicates whether the video player should continuously play a playlist
    /// or if it should stop playing after the last video in the playlist ends
    /// - Parameters:
    ///   - enabled: Bool value if is enabled
    ///   - completion: The completion closure
    func setLoop(
        enabled: Bool,
        completion: ((Result<Void, APIError>) -> Void)? = nil
    ) {
        self.webView.evaluate(
            javaScript: .player(
                function: "setLoop",
                parameters: String(enabled)
            ),
            completion: completion
        )
    }
    
    #if compiler(>=5.5) && canImport(_Concurrency)
    /// This function indicates whether the video player should continuously play a playlist
    /// or if it should stop playing after the last video in the playlist ends
    /// - Parameters:
    ///   - enabled: Bool value if is enabled
    func setLoop(
        enabled: Bool
    ) async throws {
        try await withCheckedThrowingContinuation { continuation in
            self.setLoop(
                enabled: enabled,
                completion: continuation.resume(with:)
            )
        }
    }
    #endif
    
    /// This function indicates whether a playlist's videos should be shuffled
    /// so that they play back in an order different from the one that the playlist creator designated
    /// - Parameters:
    ///   - enabled: Bool value if is enabled
    ///   - completion: The completion closure
    func setShuffle(
        enabled: Bool,
        completion: ((Result<Void, APIError>) -> Void)? = nil
    ) {
        self.webView.evaluate(
            javaScript: .player(
                function: "setShuffle",
                parameters: String(enabled)
            ),
            completion: completion
        )
    }
    
    #if compiler(>=5.5) && canImport(_Concurrency)
    /// This function indicates whether a playlist's videos should be shuffled
    /// so that they play back in an order different from the one that the playlist creator designated
    /// - Parameters:
    ///   - enabled: Bool value if is enabled
    func setShuffle(
        enabled: Bool
    ) async throws {
        try await withCheckedThrowingContinuation { continuation in
            self.setShuffle(
                enabled: enabled,
                completion: continuation.resume(with:)
            )
        }
    }
    #endif
    
    /// Retrieve an array of the video IDs in the playlist as they are currently ordered
    /// - Parameter completion: The completion closure
    func getPlaylist(
        completion: @escaping (Result<[String], APIError>) -> Void
    ) {
        self.webView.evaluate(
            javaScript: .player(function: "getPlaylist"),
            converter: .typeCast(),
            completion: completion
        )
    }
    
    #if compiler(>=5.5) && canImport(_Concurrency)
    /// This function returns an array of the video IDs in the playlist as they are currently ordered
    func getPlaylist() async throws -> [String] {
        try await withCheckedThrowingContinuation { continuation in
            self.getPlaylist(
                completion: continuation.resume
            )
        }
    }
    #endif
    
    /// Retrieve the index of the playlist video that is currently playing.
    /// - Parameter completion: The completion closure
    func getPlaylistIndex(
        completion: @escaping (Result<Int, APIError>) -> Void
    ) {
        self.webView.evaluate(
            javaScript: .player(function: "getPlaylistIndex"),
            converter: .typeCast(),
            completion: completion
        )
    }
    
    #if compiler(>=5.5) && canImport(_Concurrency)
    /// This function returns the index of the playlist video that is currently playing.
    func getPlaylistIndex() async throws -> Int {
        try await withCheckedThrowingContinuation { continuation in
            self.getPlaylistIndex(
                completion: continuation.resume
            )
        }
    }
    #endif
    
}
