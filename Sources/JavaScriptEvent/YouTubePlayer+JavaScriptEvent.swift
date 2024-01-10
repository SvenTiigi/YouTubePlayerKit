import Foundation

// MARK: - YouTubePlayer+JavaScriptEvent

extension YouTubePlayer {
    
    /// A YouTubePlayer JavaScriptEvent
    struct JavaScriptEvent: Codable, Hashable, Sendable {
        
        /// The JavaScriptEvent Name
        let name: Name
        
        /// The optional data payload
        let data: String?
        
    }
    
}

// MARK: - JavaScriptEvent+init(url:)

extension YouTubePlayer.JavaScriptEvent {
    
    /// The YouTubePlayer JavaScript Event callback URL scheme
    private static let eventCallbackURLScheme = "youtubeplayer"
    
    /// The YouTubePlayer JavaScript Event data parameter name
    private static let eventCallbackDataParameterName = "data"
    
    /// Creates a new instance of `YouTubePlayer.HTML.JavaScriptEvent.Resolved` from an URL, if available
    /// - Parameters:
    ///   - url: The URL
    init?(url: URL) {
        // Verify scheme matches the JavaScriptEvent callback url scheme
        guard url.scheme == Self.eventCallbackURLScheme else {
            // Otherwise return nil
            return nil
        }
        // Verify host of URL is available
        guard let host = url.host else {
            // Otherwise return nil
            return nil
        }
        // Verify JavaScriptEvent Name can be initialized from raw value
        guard let name = YouTubePlayer.JavaScriptEvent.Name(rawValue: host) else {
            // Otherwise return nil
            return nil
        }
        // Initialize
        self.init(
            name: name,
            data: URLComponents(
                url: url,
                resolvingAgainstBaseURL: false
            )?
            .queryItems?
            .first { $0.name == Self.eventCallbackDataParameterName }?
            .value
            .flatMap { $0 == "null" ? nil : $0 }
        )
    }
    
}
