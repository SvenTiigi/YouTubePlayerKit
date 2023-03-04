import Combine
import Foundation

// MARK: - YouTubePlayer

/// A YouTubePlayer
public final class YouTubePlayer: ObservableObject {
    
    // MARK: Properties
    
    /// The optional YouTubePlayer Source
    @Published
    public var source: Source? {
        didSet {
            // Verify Source has changed
            guard oldValue != self.source else {
                // Otherwise return out of function
                return
            }
            // Load Source
            self.load(
                source: self.source
            )
        }
    }
    
    /// The YouTubePlayer Configuration
    @Published
    public var configuration: Configuration {
        didSet {
            // Verify Configuration has changed
            guard oldValue != self.configuration else {
                // Otherwise return out of function
                return
            }
            // Update Configuration
            self.update(
                configuration: self.configuration
            )
        }
    }
    
    /// The YouTubePlayer State CurrentValueSubject
    private(set) lazy var playerStateSubject = CurrentValueSubject<State?, Never>(nil)
    
    /// The YouTubePlayer PlaybackState CurrentValueSubject
    private(set) lazy var playbackStateSubject = CurrentValueSubject<PlaybackState?, Never>(nil)
    
    /// The YouTubePlayer PlaybackQuality CurrentValueSubject
    private(set) lazy var playbackQualitySubject = CurrentValueSubject<PlaybackQuality?, Never>(nil)
    
    /// The YouTubePlayer PlaybackRate CurrentValueSubject
    private(set) lazy var playbackRateSubject = CurrentValueSubject<PlaybackRate?, Never>(nil)
    
    /// The YouTubePlayer WebView
    private(set) lazy var webView: YouTubePlayerWebView = {
        // Initialize a YouTubePlayerWebView
        let webView = YouTubePlayerWebView(player: self)
        // Subscribe to YouTubePlayerWebView Event Subject
        self.webViewEventSubscription = webView
            .eventSubject
            .sink { [weak self] event in
                // Handle YouTubePlayer WebView Event
                self?.handle(
                    webViewEvent: event
                )
            }
        return webView
    }()
    
    /// The YouTubePlayer WebView Event Subscription
    private var webViewEventSubscription: AnyCancellable?
    
    // MARK: Initializer
    
    /// Creates a new instance of `YouTubePlayer`
    /// - Parameters:
    ///   - source: The optional YouTubePlayer Source. Default value `nil`
    ///   - configuration: The YouTubePlayer Configuration. Default value `.init()`
    public init(
        source: Source? = nil,
        configuration: Configuration = .init()
    ) {
        self.source = source
        self.configuration = configuration
    }
    
}

// MARK: - YouTubePlayer+ExpressibleByStringLiteral

extension YouTubePlayer: ExpressibleByStringLiteral {
    
    /// Creates an instance initialized to the given string value.
    /// - Parameter value: The value of the new instance
    public convenience init(
        stringLiteral value: String
    ) {
        self.init(
            source: .url(value)
        )
    }
    
}

// MARK: - YouTubePlayer+Equatable

extension YouTubePlayer: Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (
        lhs: YouTubePlayer,
        rhs: YouTubePlayer
    ) -> Bool {
        lhs.source == rhs.source && lhs.configuration == rhs.configuration
    }

}

// MARK: - YouTubePlayer+Hashable

extension YouTubePlayer: Hashable {
    
    /// Hashes the essential components of this value by feeding them into the given hasher.
    /// - Parameter hasher: The hasher to use when combining the components of this instance.
    public func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(self.source)
        hasher.combine(self.configuration)
    }
    
}

// MARK: - YouTubePlayer+handle(webViewEvent:)

private extension YouTubePlayer {
    
    /// Handle a YouTubePlayerWebView Event
    /// - Parameter webViewEvent: The YouTubePlayerWebView Event
    func handle(
        webViewEvent: YouTubePlayerWebView.Event
    ) {
        switch webViewEvent {
        case .receivedJavaScriptEvent(let javaScriptEvent):
            // Send object will change event
            self.objectWillChange.send()
            // Handle JavaScriptEvent
            self.handle(
                javaScriptEvent: javaScriptEvent
            )
        case .frameChanged(let frame):
            // Initialize parameters
            let parameters = [
                frame.size.width,
                frame.size.height
            ]
            .map(String.init)
            .joined(separator: ",")
            // Set YouTubePlayer Size
            self.webView.evaluate(
                javaScript: .init("setYouTubePlayerSize(\(parameters));")
            )
        case .webContentProcessDidTerminate:
            // Send object will change event
            self.objectWillChange.send()
            // Send web content process did terminate error
            self.playerStateSubject.send(
                .error(.webContentProcessDidTerminate)
            )
        }
    }
    
}

// MARK: - YouTubePlayer+handle(javaScriptEvent:)

private extension YouTubePlayer {
    
    /// Handle incoming JavaScriptEvent
    /// - Parameter javaScriptEvent: The YouTubePlayer JavaScriptEvent
    func handle(
        javaScriptEvent: YouTubePlayer.JavaScriptEvent
    ) {
        // Switch on Resolved JavaScriptEvent Name
        switch javaScriptEvent.name {
        case .onIframeAPIReady:
            // Simply do nothing as we only
            // perform action on an `onReady` event
            break
        case .onIframeAPIFailedToLoad:
            // Send error state
            self.playerStateSubject.send(.error(.iFrameAPIFailedToLoad))
        case .onReady:
            // Send ready state
            self.playerStateSubject.send(.ready)
            // Check if autoPlay is enabled
            if self.configuration.autoPlay == true && self.source != nil {
                // Play Video
                self.play()
            }
            // Retrieve the current PlaybackRate
            self.getPlaybackRate { [weak self] result in
                // Verify PlaybackRate is available
                guard case .success(let playbackRate) = result else {
                    // Otherwise ignore the error and return out of function
                    return
                }
                // Send PlaybackRate
                self?.playbackRateSubject.send(playbackRate)
            }
            // Retrieve the current PlaybackState
            self.getPlaybackState { [weak self] result in
                // Verify PlaybackState is available
                guard case .success(let playbackState) = result else {
                    // Otherwise ignore the error and return out of function
                    return
                }
                // Send PlaybackState
                self?.playbackStateSubject.send(playbackState)
            }
        case .onStateChange:
            // Verify YouTubePlayer PlaybackState is available
            guard let playbackState: YouTubePlayer.PlaybackState? = {
                // Verify JavaScript Event Data is available
                guard let javaScriptEventData = javaScriptEvent.data else {
                    // Otherwise return ended state
                    return .ended
                }
                // Return PlaybackState from JavaScript Event Code
                return Int(
                    javaScriptEventData
                )
                .flatMap(YouTubePlayer.PlaybackState.init)
            }() else {
                // Otherwise return out of function
                return
            }
            // Send PlaybackState
            self.playbackStateSubject.send(playbackState)
        case .onPlaybackQualityChange:
            // Send PlaybackQuality
            javaScriptEvent
                .data
                .flatMap(YouTubePlayer.PlaybackQuality.init)
                .map { self.playbackQualitySubject.send($0) }
        case .onPlaybackRateChange:
            // Send PlaybackRate
            javaScriptEvent
                .data
                .flatMap(YouTubePlayer.PlaybackRate.init)
                .map { self.playbackRateSubject.send($0) }
        case .onError:
            // Send error state
            javaScriptEvent
                .data
                .flatMap(Int.init)
                .flatMap(YouTubePlayer.Error.init)
                .map { .error($0) }
                .map { self.playerStateSubject.send($0) }
        }
    }
    
}
