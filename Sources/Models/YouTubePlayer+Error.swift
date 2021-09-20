import Foundation

// MARK: - YouTubePlayer+Error

public extension YouTubePlayer {
    
    /// The YouTubePlayer Error
    enum Error: Int, Swift.Error, Codable, Hashable, CaseIterable {
        /// The request contains an invalid parameter value.
        /// For example, this error occurs if you specify a video ID that does not have 11 characters,
        /// or if the video ID contains invalid characters, such as exclamation points or asterisks.
        case invalidSource = 2
        /// The requested content cannot be played in an HTML5 player
        /// or another error related to the HTML5 player has occurred.
        case html5NotSupported = 5
        /// The video requested was not found.
        /// This error occurs when a video has been removed (for any reason) or has been marked as private.
        case notFound = 100
        /// The owner of the requested video does not allow it to be played in embedded players.
        case embeddedVideoPlayingNotAllowed = 101
        /// Player setup failed
        case setupFailed = -1
        /// The YouTube iFrame API JavaScript failed to load
        case iFrameAPIFailedToLoad = -2
    }
    
}
