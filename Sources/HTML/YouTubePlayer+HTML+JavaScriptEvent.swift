import Foundation

// MARK: - YouTubePlayer+HTML+JavaScriptEvent

extension YouTubePlayer.HTML {
    
    /// The YouTubePlayer HTML JavaScript Event
    enum JavaScriptEvent: String, Codable, Hashable, CaseIterable {
        /// iFrame API is ready
        case onIframeAPIReady
        /// iFrame API failed to load
        case onIframeAPIFailedToLoad
        /// Ready
        case onReady
        /// State change
        case onStateChange
        /// Playback quality change
        case onPlaybackQualityChange
        /// Playback rate change
        case onPlaybackRateChange
        /// Error
        case onError
    }
    
}

// MARK: - Callback Registration

extension YouTubePlayer.HTML.JavaScriptEvent {
    
    /// The JavaScriptEvent Callback Registration Dictionary
    static var callbackRegistration: [String: String] {
        Self
            .allCases
            .filter { event in
                event != .onIframeAPIReady
                    || event != .onIframeAPIFailedToLoad
            }
            .reduce(
                into: .init()
            ) { result, event in
                result[event.rawValue] = event.rawValue
            }
    }
    
}

// MARK: - Initializer with URL

extension YouTubePlayer.HTML.JavaScriptEvent {
    
    /// Creates a new instance of `YouTubePlayer.JavaScriptEvent` from an URL, if available
    /// - Parameters:
    ///   - url: The URL
    init?(url: URL) {
        // Verify scheme matches the JavaScriptEvent callback url scheme
        guard url.scheme == YouTubePlayer.HTML.Constants.javaScriptEventCallbackURLScheme else {
            // Otherwise return nil
            return nil
        }
        // Verify host of URL is available
        guard let host = url.host else {
            // Otherwise return nil
            return nil
        }
        // Initialize with host as raw value
        self.init(rawValue: host)
    }
    
}

// MARK: - Extract Data Parameter

extension YouTubePlayer.HTML.JavaScriptEvent {
    
    /// Extract JavaScriptEvent Parameter from an URL, if available
    /// - Parameter url: The URL
    /// - Returns: The JavaScriptEvent Parameter
    static func extractParameter(
        from url: URL
    ) -> String? {
        URLComponents(
            url: url,
            resolvingAgainstBaseURL: false
        )?
        .queryItems?
        .first { queryItem in
            queryItem.name == YouTubePlayer.HTML.Constants.javaScriptEventDataParameterName
        }?
        .value
        .flatMap { $0 == "null" ? nil : $0 }
    }
    
}
