import Foundation
import WebKit

// MARK: - YouTubePlayerWebView+Event

extension YouTubePlayerWebView {
    
    /// A YouTubePlayerWebView Event
    enum Event: Sendable {
        /// Received JavaScriptEvent from YouTubePlayer
        case receivedJavaScriptEvent(YouTubePlayer.JavaScriptEvent)
        /// The frame of the YouTubePlayerWebView changed
        case frameChanged(CGRect)
        /// Did fail provisional navigation
        case didFailProvisionalNavigation(Error)
        /// Web content process did terminate
        case webContentProcessDidTerminate
    }
    
}

