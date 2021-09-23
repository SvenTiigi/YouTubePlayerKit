#if !os(macOS)
import UIKit

// MARK: - YouTubePlayerViewController

/// The YouTubePlayer UIViewController
public final class YouTubePlayerViewController: UIViewController {
    
    // MARK: Properties
    
    /// The YouTubePlayerWebView
    private let webView: YouTubePlayerWebView
    
    /// The YouTubePlayer
    public var player: YouTubePlayer {
        self.webView.player
    }
    
    // MARK: Initializer
    
    /// Creates a new instance of `YouTubePlayer.ViewController`
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
#else
import AppKit

// MARK: - YouTubePlayerViewController

/// The YouTubePlayer UIViewController
final class YouTubePlayerViewController: NSViewController {
    
    // MARK: Properties
    
    /// The YouTubePlayerWebView
    private let webView: YouTubePlayerWebView
    
    /// The YouTubePlayer
    public var player: YouTubePlayer {
        self.webView.player
    }
    
    // MARK: Initializer
    
    /// Creates a new instance of `YouTubePlayer.ViewController`
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
    
    /// Initializer with NSCoder always returns nil
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: View-Lifecycle
    
    /// Creates the view that the controller manages
    override func loadView() {
        self.view = self.webView
    }
    
}
#endif
