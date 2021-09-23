import Combine
import Foundation
import WebKit

// MARK: - YouTubePlayerWebView

/// The YouTubePlayer WebView
final class YouTubePlayerWebView: WKWebView {
    
    // MARK: Properties
    
    /// The YouTubePlayer
    let player: YouTubePlayer
    
    /// The updated YouTubePlayer Source which has
    /// been set by the `load(source:)` API
    private(set) var updatedSource: YouTubePlayer.Source?
    
    /// The origin URL
    private(set) lazy var originURL: URL? = Bundle
        .main
        .bundleIdentifier
        .flatMap { ["https://", $0.lowercased()].joined() }
        .flatMap(URL.init)
    
    // MARK: Subjects
    
    /// The YouTubePlayer State CurrentValueSubject
    private(set) lazy var playerStateSubject = CurrentValueSubject<YouTubePlayer.State?, Never>(nil)
    
    /// The YouTubePlayer PlaybackState CurrentValueSubject
    private(set) lazy var playbackStateSubject = CurrentValueSubject<YouTubePlayer.PlaybackState?, Never>(nil)
    
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
        // Set player
        self.player = player
        // Super init
        super.init(
            frame: .zero,
            configuration: {
                // Initialize WebView Configuration
                let configuration = WKWebViewConfiguration()
                #if !os(macOS)
                // Allows inline media playback
                configuration.allowsInlineMediaPlayback = true
                // Enable PiP-Playback
                configuration.allowsPictureInPictureMediaPlayback = true
                #endif
                // No media types requiring user action for playback
                configuration.mediaTypesRequiringUserActionForPlayback = []
                // Return configuration
                return configuration
            }()
        )
        // For each JavaScriptEvent
        for javaScriptEvent in YouTubePlayer.HTML.JavaScriptEvent.allCases {
            // Add message handler for JavaScriptEvent
            self.configuration
                .userContentController
                .add(
                    self,
                    name: javaScriptEvent.rawValue
                )
        }
        // Set YouTubePlayerAPI on current Player
        self.player.api = self
        #if !os(macOS)
        // Set clear background color
        self.backgroundColor = .clear
        // Disable opaque
        self.isOpaque = false
        // Set autoresizing masks
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // Disable scrolling
        self.scrollView.isScrollEnabled = false
        // Disable bounces of ScrollView
        self.scrollView.bounces = false
        #endif
        // Set navigation delegate
        self.navigationDelegate = self
        // Set ui delegate
        self.uiDelegate = self
        // Load Player and retain result
        let isPlayerLoaded = self.loadPlayer()
        // Check if Player is not loaded
        if !isPlayerLoaded {
            // Send setup failed error
            self.playerStateSubject.send(.error(.setupFailed))
        }
    }
    
    /// Initializer with NSCoder always returns nil
    required init?(coder: NSCoder) {
        nil
    }
    
}
