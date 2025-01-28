import Combine
import Foundation
import OSLog

// MARK: - YouTubePlayer

/// A YouTube player that provides a native interface to the [YouTube IFrame Player API](https://developers.google.com/youtube/iframe_api_reference).
///
/// Enables embedding and controlling YouTube videos in your app, including playback controls,
/// playlist management, and video information retrieval.
///
/// - Important: The following limitations apply:
/// Audio background playback is not supported,
/// Simultaneous playback of multiple YouTube players is not supported,
/// Controlling playback of 360° videos is not supported.
/// - SeeAlso: [YouTubePlayerKit on GitHub](https://github.com/SvenTiigi/YouTubePlayerKit?tab=readme-ov-file)
@MainActor
public final class YouTubePlayer: ObservableObject {
    
    // MARK: Properties
    
    /// The source.
    public internal(set) var source: Source? {
        didSet {
            // Verify that the source has changed.
            guard self.source != oldValue else {
                // Otherwise return out of function
                return
            }
            // Send object will change
            self.objectWillChange.send()
            // Send source.
            self.sourceSubject.send(self.source)
        }
    }
    
    /// The parameters.
    /// - Important: Updating this property will result in a reload of YouTube player.
    public var parameters: Parameters {
        didSet {
            // Verify that the parameters have changed.
            guard self.parameters != oldValue else {
                // Otherwise return out of function
                return
            }
            // Send object will change
            self.objectWillChange.send()
            // Reload the player to apply the new parameters
            Task { [weak self] in
                try? await self?.reload()
            }
        }
    }
    
    /// The configuration.
    public var configuration: Configuration {
        didSet {
            // Verify that the configuration has changed.
            guard self.configuration != oldValue else {
                // Otherwise return out of function
                return
            }
            // Send object will change
            self.objectWillChange.send()
            // Update automatically adjusts content insets, if needed
            if self.configuration.automaticallyAdjustsContentInsets != oldValue.automaticallyAdjustsContentInsets {
                self.webView.setAutomaticallyAdjustsContentInsets(
                    enabled: self.configuration.automaticallyAdjustsContentInsets
                )
            }
            // Update custom user agent, if needed
            if self.configuration.customUserAgent != oldValue.customUserAgent {
                self.webView.customUserAgent = self.configuration.customUserAgent
            }
        }
    }
    
    /// A Boolean value that determines whether logging is enabled.
    public var isLoggingEnabled: Bool {
        didSet {
            // Send object will change
            self.objectWillChange.send()
        }
    }
    
    /// The source subject.
    private(set) lazy var sourceSubject = CurrentValueSubject<Source?, Never>(nil)
    
    /// The state subject.
    private(set) lazy var stateSubject = CurrentValueSubject<State, Never>(.idle)
    
    /// The playback state subject.
    private(set) lazy var playbackStateSubject = CurrentValueSubject<PlaybackState?, Never>(nil)
    
    /// The playback quality subject.
    private(set) lazy var playbackQualitySubject = CurrentValueSubject<PlaybackQuality?, Never>(nil)
    
    /// The playback rate subject.
    private(set) lazy var playbackRateSubject = CurrentValueSubject<PlaybackRate?, Never>(nil)
    
    /// The autplay blocked subject.
    private(set) lazy var autoplayBlockedSubject = PassthroughSubject<Void, Never>()
    
    /// The YouTube player web view.
    private(set) lazy var webView: YouTubePlayerWebView = {
        let webView = YouTubePlayerWebView(player: self)
        self.webViewEventSubscription = webView
            .eventSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                self?.handle(
                    webViewEvent: event
                )
            }
        return webView
    }()
    
    /// The YouTubePlayer WebView Event Subscription
    private var webViewEventSubscription: AnyCancellable?
    
    // MARK: Initializer
    
    /// Creates a new instance of ``YouTubePlayer``
    /// - Parameters:
    ///   - source: The source. Default value `nil`
    ///   - parameters: The parameters. Default value `.init()`
    ///   - configuration: The configuration. Default value `.init()`
    ///   - isLoggingEnabled: A Boolean value that determines whether logging is enabled. Default value `false`
    nonisolated public init(
        source: Source? = nil,
        parameters: Parameters = .init(),
        configuration: Configuration = .init(),
        isLoggingEnabled: Bool = false
    ) {
        self.source = source
        self.parameters = parameters
        self.configuration = configuration
        self.isLoggingEnabled = isLoggingEnabled
        Task { @MainActor [weak self] in
            self?.sourceSubject.send(source)
        }
    }
    
}

// MARK: - Convenience Initializers

public extension YouTubePlayer {
    
    /// Creates a new instance of ``YouTubePlayer``
    /// - Parameters:
    ///   - url: The URL.
    nonisolated convenience init(
        url: URL
    ) {
        self.init(
            source: .init(url: url),
            parameters: .init(url: url) ?? .init(),
            configuration: .init(url: url) ?? .init()
        )
    }
    
    /// Creates a new instance of ``YouTubePlayer``
    /// - Parameters:
    ///   - urlString: The URL string.
    nonisolated convenience init(
        urlString: String
    ) {
        self.init(
            source: .init(urlString: urlString),
            parameters: .init(urlString: urlString) ?? .init(),
            configuration: .init(urlString: urlString) ?? .init()
        )
    }
    
}

// MARK: - ExpressibleByStringLiteral

extension YouTubePlayer: ExpressibleByStringLiteral {
    
    /// Creates a new instance of ``YouTubePlayer``
    /// - Parameter urlString: The url string.
    nonisolated public convenience init(
        stringLiteral urlString: String
    ) {
        self.init(
            urlString: urlString
        )
    }
    
}

// MARK: - Identifiable

extension YouTubePlayer: Identifiable {
    
    /// The stable identity of the entity associated with this instance.
    nonisolated public var id: ObjectIdentifier {
        .init(self)
    }
    
}

// MARK: - Equatable

extension YouTubePlayer: @preconcurrency Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (
        lhs: YouTubePlayer,
        rhs: YouTubePlayer
    ) -> Bool {
        lhs.source == rhs.source
            && lhs.parameters == rhs.parameters
            && lhs.configuration == rhs.configuration
    }

}

// MARK: - Hashable

extension YouTubePlayer: @preconcurrency Hashable {
    
    /// Hashes the essential components of this value by feeding them into the given hasher.
    /// - Parameter hasher: The hasher to use when combining the components of this instance.
    public func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(self.source)
        hasher.combine(self.parameters)
        hasher.combine(self.configuration)
    }
    
}

// MARK: - Reset State

extension YouTubePlayer {
    
    /// Resets the state of the subjects.
    func resetState() {
        self.stateSubject.send(.idle)
        self.playbackStateSubject.send(nil)
        self.playbackQualitySubject.send(nil)
        self.playbackRateSubject.send(nil)
    }
    
}

// MARK: - Handle WebView Event

private extension YouTubePlayer {
    
    /// Handles a ``YouTubePlayerWebView.Event``
    /// - Parameter webViewEvent: The web view event to handle.
    func handle(
        webViewEvent: YouTubePlayerWebView.Event
    ) {
        switch webViewEvent {
        case .receivedJavaScriptEvent(let javaScriptEvent):
            // Handle JavaScriptEvent
            self.handle(
                javaScriptEvent: javaScriptEvent
            )
        case .didFailProvisionalNavigation(let error):
            // Send web content process did terminate error
            self.stateSubject.send(
                .error(.didFailProvisionalNavigation(error))
            )
        case .webContentProcessDidTerminate:
            // Send web content process did terminate error
            self.stateSubject.send(
                .error(.webContentProcessDidTerminate)
            )
        }
    }
    
}

// MARK: - Handle JavaScript Event

private extension YouTubePlayer {
    
    /// Handles an incoming ``YouTubePlayer.JavaScriptEvent``
    /// - Parameter javaScriptEvent: The JavaScript event to handle.
    func handle(
        javaScriptEvent: YouTubePlayer.JavaScriptEvent
    ) {
        // Switch on Resolved JavaScriptEvent Name
        switch javaScriptEvent.name {
        case .onIframeApiReady:
            // Simply do nothing as we only
            // perform action on an `onReady` event
            break
        case .onIframeApiFailedToLoad:
            // Send error state
            self.stateSubject.send(.error(.iFrameApiFailedToLoad))
        case .onReady:
            // Send ready state
            self.stateSubject.send(.ready)
            // Check if autoPlay is enabled
            if self.parameters.autoPlay == true && self.source != nil && !self.isPlaying {
                // Play Video
                Task(
                    priority: .userInitiated
                ) { [weak self] in
                    try? await self?.play()
                }
            }
            // Initially load playback state
            Task { [weak self] in
                guard let playbackState = try? await self?.getPlaybackState() else {
                    return
                }
                self?.playbackStateSubject.send(playbackState)
            }
            // Initially load playback rate
            Task { [weak self] in
                guard let playbackRate = try? await self?.getPlaybackRate() else {
                    return
                }
                self?.playbackRateSubject.send(playbackRate)
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
                .flatMap(YouTubePlayer.PlaybackState.init(value:))
            }() else {
                // Otherwise return out of function
                return
            }
            // Check if state is set to error
            if playbackState != .unstarted, case .error = self.state {
                // Handle onReady state
                self.handle(javaScriptEvent: .init(name: .onReady))
            }
            // Send PlaybackState
            self.playbackStateSubject.send(playbackState)
        case .onPlaybackQualityChange:
            // Send PlaybackQuality
            javaScriptEvent
                .data
                .flatMap(YouTubePlayer.PlaybackQuality.init(name:))
                .map { self.playbackQualitySubject.send($0) }
        case .onPlaybackRateChange:
            // Send PlaybackRate
            javaScriptEvent
                .data
                .flatMap(Double.init)
                .flatMap(YouTubePlayer.PlaybackRate.init(value:))
                .map { self.playbackRateSubject.send($0) }
        case .onError:
            // Send error state
            javaScriptEvent
                .data
                .flatMap(Int.init)
                .flatMap(YouTubePlayer.Error.init)
                .map { .error($0) }
                .map { self.stateSubject.send($0) }
        case .onApiChange:
            self.stateSubject.send(.ready)
            self.playbackStateSubject.send(nil)
            self.playbackQualitySubject.send(nil)
            self.playbackRateSubject.send(nil)
            Task { [weak self] in
                guard let videoURL = try? await self?.getVideoURL(),
                      let source = YouTubePlayer.Source(urlString: videoURL) else {
                    return
                }
                self?.source = source
            }
        case .onAutoplayBlocked:
            // Send auto play blocked event
            self.autoplayBlockedSubject.send(())
        }
    }
    
}

// MARK: - Logger

extension YouTubePlayer {
    
    /// Returns a new logger instance if logging is enabled through `isLoggingEnabled`.
    func logger() -> os.Logger? {
        guard self.isLoggingEnabled else {
            return nil
        }
        return .init(
            subsystem: "YouTubePlayer",
            category: .init(describing: self.id)
        )
    }
    
}
