import Foundation

// MARK: - YouTubePlayer+PlaybackQuality

public extension YouTubePlayer {
    
    /// The YouTubePlayer PlaybackQuality
    enum PlaybackQuality: String, Codable, Hashable, Sendable, CaseIterable {
        /// Automatic
        case auto
        /// Small
        case small
        /// Medium
        case medium
        /// Large
        case large
        /// HD720
        case hd720
        /// HD1080
        case hd1080
        /// High resolution
        case highResolution = "highres"
        // Unknown
        case unknown
    }
    
}
