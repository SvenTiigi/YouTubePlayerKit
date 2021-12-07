#if os(macOS)
import AppKit
#else
import UIKit
#endif

// MARK: - YouTubePlayerHostBaseView

#if os(macOS)
/// The YouTubePlayerBase NSView
public class YouTubePlayerHostBaseView: NSView {}
#else
/// The YouTubePlayerBase UIView
public class YouTubePlayerHostBaseView: UIView {}
#endif

/// The YouTubePlayer HostView
public final class YouTubePlayerHostView: YouTubePlayerHostBaseView {
    
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
    public init(player: YouTubePlayer) {
        webView = .init(player: player)
        #if os(macOS)
        webView.autoresizingMask = [.width, .height]
        #else
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        #endif
        super.init(frame: .zero)
        
        addSubview(webView)
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
