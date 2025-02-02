import Foundation

// MARK: - YouTubePlayerWebView+Event

extension YouTubePlayerWebView {
    
    /// A YouTubePlayerWebView Event
    enum Event: Sendable {
        /// Received ``YouTubePlayer/Event``
        case receivedPlayerEvent(YouTubePlayer.Event)
        /// Did fail provisional navigation
        case didFailProvisionalNavigation(Error)
        /// Did fail navigation
        case didFailNavigation(Error)
        /// Web content process did terminate
        case webContentProcessDidTerminate
    }
    
}

// MARK: - Player Event

extension YouTubePlayerWebView.Event {
    
    /// The received ``YouTubePlayer/Event``, if available.
    var playerEvent: YouTubePlayer.Event? {
        if case .receivedPlayerEvent(let playerEvent) = self {
            return playerEvent
        } else {
            return nil
        }
    }
    
}
