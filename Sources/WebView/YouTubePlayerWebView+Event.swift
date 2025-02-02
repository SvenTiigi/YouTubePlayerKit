import Foundation

// MARK: - YouTubePlayerWebView+Event

extension YouTubePlayerWebView {
    
    /// A YouTubePlayerWebView Event
    enum Event: Sendable {
        /// Received ``YouTubePlayer/Event``
        case receivedEvent(YouTubePlayer.Event)
        /// Did fail provisional navigation
        case didFailProvisionalNavigation(Error)
        /// Did fail navigation
        case didFailNavigation(Error)
        /// Web content process did terminate
        case webContentProcessDidTerminate
    }
    
}

// MARK: - Event

extension YouTubePlayerWebView.Event {
    
    /// The received ``YouTubePlayer/Event``, if available.
    var event: YouTubePlayer.Event? {
        if case .receivedEvent(let event) = self {
            return event
        } else {
            return nil
        }
    }
    
}
