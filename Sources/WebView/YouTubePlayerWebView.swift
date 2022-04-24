import Combine
import Foundation
import WebKit

// MARK: - YouTubePlayerWebView

/// The YouTubePlayer WebView
final class YouTubePlayerWebView: WKWebView {
    
    // MARK: Properties
    
    /// The YouTubePlayer
    var player: YouTubePlayer {
        didSet {
            // Verify YouTubePlayer reference has changed
            guard self.player !== oldValue else {
                // Otherwise return out of function
                return
            }
            // Re-Load Player
            self.loadPlayer()
        }
    }
    
    /// The origin URL
    private(set) lazy var originURL: URL? = Bundle
        .main
        .bundleIdentifier
        .flatMap { ["https://", $0.lowercased()].joined() }
        .flatMap(URL.init)
    
    /// The Layout Lifecycle Subject
    private lazy var layoutLifecycleSubject = PassthroughSubject<CGRect, Never>()
    
    /// The frame observation Cancellable
    private var frameObservation: AnyCancellable?
    
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
            configuration: .youTubePlayer
        )
        // Setup
        self.setup()
    }
    
    /// Initializer with NSCoder always returns nil
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: View-Lifecycle
    
    #if os(iOS)
    /// Layout Subviews
    override func layoutSubviews() {
        super.layoutSubviews()
        // Send frame on Layout Subject
        self.layoutLifecycleSubject.send(self.frame)
    }
    #elseif os(macOS)
    /// Perform layout
    override func layout() {
        super.layout()
        // Send frame on Layout Subject
        self.layoutLifecycleSubject.send(self.frame)
    }
    #endif
    
}

// MARK: - Setup

private extension YouTubePlayerWebView {
    
    /// Setup YouTubePlayerWebView
    func setup() {
        // Setup frame observation
        self.frameObservation = self
            .publisher(
                for: \.frame,
                options: [.new]
            )
            .merge(
                with: self.layoutLifecycleSubject
            )
            .map(\.size)
            .removeDuplicates()
            .sink { [weak self] frame in
                // Initialize parameters
                let parameters = [
                    frame.width,
                    frame.height
                ]
                .map(String.init)
                .joined(separator: ",")
                // Set YouTubePlayer Size
                self?.evaluate(
                    javaScript: "setYouTubePlayerSize(\(parameters));"
                )
            }
        // Set YouTubePlayerAPI on current Player
        self.player.api = self
        // Set navigation delegate
        self.navigationDelegate = self
        // Set ui delegate
        self.uiDelegate = self
        #if !os(macOS)
        // Set clear background color
        self.backgroundColor = .clear
        // Disable opaque
        self.isOpaque = false
        // Set autoresizing masks
        self.autoresizingMask = {
            #if os(macOS)
            return [.width, .height]
            #else
            return [.flexibleWidth, .flexibleHeight]
            #endif
        }()
        // Disable scrolling
        self.scrollView.isScrollEnabled = false
        // Disable bounces of ScrollView
        self.scrollView.bounces = false
        #endif
        // Load YouTubePlayer
        self.loadPlayer()
    }
    
}

// MARK: - WKWebViewConfiguration+youTubePlayer

private extension WKWebViewConfiguration {
    
    /// The YouTubePlayer WKWebViewConfiguration
    static var youTubePlayer: WKWebViewConfiguration {
        // Initialize WebView Configuration
        let configuration = WKWebViewConfiguration()
        #if !os(macOS)
        // Allows inline media playback
        configuration.allowsInlineMediaPlayback = true
        #endif
        // No media types requiring user action for playback
        configuration.mediaTypesRequiringUserActionForPlayback = []
        // Return configuration
        return configuration
    }
    
}
