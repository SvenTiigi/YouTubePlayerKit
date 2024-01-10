import Foundation

// MARK: - YouTubePlayer+Configuration+ProgressBarColor

public extension YouTubePlayer.Configuration {
    
    /// The YouTubePlayer Configuration ProgressBar Color
    enum ProgressBarColor: String, Codable, Hashable, Sendable, CaseIterable {
        /// YouTube red color
        case red
        /// White color
        case white
    }
    
}
