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
    
    /// The YouTubePlayerWebView
    private let webView: YouTubePlayerWebView
    
    /// The YouTubePlayer
    public var player: YouTubePlayer {
        get {
            self.webView.player
        }
        set {
            self.webView.player = newValue
        }
    }
    
    // MARK: Initializer
    
    /// Creates a new instance of `YouTubePlayerHostView`
    /// - Parameters:
    ///   - player: The YouTubePlayer
    public init(
        player: YouTubePlayer
    ) {
        self.webView = .init(player: player)
        super.init(frame: .zero)
        self.webView.autoresizingMask = {
            #if os(macOS)
            return [.width, .height]
            #else
            return [.flexibleWidth, .flexibleHeight]
            #endif
        }()
        self.addSubview(self.webView)
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
    
    /// Initializer with NSCoder always returns nil
    required init?(coder: NSCoder) {
        nil
    }
    
}
