import Foundation

// MARK: - YouTubePlayer+State

public extension YouTubePlayer {
    
    /// A YouTube player state.
    enum State: Sendable {
        /// Idle
        case idle
        /// Ready
        case ready
        /// Error
        case error(Error)
    }

}

// MARK: - Equatable

extension YouTubePlayer.State: Equatable {
    
    /// Returns a Boolean value indicating whether two ``YouTubePlayer/State`` objects  are equal.
    /// - Parameters:
    ///   - lhs: A ``YouTubePlayer/State`` to compare.
    ///   - rhs: Another ``YouTubePlayer/State`` to compare.
    public static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        switch (lhs, rhs) {
        case (.idle, idle):
            return true
        case (.ready, .ready):
            return true
        case (.error(let lhs), .error(let rhs)):
            return String(describing: lhs) == String(describing: rhs)
        default:
            return false
        }
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
    
    /// The YouTube player error, if available.
    var error: YouTubePlayer.Error? {
        switch self {
        case .error(let error):
            return error
        default:
            return nil
        }
    }
    
}
