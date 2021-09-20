import Foundation

// MARK: - YouTubePlayer+VideoState

public extension YouTubePlayer {
    
    /// The YouTubePlayer VideoState
    enum VideoState: Int {
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
