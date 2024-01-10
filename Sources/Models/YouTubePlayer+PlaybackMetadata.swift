import Foundation

// MARK: - YouTubePlayer+PlaybackMetadata

public extension YouTubePlayer {
    
    /// The YouTubePlayer PlaybackMetadata
    struct PlaybackMetadata: Codable, Hashable, Sendable {
        
        // MARK: Properties
        
        /// The title of the playback/video
        public let title: String
        
        /// The optional author/creator of the playback/video
        public let author: String?
        
        // MARK: Initializer
        
        /// Creates a new instance of `YouTubePlayer.PlaybackMetadata`
        /// - Parameters:
        ///   - title: The title of the playback/video
        ///   - author: The optional author/creator of the playback/video
        public init(
            title: String,
            author: String? = nil
        ) {
            self.title = title
            self.author = author
        }
        
    }
    
}
