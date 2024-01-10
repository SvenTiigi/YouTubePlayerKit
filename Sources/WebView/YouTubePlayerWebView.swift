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
                // Disable text interaction / selection
                if #available(iOS 14.5, macOS 11.3, *) {
                    configuration.preferences.isTextInteractionEnabled = false
                }
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
    
    #if os(macOS)
    /// ScrollWheel Event
    /// - Parameter event: The NSEvent
    override func scrollWheel(with event: NSEvent) {
        // Explicity overriden without super invocation
        // to disable scrolling on macOS
        self.nextResponder?.scrollWheel(with: event)
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
        // Disable link preview
        self.allowsLinkPreview = false
        // Set autoresizing masks
        self.autoresizingMask = {
            #if os(macOS)
            return [.width, .height]
            #else
            return [.flexibleWidth, .flexibleHeight]
            #endif
        }()
        if #available(iOS 15.0, macOS 12.0, *) {
            self.underPageBackgroundColor = .clear
        }
        #if !os(macOS)
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
        // Set HTML element fullscreen enabled if fullscreen mode is set to web
        // which results in a fullscreen YouTube player web user interface
        // instead of the system fullscreen AVPlayerViewController
        self.configuration.preferences.isHTMLElementFullscreenEnabled = player.configuration.fullscreenMode == .web
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

// MARK: - WKPreferences+isFullscreenEnabled

private extension WKPreferences {
    
    /// The `fullScreenEnabled` key used as fallback under iOS 15.4 and macOS 12.3
    static let fullScreenEnabledKey = "fullScreenEnabled"
    
    /// Bool value if fullscreen HTML element is enabled.
    var isHTMLElementFullscreenEnabled: Bool {
        get {
            if #available(iOS 15.4, macOS 12.3, *) {
                return self.isElementFullscreenEnabled
            } else {
                return (self.value(forKey: Self.fullScreenEnabledKey) as? Bool) == true
            }
        }
        set {
            if #available(iOS 15.4, macOS 12.3, *) {
                self.isElementFullscreenEnabled = newValue
            } else {
                self.setValue(newValue, forKey: Self.fullScreenEnabledKey)
            }
        }
    }
    
}
