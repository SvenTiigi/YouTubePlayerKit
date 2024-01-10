import Foundation

// MARK: - YouTubePlayer+Error

public extension YouTubePlayer {
    
    /// The YouTubePlayer Error
    enum Error: Swift.Error, Sendable {
        /// Player setup failed with Error
        case setupFailed(Swift.Error)
        /// The web views underlying web content process was terminated
        case webContentProcessDidTerminate
        /// The YouTube iFrame API JavaScript failed to load
        case iFrameAPIFailedToLoad
        /// The request contains an invalid parameter value.
        /// For example, this error occurs if you specify a video ID that does not have 11 characters,
        /// or if the video ID contains invalid characters, such as exclamation points or asterisks.
        case invalidSource
        /// The requested content cannot be played in an HTML5 player
        /// or another error related to the HTML5 player has occurred.
        case html5NotSupported
        /// The video requested was not found.
        /// This error occurs when a video has been removed (for any reason) or has been marked as private.
        case notFound
        /// The owner of the requested video does not allow it to be played in embedded players.
        case embeddedVideoPlayingNotAllowed
    }
    
}

// MARK: - Error+init(errorCode:)

extension YouTubePlayer.Error {
    
    /// The ErrorCodes Dictionary
    private static let errorCodes: [Int: Self] = [
        2: .invalidSource,
        5: .html5NotSupported,
        100: .notFound,
        101: .embeddedVideoPlayingNotAllowed,
        150: .embeddedVideoPlayingNotAllowed
    ]
    
    /// Creates a new instance of `YouTubePlayer.Error` from a given error code
    /// - Parameters:
    ///   - errorCode: The error code integer value
    init?(
        errorCode: Int
    ) {
        // Verify error is available for a given error code
        guard let error = Self.errorCodes[errorCode] else {
            // Otherwise return nil
            return nil
        }
        // Initialize
        self = error
    }
    
}
