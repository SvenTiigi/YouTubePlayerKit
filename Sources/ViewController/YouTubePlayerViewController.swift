import UIKit
import WebKit

// MARK: - YouTubePlayerViewController

/// The YouTubePlayer UIViewController
public final class YouTubePlayerViewController: UIViewController {
    
    // MARK: Properties
    
    /// The YouTubePlayerWebView
    private let webView: YouTubePlayerWebView
    
    /// The YouTubePlayer
    public var player: YouTubePlayer {
        get {
            self.webView.player
        }
        set {
            newValue.api = self.webView
            self.webView.player = newValue
        }
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
        // Load Player and retain result
        let isPlayerLoaded = self.loadPlayer()
        // Check if Player is not loaded
        if !isPlayerLoaded {
            // Send setup failed error
            self.webView.stateSubject.send(.error(.setupFailed))
        }
    }
    
    /// Initializer with NSCoder always returns nil
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: View-Lifecycle
    
    /// Creates the view that the controller manages.
    public override func loadView() {
        self.view = self.webView
    }
    
}

// MARK: - Load Player

private extension YouTubePlayerViewController {
    
    /// Load Player
    /// - Returns: A Bool value if the YouTube player was successfully loaded
    @discardableResult
    func loadPlayer() -> Bool {
        // Verify YouTube Player HTML is available
        guard let youTubePlayerHTML = YouTubePlayer.HTML.contents(
            for: self.player,
            originURL: self.webView.originURL
        ) else {
            // Otherwise return failure
            return false
        }
        // Load HTML string
        self.webView.loadHTMLString(
            youTubePlayerHTML,
            baseURL: self.webView.originURL
        )
        // Return success
        return true
    }
    
}
