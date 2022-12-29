import Combine
import Foundation
import WebKit

// MARK: - YouTubePlayerWebView

/// The YouTubePlayer WebView
final class YouTubePlayerWebView: WKWebView {
    
    // MARK: Properties
    
    /// The YouTubePlayer
    private(set) weak var player: YouTubePlayer?
    
    /// The origin URL
    private(set) lazy var originURL: URL? = Bundle
        .main
        .bundleIdentifier
        .flatMap { ["https://", $0.lowercased()].joined() }
        .flatMap(URL.init)
    
    /// The YouTubePlayerWebView Event PassthroughSubject
    private(set) lazy var eventSubject = PassthroughSubject<Event, Never>()
    
    /// The Layout Lifecycle Subject
    private lazy var layoutLifecycleSubject = PassthroughSubject<CGRect, Never>()
    
    /// The cancellables
    var cancellables = Set<AnyCancellable>()
    
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
                #endif
                // No media types requiring user action for playback
                configuration.mediaTypesRequiringUserActionForPlayback = []
                // Return configuration
                return configuration
            }()
        )
        // Setup
        self.setup()
        // Load
        self.load(using: player)
    }
    
    /// Initializer with NSCoder is unavailable.
    /// Use `init(player:)`
    @available(*, unavailable)
    required init?(
        coder aDecoder: NSCoder
    ) { nil }
    
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
        self.publisher(
            for: \.frame,
            options: [.new]
        )
        .merge(
            with: self.layoutLifecycleSubject
        )
        .removeDuplicates()
        .sink { [weak self] frame in
            // Send frame changed event
            self?.eventSubject.send(
                .frameChanged(frame)
            )
        }
        .store(in: &self.cancellables)
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
    }
    
}

// MARK: - YouTubePlayerWebView+loadPlayer

extension YouTubePlayerWebView {
    
    /// Load the YouTubePlayer to this WKWebView
    /// - Returns: A Bool value if the YouTube player has been successfully loaded
    @discardableResult
    func load(
        using player: YouTubePlayer
    ) -> Bool {
        // Declare YouTubePlayer HTML
        let youTubePlayerHTML: YouTubePlayer.HTML
        do {
            // Try to initialize YouTubePlayer HTML
            youTubePlayerHTML = try .init(
                options: .init(
                    playerSource: player.source,
                    playerConfiguration: player.configuration,
                    originURL: self.originURL
                )
            )
        } catch {
            // Send error state
            player.playerStateSubject.send(
                .error(
                    .setupFailed(error)
                )
            )
            // Return false as setup has failed
            return false
        }
        // Update player
        self.player = player
        #if !os(macOS)
        // Update allows Picture-in-Picture media playback
        self.configuration.allowsPictureInPictureMediaPlayback = player
            .configuration
            .allowsPictureInPictureMediaPlayback ?? true
        // Update contentInsetAdjustmentBehavior
        self.scrollView.contentInsetAdjustmentBehavior = player
            .configuration
            .automaticallyAdjustsContentInsets
            .flatMap { $0 ? .automatic : .never }
            ?? .automatic
        #else
        // Update automaticallyAdjustsContentInsets
        self.enclosingScrollView?.automaticallyAdjustsContentInsets = player
            .configuration
            .automaticallyAdjustsContentInsets
            ?? true
        #endif
        // Set custom user agent
        self.customUserAgent = player.configuration.customUserAgent
        // Load HTML string
        self.loadHTMLString(
            youTubePlayerHTML.contents,
            baseURL: self.originURL
        )
        // Return success
        return true
    }
    
}
