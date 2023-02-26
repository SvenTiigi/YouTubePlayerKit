import Foundation

// MARK: - YouTubePlayer+Configuration+FullscreenMode

public extension YouTubePlayer.Configuration {
    
    /// A YouTubePlayer Configuration fullscreen mode.
    enum FullscreenMode: String, Codable, Hashable, CaseIterable {
        /// System fullscreen mode (AVPlayerViewController).
        case system
        /// YouTube fullscreen mode showing the YouTube player web user interface.
        case youTube
    }
    
}
