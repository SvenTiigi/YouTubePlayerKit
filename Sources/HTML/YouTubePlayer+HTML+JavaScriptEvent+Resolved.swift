import Foundation

// MARK: - YouTubePlayer+HTML+JavaScriptEvent+Resolved

extension YouTubePlayer.HTML.JavaScriptEvent {
    
    /// A resolved YouTubePlayer HTML JavaScriptEvent
    struct Resolved: Codable, Hashable {
        
        /// The JavaScriptEvent that has been resolved
        let event: YouTubePlayer.HTML.JavaScriptEvent
        
        /// The optional data parameter
        let data: String?
        
    }
    
}

// MARK: - Constants

private extension YouTubePlayer.HTML.JavaScriptEvent.Resolved {
    
    /// The YouTubePlayer JavaScript Event callback URL scheme
    static let eventCallbackURLScheme = "youtubeplayer"
    
    /// The YouTubePlayer JavaScript Event data parameter name
    static let eventCallbackDataParameterName = "data"
    
}

// MARK: - Failable initializer with URL

extension YouTubePlayer.HTML.JavaScriptEvent.Resolved {
    
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
        // Verify JavaScriptEvent can be initialized from raw value
        guard let event = YouTubePlayer.HTML.JavaScriptEvent(rawValue: host) else {
            // Otherwise return nil
            return nil
        }
        // Initialize
        self.init(
            event: event,
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
