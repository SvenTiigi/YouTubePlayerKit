import Foundation

// MARK: - YouTubePlayer+State

public extension YouTubePlayer {
    
    /// The YouTubePlayer State
    enum State: Hashable {
        /// Idle
        case idle
        /// Ready
        case ready
        /// Error
        case error(Error)
    }

}

// MARK: - State+isIdle

public extension YouTubePlayer.State {
    
    /// Bool value if is `idle`
    var isIdle: Bool {
        switch self {
        case .idle:
            return true
        default:
            return false
        }
    }
    
}

// MARK: - State+isReady

public extension YouTubePlayer.State {
    
    /// Bool value if is `ready`
    var isReady: Bool {
        switch self {
        case .ready:
            return true
        default:
            return false
        }
    }
    
}

// MARK: - State+isError

public extension YouTubePlayer.State {
    
    /// Bool value if is `error`
    var isError: Bool {
        switch self {
        case .error:
            return true
        default:
            return false
        }
    }
    
}

// MARK: - State+error

public extension YouTubePlayer.State {
    
    /// The YouTubePlayer Error, if available
    var error: YouTubePlayer.Error? {
        switch self {
        case .error(let error):
            return error
        default:
            return nil
        }
    }
    
}
