import Combine
import Foundation
import WebKit

// MARK: - YouTubePlayerWebView

/// The YouTubePlayer WebView
final class YouTubePlayerWebView: WKWebView {
    
    // MARK: Properties
    
    /// The YouTubePlayer
    var player: YouTubePlayer
    
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
