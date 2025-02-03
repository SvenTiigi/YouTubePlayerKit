import Combine
import Foundation

// MARK: - YouTubePlayer

/// A YouTube player that provides a native interface to the [YouTube iFrame Player API](https://developers.google.com/youtube/iframe_api_reference).
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
            // Reload the web view to apply the new parameters
            try? self.webView.load()
        }
    }
    
    /// The configuration.
    public let configuration: Configuration
    
    /// A Boolean value that determines whether logging is enabled.
    public var isLoggingEnabled: Bool {
        didSet {
            // Send object will change
            self.objectWillChange.send()
        }
    }
    
    /// The state subject.
    private(set) lazy var stateSubject = CurrentValueSubject<State, Never>(.idle)
    
    /// The playback state subject.
    private(set) lazy var playbackStateSubject = CurrentValueSubject<PlaybackState?, Never>(nil)
    
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
    }
    
}

// MARK: - Convenience Initializers

public extension YouTubePlayer {
    
    /// Creates a new instance of ``YouTubePlayer`` from a URL
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
    
    /// Creates a new instance of ``YouTubePlayer`` from a URL string.
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

// MARK: - Decodable

extension YouTubePlayer: Decodable {
    
    /// The coding keys.
    private enum CodingKeys: CodingKey {
        case source
        case parameters
        case configuration
        case isLoggingEnabled
    }
    
    /// Creates a new instance of ``YouTubePlayer``
    /// - Parameter decoder: The decoder.
    nonisolated public convenience init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            source: container.decodeIfPresent(Source.self, forKey: .source),
            parameters: container.decodeIfPresent(Parameters.self, forKey: .parameters) ?? .init(),
            configuration: container.decodeIfPresent(Configuration.self, forKey: .configuration) ?? .init(),
            isLoggingEnabled: container.decodeIfPresent(Bool.self, forKey: .isLoggingEnabled) ?? false
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
            && lhs.isLoggingEnabled == rhs.isLoggingEnabled
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
        hasher.combine(self.isLoggingEnabled)
    }
    
}

// MARK: - Handle Event

private extension YouTubePlayer {
    
    /// Handles a `YoutubePlayerWebView.Event`
    /// - Parameter webViewEvent: The web view event to handle.
    func handle(
        webViewEvent: YouTubePlayerWebView.Event
    ) {
        switch webViewEvent {
        case .receivedPlayerEvent(let playerEvent):
            // Handle player event
            self.handle(
                playerEvent: playerEvent
            )
        case .didFailProvisionalNavigation(let error):
            // Send did fail provisional navigation error
            self.stateSubject.send(
                .error(.didFailProvisionalNavigation(error))
            )
        case .didFailNavigation(let error):
            // Send did fail navigation error
            self.stateSubject.send(
                .error(.didFailNavigation(error))
            )
        case .webContentProcessDidTerminate:
            // Send web content process did terminate error
            self.stateSubject.send(
                .error(.webContentProcessDidTerminate)
            )
        }
    }
    
    /// Handles an incoming ``YouTubePlayer/Event``
    /// - Parameter event: The event to handle.
    func handle(
        playerEvent: Event
    ) {
        // Switch on event name
        switch playerEvent.name {
        case .iFrameApiFailedToLoad, .connectionIssue:
            // Send error state
            self.stateSubject.send(.error(.iFrameApiFailedToLoad))
        case .error:
            // Send error state
            playerEvent
                .data?
                .value(as: Int.self)
                .flatMap(YouTubePlayer.Error.init)
                .map { self.stateSubject.send(.error($0)) }
        case .ready:
            // Send ready state
            self.stateSubject.send(.ready)
        case .stateChange:
            // Verify YouTubePlayer PlaybackState is available
            guard let playbackState = playerEvent
                .data?
                .value(as: Int.self)
                .flatMap(PlaybackState.init(value:)) else {
                // Otherwise return out of function
                return
            }
            // Check if playback state is not equal to unstarted which mostly is an error
            // and the state is currently set to error
            if playbackState != .unstarted, case .error = self.state {
                // Send ready state as the player has recovered from an error
                self.stateSubject.send(.ready)
            }
            // Send PlaybackState
            self.playbackStateSubject.send(playbackState)
        case .reloadRequired:
            // Reload player
            Task { [weak self] in
                try? await self?.reload()
            }
        default:
            break
        }
    }
    
}
