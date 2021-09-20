import Foundation

// MARK: - YouTubePlayer+Configuration+ListType

extension YouTubePlayer.Configuration {
    
    /// The YouTubePlayer Configuration ListType
    enum ListType: String, Codable, Hashable, CaseIterable {
        /// Playlist
        case playlist
        /// User uploads / channel
        case userUploads = "user_uploads"
    }
    
}
