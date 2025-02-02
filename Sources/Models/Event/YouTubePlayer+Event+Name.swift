import Foundation

// MARK: - YouTubePlayer+Event+Name

public extension YouTubePlayer.Event {
    
    /// A name of a ``YouTubePlayer/Event``.
    enum Name: String, Codable, Hashable, Sendable, CaseIterable {
        
        // MARK: Custom Events
        
        /// Fired when the YouTube IFrame API has successfully loaded and initialized.
        /// - Important: A custom event emitted after the `YT.Player` has been initialized.
        case iFrameApiReady = "onIframeApiReady"
        /// Fired if the YouTube IFrame API fails to load.
        /// - Important: A custom event emitted when an error occured loading the YouTube player iFrame API JavaScript.
        case iFrameApiFailedToLoad = "onIframeApiFailedToLoad"
        
        
        // MARK: Offical Events
        
        /// Fired when an error occurs during player operation.
        case error = "onError"
        /// Fired when the YouTube player is fully initialized and ready to accept API commands.
        case ready = "onReady"
        /// Fired when a change occurs in the YouTube player iFrame API
        case apiChange = "onApiChange"
        /// Fired when the player's state changes (e.g., unstarted, playing, paused, buffering, ended).
        case stateChange = "onStateChange"
        /// Fired when the playback quality changes (for example, due to network conditions or manual change by the user).
        case playbackQualityChange = "onPlaybackQualityChange"
        /// Fired when the playback rate (speed) is changed.
        case playbackRateChange = "onPlaybackRateChange"
        
        // MARK: Unofficial Events
        
        /// Fired when an autoplay attempt is blocked by the browser or user settings.
        /// - Warning: This event is unofficial and its behavior and availability may change.
        case autoplayBlocked = "onAutoplayBlocked"
        /// Fired when the player enters or exits fullscreen mode.
        /// - Warning: This event is unofficial and its behavior and availability may change.
        case fullscreenChange = "onFullscreenChange"
        /// Fired when the player's volume level or mute state changes.
        /// - Warning: This event is unofficial and its behavior and availability may vary.
        case volumeChange = "onVolumeChange"
        /// Fired when there is a change in video metadata (such as title or description updates).
        /// - Warning: This event is unofficial and its behavior and availability may change.
        case videoDataChange = "onVideoDataChange"
        /// Fired when the playlist associated with the player is updated or modified.
        /// - Warning: This event is unofficial and its behavior and availability may change.
        case playlistUpdate = "onPlaylistUpdate"
        /// Fired when an automatic navigation pause is requested to temporarily halt auto–advance.
        /// - Warning: This event is unofficial and its behavior and availability may change.
        case autoNavigationPauseRequest = "onAutonavPauseRequest"
        /// Fired to indicate the buffering progress (loaded fraction) of the video.
        /// - Warning: This event is unofficial and its behavior and availability may change.
        case loadProgress = "onLoadProgress"
        /// Fired periodically to indicate the current playback position (time update) of the video.
        /// - Warning: This event is unofficial and its behavior and availability may change.
        case videoProgress = "onVideoProgress"
        /// Signals that a reload of the player or its content is necessary (often due to a fatal error).
        /// - Warning: This event is unofficial and its behavior and availability may change.
        case reloadRequired = "onReloadRequired"
        /// Indicates that a network or connectivity issue is affecting playback.
        /// - Warning: This event is unofficial and its behavior and availability may change.
        case connectionIssue = "CONNECTION_ISSUE"
    }
    
}
