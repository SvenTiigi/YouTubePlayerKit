import Foundation

// MARK: - YouTubePlayer+Event+Name

public extension YouTubePlayer.Event {

    /// An extensible YouTube player event name.
    ///
    /// Use the well-known constants or create a name for a newly introduced event.
    /// Register additional events through ``YouTubePlayer/HTMLBuilder/additionalEventNames``.
    struct Name: RawRepresentable, Hashable, Sendable {

        // MARK: Properties

        /// The event name supplied by the YouTube IFrame API.
        public var rawValue: String

        // MARK: Initializer

        /// Creates an event name, including names not yet known to this package.
        /// - Parameter rawValue: The event name supplied by the YouTube IFrame API.
        public init(
            rawValue: String
        ) {
            self.rawValue = rawValue
        }

    }

}

// MARK: - Well-Known Events

public extension YouTubePlayer.Event.Name {

    // MARK: Custom Events

    /// Fired when the YouTube IFrame API has successfully loaded and initialized.
    /// - Important: A custom event emitted after the `YT.Player` has been initialized.
    static let iFrameApiReady: Self = "onIframeApiReady"

    /// Fired if the YouTube IFrame API fails to load.
    /// - Important: A custom event emitted when an error occurred loading the YouTube player iFrame API JavaScript.
    static let iFrameApiFailedToLoad: Self = "onIframeApiFailedToLoad"

    // MARK: Official Events
    
    /// Fired when an error occurs during player operation.
    static let error: Self = "onError"

    /// Fired when the YouTube player is fully initialized and ready to accept API commands.
    static let ready: Self = "onReady"

    /// Fired when a change occurs in the YouTube player iFrame API
    static let apiChange: Self = "onApiChange"

    /// Fired when the player's state changes (e.g., unstarted, playing, paused, buffering, ended).
    static let stateChange: Self = "onStateChange"

    /// Fired when the playback quality changes (for example, due to network conditions or manual change by the user).
    static let playbackQualityChange: Self = "onPlaybackQualityChange"

    /// Fired when the playback rate (speed) is changed.
    static let playbackRateChange: Self = "onPlaybackRateChange"

    /// Fired when an autoplay attempt is blocked by the browser or user settings.
    static let autoplayBlocked: Self = "onAutoplayBlocked"

    // MARK: Unofficial Events

    /// Fired when the player enters or exits fullscreen mode.
    /// - Warning: This event is unofficial and its behavior and availability may change.
    static let fullscreenChange: Self = "onFullscreenChange"

    /// Fired when the player's volume level or mute state changes.
    /// - Warning: This event is unofficial and its behavior and availability may vary.
    static let volumeChange: Self = "onVolumeChange"

    /// Fired when there is a change in video metadata (such as title or description updates).
    /// - Warning: This event is unofficial and its behavior and availability may change.
    static let videoDataChange: Self = "onVideoDataChange"

    /// Fired when the playlist associated with the player is updated or modified.
    /// - Warning: This event is unofficial and its behavior and availability may change.
    static let playlistUpdate: Self = "onPlaylistUpdate"

    /// Fired when an automatic navigation pause is requested to temporarily halt auto–advance.
    /// - Warning: This event is unofficial and its behavior and availability may change.
    static let autoNavigationPauseRequest: Self = "onAutonavPauseRequest"

    /// Fired to indicate the buffering progress (loaded fraction) of the video.
    /// - Warning: This event is unofficial and its behavior and availability may change.
    static let loadProgress: Self = "onLoadProgress"

    /// Fired periodically to indicate the current playback position (time update) of the video.
    /// - Warning: This event is unofficial and its behavior and availability may change.
    static let videoProgress: Self = "onVideoProgress"

    /// Signals that a reload of the player or its content is necessary (often due to a fatal error).
    /// - Warning: This event is unofficial and its behavior and availability may change.
    static let reloadRequired: Self = "onReloadRequired"

    /// Indicates that a network or connectivity issue is affecting playback.
    /// - Warning: This event is unofficial and its behavior and availability may change.
    static let connectionIssue: Self = "CONNECTION_ISSUE"

}

// MARK: - CaseIterable

extension YouTubePlayer.Event.Name: CaseIterable {

    /// The well-known event names registered by default.
    /// - Note: Custom names are not included in this collection.
    public static let allCases: [Self] = [
        .iFrameApiReady,
        .iFrameApiFailedToLoad,
        .error,
        .ready,
        .apiChange,
        .stateChange,
        .playbackQualityChange,
        .playbackRateChange,
        .autoplayBlocked,
        .fullscreenChange,
        .volumeChange,
        .videoDataChange,
        .playlistUpdate,
        .autoNavigationPauseRequest,
        .loadProgress,
        .videoProgress,
        .reloadRequired,
        .connectionIssue,
    ]

}

// MARK: - Codable

extension YouTubePlayer.Event.Name: Codable {

    /// Creates an event name from a single string, preserving unknown names.
    /// - Parameter decoder: The decoder.
    public init(
        from decoder: any Decoder
    ) throws {
        let container = try decoder.singleValueContainer()
        self.init(rawValue: try container.decode(String.self))
    }

    /// Encodes the event name as a single string.
    /// - Parameter encoder: The encoder.
    public func encode(
        to encoder: any Encoder
    ) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }

}

// MARK: - ExpressibleByStringLiteral

extension YouTubePlayer.Event.Name: ExpressibleByStringLiteral {

    /// Creates an event name from a string literal.
    /// - Parameter value: The event name.
    public init(
        stringLiteral value: String
    ) {
        self.init(rawValue: value)
    }

}

// MARK: - CustomStringConvertible

extension YouTubePlayer.Event.Name: CustomStringConvertible {

    /// The event name supplied by the YouTube IFrame API.
    public var description: String {
        return self.rawValue
    }

}
