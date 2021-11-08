#if os(macOS)
import AppKit
#else
import UIKit
#endif

// MARK: - YouTubePlayerBaseViewController

#if os(macOS)
/// The YouTubePlayerBase NSViewController
public class YouTubePlayerBaseViewController: NSViewController {}
#else
/// The YouTubePlayerBase UIViewController
public class YouTubePlayerBaseViewController: UIViewController {}
#endif

// MARK: - YouTubePlayerViewController

/// The YouTubePlayer ViewController
public final class YouTubePlayerViewController: YouTubePlayerBaseViewController {
    
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
    
    /// Creates a new instance of `YouTubePlayerViewController`
    /// - Parameters:
    ///   - player: The YouTubePlayer
    public init(
        player: YouTubePlayer
    ) {
        // Initialize WebView
        self.webView = .init(player: player)
        // Super init
        super.init(nibName: nil, bundle: nil)
    }
    
    /// Creates a new instance of `YouTubePlayerViewController`
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
    
    // MARK: View-Lifecycle
    
    /// Creates the view that the controller manages
    public override func loadView() {
        self.view = self.webView
    }
    
}
