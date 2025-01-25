import Foundation
import OSLog

// MARK: - YouTubePlayer+Logger

extension YouTubePlayer {
    
    /// A YouTube logger namespace enum.
    enum Logger {
        
        /// Bool value if logging is enabled.
        @MainActor
        static var isEnabled = false
        
    }
    
}

// MARK: - Category

extension YouTubePlayer.Logger {
    
    /// Returns a new instance of ``Logger``, if logging is enabled.
    /// - Parameter player: The ``YouTubePlayer`` instance used as category.
    @MainActor
    static func category(
        _ player: YouTubePlayer?
    ) -> os.Logger? {
        guard self.isEnabled else {
            return nil
        }
        return .init(
            subsystem: "YouTubePlayerKit",
            category: player.flatMap { .init(describing: $0.id) } ?? "YouTubePlayer"
        )
    }
    
}
