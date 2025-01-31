import Combine
import Foundation
import WebKit

// MARK: - YouTubePlayerWebView

/// A YouTube player web view.
final class YouTubePlayerWebView: WKWebView {
    
    // MARK: Properties
    
    /// The YouTubePlayer.
    private(set) weak var player: YouTubePlayer?
    
    /// The event subject..
    private(set) lazy var eventSubject = PassthroughSubject<Event, Never>()
    
    /// The layout lifecycle subject.
    private lazy var layoutLifecycleSubject = PassthroughSubject<CGRect, Never>()
    
    /// The cancellables.
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Initializer
    
    /// Creates a new instance of ``YouTubePlayer.WebView``
    /// - Parameter player: The YouTube player
    init(
        player: YouTubePlayer
    ) {
        self.player = player
        super.init(
            frame: .zero,
            configuration: {
                let configuration = WKWebViewConfiguration()
                // Do not persist cookies and website data storage to disk
                configuration.websiteDataStore = player.configuration.useNonPersistentWebsiteDataStore
                    ? .nonPersistent()
                    : .default()
                #if !os(macOS)
                // Set allows inline media playback
                configuration.allowsInlineMediaPlayback = player.configuration.allowsInlineMediaPlayback
                // Set allows picture in picture media playback
                configuration.allowsPictureInPictureMediaPlayback = player.configuration.allowsPictureInPictureMediaPlayback
                #endif
                // No media types requiring user action for playback
                configuration.mediaTypesRequiringUserActionForPlayback = .init()
                // Disable text interaction / selection
                configuration.preferences.isTextInteractionEnabled = false
                // Set HTML element fullscreen enabled if fullscreen mode is set to web
                let isElementFullscreenEnabled = player.configuration.fullscreenMode == .web
                if #available(iOS 15.4, macOS 12.3, visionOS 1.0, *) {
                    configuration.preferences.isElementFullscreenEnabled = isElementFullscreenEnabled
                } else {
                    configuration.preferences.setValue(isElementFullscreenEnabled, forKey: "fullScreenEnabled")
                }
                return configuration
            }()
        )
        // Setup
        self.setup(using: player)
        // Load
        try? self.load()
    }
    
    /// Initializer with NSCoder is unavailable.
    /// Use `init(player:)`
    @available(*, unavailable)
    required init?(
        coder aDecoder: NSCoder
    ) { nil }
    
    // MARK: View-Lifecycle
    
    #if os(macOS)
    /// Perform layout
    override func layout() {
        super.layout()
        // Send frame on Layout Subject
        self.layoutLifecycleSubject.send(self.frame)
    }
    #else
    /// Layout Subviews
    override func layoutSubviews() {
        super.layoutSubviews()
        // Send frame on Layout Subject
        self.layoutLifecycleSubject.send(self.frame)
    }
    #endif
    
    #if os(macOS)
    /// ScrollWheel Event
    /// - Parameter event: The NSEvent
    override func scrollWheel(with event: NSEvent) {
        // Explicity overriden without super invocation
        // to disable scrolling on macOS
        self.nextResponder?.scrollWheel(with: event)
    }
    #endif
    
    /// Sets a Boolean that indicates whether the scroll view automatically adjusts its content insets.
    /// - Parameter enabled: A Boolean if enabled.
    func setAutomaticallyAdjustsContentInsets(enabled: Bool) {
        #if os(macOS)
        self.enclosingScrollView?.automaticallyAdjustsContentInsets = enabled
        #else
        self.scrollView.contentInsetAdjustmentBehavior = enabled ? .automatic : .never
        #endif
    }
    
}

// MARK: - Setup

private extension YouTubePlayerWebView {
    
    /// Setups the web view.
    func setup(
        using player: YouTubePlayer
    ) {
        // Setup frame observation
        self.publisher(
            for: \.frame,
            options: [.new]
        )
        .dropFirst()
        .merge(
            with: self.layoutLifecycleSubject
        )
        .map(\.size)
        .removeDuplicates()
        .filter { $0 != .zero }
        .sink { size in
            // Set player size
            Task(priority: .userInitiated) { [weak self] in
                try? await self?.evaluate(
                    javaScript: .youTubePlayer(
                        functionName: "setSize",
                        parameters: [
                            String(
                                format: "%.1f",
                                size.width
                            ),
                            String(
                                format: "%.1f",
                                size.height
                            )
                        ]
                    ),
                    converter: .void
                )
            }
        }
        .store(in: &self.cancellables)
        // Set navigation delegate
        self.navigationDelegate = self
        // Set ui delegate
        self.uiDelegate = self
        // Disable link preview
        self.allowsLinkPreview = false
        // Disable gesture navigation
        self.allowsBackForwardNavigationGestures = false
        // Clear under page background color
        self.underPageBackgroundColor = .clear
        #if os(macOS)
        // Set clear layer background color
        self.layer?.backgroundColor = .clear
        // Hide scrollbars
        self.enclosingScrollView?.hasVerticalScroller = false
        self.enclosingScrollView?.hasHorizontalScroller = false
        // Disable magnification
        self.enclosingScrollView?.allowsMagnification = false
        self.allowsMagnification = false
        #else
        // Set clear background color
        self.backgroundColor = .clear
        // Disable opaque
        self.isOpaque = false
        // Disable scrolling
        self.scrollView.isScrollEnabled = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        // Disable bounces of ScrollView
        self.scrollView.bounces = false
        #endif
        // Initially set if content insets should be automatically adjusted
        self.setAutomaticallyAdjustsContentInsets(enabled: player.configuration.automaticallyAdjustsContentInsets)
        // Initially set custom user agent
        self.customUserAgent = player.configuration.customUserAgent
    }
    
}

// MARK: - Load

extension YouTubePlayerWebView {
    
    /// Loads the YouTube player.
    func load() throws {
        // Verify player is available
        guard let player = self.player else {
            // Otherwise throw error
            throw YouTubePlayer.APIError(
                reason: "YouTubePlayer deallocated"
            )
        }
        // Declare HTML string
        let htmlString: String
        do {
            // Initialize JSON encoded JavaScript player options
            let jsonEncodedJavaScriptPlayerOptions = String(
                decoding: try YouTubePlayer.JavaScriptPlayerOptions(
                    source: player.source,
                    parameters: player.parameters
                )
                .jsonEncode(
                    configuration: .init(
                        allowsInlineMediaPlayback: player.configuration.allowsInlineMediaPlayback
                    )
                ),
                as: UTF8.self
            )
            // Try to build HTML string.
            htmlString = try player
                .configuration
                .htmlBuilder(
                    jsonEncodedYouTubePlayerOptions: jsonEncodedJavaScriptPlayerOptions
                )
            // Log player options
            player
                .logger()?
                .debug(
                    """
                    Loading YouTube Player with options:
                    \(jsonEncodedJavaScriptPlayerOptions)
                    """
                )
        } catch {
            // Send error state
            player.stateSubject.send(
                .error(
                    .setupFailed(error)
                )
            )
            throw error
        }
        // Load HTML string
        self.loadHTMLString(
            htmlString,
            baseURL: player.parameters.originURL
        )
    }
    
}
