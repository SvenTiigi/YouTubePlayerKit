import Combine
import Foundation
import WebKit

// MARK: - YouTubePlayerWebView

/// The YouTubePlayer WebView
final class YouTubePlayerWebView: WKWebView {
    
    // MARK: Properties
    
    /// The YouTubePlayer
    let player: YouTubePlayer
    
    /// The origin URL
    private(set) lazy var originURL: URL? = Bundle
        .main
        .bundleIdentifier
        .flatMap { ["https://", $0.lowercased()].joined() }
        .flatMap(URL.init)
    
    // MARK: Subjects
    
    /// The YouTubePlayer State CurrentValueSubject
    private(set) lazy var stateSubject = CurrentValueSubject<YouTubePlayer.State?, Never>(nil)
    
    /// The YouTubePlayer VideoState CurrentValueSubject
    private(set) lazy var videoStateSubject = CurrentValueSubject<YouTubePlayer.VideoState?, Never>(nil)
    
    /// The YouTubePlayer PlaybackQuality CurrentValueSubject
    private(set) lazy var playbackQualitySubject = CurrentValueSubject<YouTubePlayer.PlaybackQuality?, Never>(nil)
    
    /// The YouTubePlayer PlaybackRate CurrentValueSubject
    private(set) lazy var playbackRateSubject = CurrentValueSubject<YouTubePlayer.PlaybackRate?, Never>(nil)
    
    // MARK: Initializer
    
    /// Creates a new instance of `YouTubePlayer.WebView`
    /// - Parameter player: The YouTubePlayer
    init(
        player: YouTubePlayer
    ) {
        self.player = player
        super.init(
            frame: .zero,
            configuration: {
                let configuration = WKWebViewConfiguration()
                configuration.allowsInlineMediaPlayback = true
                configuration.mediaTypesRequiringUserActionForPlayback = []
                return configuration
            }()
        )
        self.player.api = self
        self.player.configuration.isUserInteractionEnabled.flatMap {
            self.isUserInteractionEnabled = $0
        }
        self.backgroundColor = .clear
        self.isOpaque = false
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.scrollView.isScrollEnabled = false
        self.scrollView.bounces = false
        self.navigationDelegate = self
        self.uiDelegate = self
        // Load Player and retain result
        let isPlayerLoaded = self.loadPlayer()
        // Check if Player is not loaded
        if !isPlayerLoaded {
            // Send setup failed error
            self.stateSubject.send(.error(.setupFailed))
        }
    }
    
    /// Initializer with NSCoder always returns nil
    required init?(coder: NSCoder) {
        nil
    }
    
    /// Deinit
    deinit {
        // Stop Player
        self.stop()
        // Destroy Player
        self.evaluate(
            javaScript: "player.destroy();"
        )
    }
    
}

// MARK: - YouTubePlayerWebView+loadPlayer

private extension YouTubePlayerWebView {
    
    /// Load Player
    /// - Returns: A Bool value if the YouTube player was successfully loaded
    @discardableResult
    func loadPlayer() -> Bool {
        // Verify YouTube Player HTML is available
        guard let youTubePlayerHTML = YouTubePlayer.HTML.contents(
            for: self.player,
            originURL: self.originURL
        ) else {
            // Otherwise return failure
            return false
        }
        // Load HTML string
        self.loadHTMLString(
            youTubePlayerHTML,
            baseURL: self.originURL
        )
        // Return success
        return true
    }
    
}

// MARK: - YouTubePlayerWebView+evaluate

extension YouTubePlayerWebView {
    
    /// Evaluates the specified JavaScript string
    /// - Parameters:
    ///   - javaScript: The JavaScript string
    ///   - completion: The optional completion closure
    func evaluate(
        javaScript: String,
        completion: ((Result<Any?, Error>) -> Void)? = nil
    ) {
        self.evaluateJavaScript(
            javaScript
        ) { result, error in
            completion?(
                error.flatMap { .failure($0) }
                    ?? .success(result)
            )
        }
    }
    
}

// MARK: - YouTubePlayerWebView+JavaScriptError

extension YouTubePlayerWebView {
    
    /// A JavaScript Error
    struct JavaScriptError: Error {
        
        /// The reason
        let reason: String
        
    }
    
}
