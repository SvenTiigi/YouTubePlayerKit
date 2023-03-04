import Foundation

/// The YouTubePlayer 360 Degree Perspective API
/// - Read more: https://developers.google.com/youtube/iframe_api_reference#Spherical_Video_Controls
public extension YouTubePlayer {
    
    /// Retrieves properties that describe the viewer's current perspective
    /// - Parameter completion: The completion closure
    func get360DegreePerspective(
        completion: @escaping (Result<Perspective360Degree, APIError>) -> Void
    ) {
        self.webView.evaluate(
            javaScript: .player(function: "getSphericalProperties"),
            converter: .typeCast(
                to: [String: Any].self
            )
            .decode(),
            completion: completion
        )
    }
    
    #if compiler(>=5.5) && canImport(_Concurrency)
    /// Retrieves properties that describe the viewer's current perspective
    func get360DegreePerspective() async throws -> Perspective360Degree {
        try await withCheckedThrowingContinuation { continuation in
            self.get360DegreePerspective(completion: continuation.resume)
        }
    }
    #endif
    
    /// Sets the video orientation for playback of a 360° video
    /// - Parameter perspective360Degree: The Perspective360Degree
    func set(
        perspective360Degree: Perspective360Degree
    ) {
        // Verify YouTubePlayer Perspective360Degree can be decoded
        guard let jsonData = try? JSONEncoder().encode(perspective360Degree) else {
            // Otherwise return out of function
            return
        }
        // Initialize JSON string from data
        let jsonString = String(decoding: jsonData, as: UTF8.self)
        // Evaluate JavaScript
        self.webView.evaluate(
            javaScript: .player(
                function: "setSphericalProperties",
                parameters: jsonString
            )
        )
    }
    
}
