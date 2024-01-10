import Foundation

// MARK: - YouTubePlayer+PlaybackState

public extension YouTubePlayer {
    
    /// The YouTubePlayer PlaybackState
    enum PlaybackState: Int, Codable, Hashable, Sendable, CaseIterable {
        /// Unstarted
        case unstarted = -1
        /// Ended
        case ended = 0
        /// Playing
        case playing = 1
        /// Paused
        case paused = 2
        /// Buffering
        case buffering = 3
        /// Video cued
        case cued = 5
    }
    
}
