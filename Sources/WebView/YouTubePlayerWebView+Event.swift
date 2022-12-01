import Foundation

// MARK: - YouTubePlayerWebView+Event

extension YouTubePlayerWebView {
    
    /// A YouTubePlayerWebView Event
    enum Event {
        /// Received JavaScriptEvent from YouTubePlayer
        case receivedJavaScriptEvent(YouTubePlayer.JavaScriptEvent)
        /// Did move to window
        case didMoveToWindow
        /// Did removed from window
        case didRemovedFromWindow
        /// The frame of the YouTubePlayerWebView changed
        case frameChanged(CGRect)
        /// Web content process did terminate
        case webContentProcessDidTerminate
    }
    
}

