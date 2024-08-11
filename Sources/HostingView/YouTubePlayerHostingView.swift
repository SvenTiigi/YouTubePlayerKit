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

/// The YouTubePlayer HostingView
public final class YouTubePlayerHostingView: YouTubePlayerHostingBaseView {
    
    // MARK: Properties
    
    /// The YouTubePlayer
    public let player: YouTubePlayer
    
    // MARK: Initializer
    
    /// Creates a new instance of `YouTubePlayerHostView`
    /// - Parameters:
    ///   - player: The YouTubePlayer
    public init(
        player: YouTubePlayer
    ) {
        self.player = player
        super.init(frame: .zero)
        self.addSubview(self.player.webView)
    }
    
    /// Creates a new instance of `YouTubePlayerHostView`
    /// - Parameters:
    ///   - source: The optional YouTubePlayer Source. Default value `nil`
    ///   - configuration: The YouTubePlayer Configuration. Default value `.init()`
    public convenience init(
        source: YouTubePlayer.Source? = nil,
        configuration: YouTubePlayer.Configuration = .init()
    ) {
        self.init(
            player: .init(
                source: source,
                configuration: configuration
            )
        )
    }
    
    /// Initializer with NSCoder is unavailable.
    /// Use `init(player:)`
    @available(*, unavailable)
    public required init?(
        coder aDecoder: NSCoder
    ) { nil }
    
    /// Deinit
    deinit {
        self.player.pause()
    }
    
}
