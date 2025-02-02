import Foundation

// MARK: - YouTubePlayer+FullscreenMode

public extension YouTubePlayer {
    
    /// A YouTube player fullscreen mode.
    enum FullscreenMode: String, Codable, Hashable, Sendable, CaseIterable {
        /// System fullscreen mode (AVPlayerViewController).
        case system
        /// Web fullscreen mode (HTML5)
        case web
    }
    
}

// MARK: - Preferred

public extension YouTubePlayer.FullscreenMode {
    
    /// The preferred fullscreen mode based on the current operating system.
    ///
    /// - iOS: `.system`
    /// - macOS & visionOS: `.web`
    static let preferred: Self = {
        #if os(macOS) || os(visionOS)
        .web
        #else
        .system
        #endif
    }()
    
}
