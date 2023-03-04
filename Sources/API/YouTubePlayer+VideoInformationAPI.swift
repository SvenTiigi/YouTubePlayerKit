import Combine
import Foundation

/// The YouTubePlayer Video Information API
/// - Read more: https://developers.google.com/youtube/iframe_api_reference#Retrieving_video_information
public extension YouTubePlayer {
    
    /// Show Stats for Nerds which displays additional video information
    func showStatsForNerds() {
        self.webView.evaluate(
            javaScript: .player(function: "showVideoInfo")
        )
    }
    
    /// Hide Stats for Nerds
    func hideStatsForNerds() {
        self.webView.evaluate(
            javaScript: .player(function: "hideVideoInfo")
        )
    }
    
    /// Retrieve the YouTubePlayer Information
    /// - Parameter completion: The completion closure
    func getInformation(
        completion: @escaping (Result<Information, APIError>) -> Void
    ) {
        self.webView.evaluate(
            javaScript: .player("playerInfo"),
            converter: .typeCast(
                to: [String: Any].self
            )
            .decode(),
            completion: completion
        )
    }
    
    #if compiler(>=5.5) && canImport(_Concurrency)
    /// Retrieve the YouTubePlayer Information
    func getInformation() async throws -> Information {
        try await withCheckedThrowingContinuation { continuation in
            self.getInformation(completion: continuation.resume)
        }
    }
    #endif
    
    /// Retrieve the duration in seconds of the currently playing video
    /// - Parameter completion: The completion closure
    func getDuration(
        completion: @escaping (Result<Double, APIError>) -> Void
    ) {
        self.webView.evaluate(
            javaScript: .player(function: "getDuration"),
            converter: .typeCast(),
            completion: completion
        )
    }
    
    #if compiler(>=5.5) && canImport(_Concurrency)
    /// Returns the duration in seconds of the currently playing video
    func getDuration() async throws -> Double {
        try await withCheckedThrowingContinuation { continuation in
            self.getDuration(completion: continuation.resume)
        }
    }
    #endif
    
    /// A Publisher that emits the duration in seconds of the currently playing video
    var durationPublisher: AnyPublisher<Double, Never> {
        self.playbackStatePublisher
            .filter { $0 == .playing }
            .flatMap { _ in
                Future { [weak self] promise in
                    self?.getDuration { result in
                        guard case .success(let duration) = result else {
                            return
                        }
                        promise(.success(duration))
                    }
                }
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    /// Retrieve the YouTube.com URL for the currently loaded/playing video
    /// - Parameter completion: The completion closure
    func getVideoURL(
        completion: @escaping (Result<String, APIError>) -> Void
    ) {
        self.webView.evaluate(
            javaScript: .player(function: "getVideoUrl"),
            converter: .typeCast(),
            completion: completion
        )
    }
    
    #if compiler(>=5.5) && canImport(_Concurrency)
    /// Returns the YouTube.com URL for the currently loaded/playing video
    func getVideoURL() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            self.getVideoURL(completion: continuation.resume)
        }
    }
    #endif
    
    /// Retrieve the embed code for the currently loaded/playing video
    /// - Parameter completion: The completion closure
    func getVideoEmbedCode(
        completion: @escaping (Result<String, APIError>) -> Void
    ) {
        self.webView.evaluate(
            javaScript: .player(function: "getVideoEmbedCode"),
            converter: .typeCast(),
            completion: completion
        )
    }
    
    #if compiler(>=5.5) && canImport(_Concurrency)
    /// Returns the embed code for the currently loaded/playing video
    func getVideoEmbedCode() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            self.getVideoEmbedCode(completion: continuation.resume)
        }
    }
    #endif
    
}
