import Foundation

// MARK: - YouTubePlayer+Configuration+FullscreenMode

public extension YouTubePlayer.Configuration {
    
    /// A YouTubePlayer Configuration fullscreen mode.
    enum FullscreenMode: String, Codable, Hashable, Sendable, CaseIterable {
        /// System fullscreen mode (AVPlayerViewController).
        case system
        /// Web fullscreen mode (YouTube web player)
        case web
    }
    
}
