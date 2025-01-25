#if os(macOS)
import AppKit
#else
import UIKit
#endif

// MARK: - YouTubePlayerHostingBaseView

#if os(macOS)
/// The YouTubePlayerHostingBase NSView
public class YouTubePlayerHostingBaseView: NSView {}
#else
/// The YouTubePlayerHostingBase UIView
public class YouTubePlayerHostingBaseView: UIView {}
#endif

// MARK: - YouTubePlayerHostingView

/// The YouTube player hosting view.
public final class YouTubePlayerHostingView: YouTubePlayerHostingBaseView {
    
    // MARK: Properties
    
    /// The YouTubePlayer
    public let player: YouTubePlayer
    
    // MARK: Initializer
    
    /// Creates a new instance of ``YouTubePlayerHostingView``
    /// - Parameters:
    ///   - player: The YouTubePlayer
    public init(
        player: YouTubePlayer
    ) {
        self.player = player
        super.init(frame: .zero)
        self.addSubview(self.player.webView)
    }
    
    /// Initializer with NSCoder is unavailable.
    /// Use `init(player:)`
    @available(*, unavailable)
    public required init?(
        coder aDecoder: NSCoder
    ) { nil }
    
    /// Deinit
    deinit {
        Task { [weak player] in
            try? await player?.pause()
        }
    }
    
}
