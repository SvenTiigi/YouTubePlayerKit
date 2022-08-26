import Combine
import Foundation

// MARK: - YouTubePlayerAPI

/// The YouTubePlayerAPI
/// - Read more: https://developers.google.com/youtube/iframe_api_reference#Functions
public typealias YouTubePlayerAPI = YouTubePlayerConfigurationAPI
    & YouTubePlayerQueueingAPI
    & YouTubePlayerEventAPI
    & YouTubePlayerVideoAPI
    & YouTubePlayer360DegreePerspectiveAPI
    & YouTubePlayerPlaylistAPI
    & YouTubePlayerVolumeAPI
    & YouTubePlayerPlaybackRateAPI
    & YouTubePlayerPlaybackAPI
    & YouTubePlayerVideoInformationAPI

// MARK: - YouTubePlayerConfigurationAPI

/// The YouTubePlayerConfigurationAPI
/// - Note: A custom YouTubePlayer API definition
public protocol YouTubePlayerConfigurationAPI: AnyObject {
    
    /// Update YouTubePlayer Configuration
    /// - Note: Updating the Configuration will result in a reload of the entire YouTubePlayer
    /// - Parameter configuration: The YouTubePlayer Configuration
    func update(
        configuration: YouTubePlayer.Configuration
    )
    
}

// MARK: - YouTubePlayerQueueingAPI

/// The YouTubePlayerQueueingAPI
/// - Read more: https://developers.google.com/youtube/iframe_api_reference#Queueing_Functions
public protocol YouTubePlayerQueueingAPI: AnyObject {
    
    /// Load YouTubePlayer Source
    /// - Parameter source: The YouTubePlayer Source to load
    func load(
        source: YouTubePlayer.Source?
    )
    
    /// Cue YouTubePlayer Source
    /// - Parameter source: The YouTubePlayer Source to cue
    func cue(
        source: YouTubePlayer.Source?
    )
    
}

// MARK: - YouTubePlayerEventAPI

/// The YouTubePlayerEventAPI
/// - Read more: https://developers.google.com/youtube/iframe_api_reference#Events
public protocol YouTubePlayerEventAPI: AnyObject {
    
    /// The current YouTubePlayer State, if available
    var state: YouTubePlayer.State? { get }
    
    /// A Publisher that emits the current YouTubePlayer State
    var statePublisher: AnyPublisher<YouTubePlayer.State, Never> { get }
    
    /// The current YouTubePlayer PlaybackState, if available
    var playbackState: YouTubePlayer.PlaybackState? { get }
    
    /// A Publisher that emits the current YouTubePlayer PlaybackState
    var playbackStatePublisher: AnyPublisher<YouTubePlayer.PlaybackState, Never> { get }
    
    /// The current YouTubePlayer PlaybackQuality, if available
    var playbackQuality: YouTubePlayer.PlaybackQuality? { get }
    
    /// A Publisher that emits the current YouTubePlayer PlaybackQuality
    var playbackQualityPublisher: AnyPublisher<YouTubePlayer.PlaybackQuality, Never> { get }
    
    /// The current YouTubePlayer PlaybackRate, if available
    var playbackRate: YouTubePlayer.PlaybackRate? { get }
    
    /// A Publisher that emits the current YouTubePlayer PlaybackRate
    var playbackRatePublisher: AnyPublisher<YouTubePlayer.PlaybackRate, Never> { get }
    
}

// MARK: - YouTubePlayerVideoAPI

/// The YouTubePlayerVideoAPI
/// Playback controls and player settings
/// - Read more: https://developers.google.com/youtube/iframe_api_reference#Playback_controls
public protocol YouTubePlayerVideoAPI: AnyObject {
    
    /// Plays the currently cued/loaded video
    func play()
    
    /// Pauses the currently playing video
    func pause()
    
    /// Stops and cancels loading of the current video
    func stop()
    
    /// Seeks to a specified time in the video
    /// - Parameters:
    ///   - seconds: The seconds parameter identifies the time to which the player should advance
    ///   - allowSeekAhead: Determines whether the player will make a new request to the server
    func seek(
        to seconds: Double,
        allowSeekAhead: Bool
    )
    
}

// MARK: - YouTubePlayer360DegreePerspectiveAPI

/// The YouTubePlayer360DegreePerspectiveAPI
/// Controlling playback of 360° videos
/// - Read more: https://developers.google.com/youtube/iframe_api_reference#Spherical_Video_Controls
public protocol YouTubePlayer360DegreePerspectiveAPI: AnyObject {
    
    /// Retrieves properties that describe the viewer's current perspective
    /// - Parameter completion: The completion closure
    func get360DegreePerspective(
        completion: @escaping (Result<YouTubePlayer.Perspective360Degree, YouTubePlayerAPIError>) -> Void
    )
    
    /// Sets the video orientation for playback of a 360° video
    /// - Parameter perspective360Degree: The Perspective360Degree
    func set(
        perspective360Degree: YouTubePlayer.Perspective360Degree
    )
    
}

// MARK: - YouTubePlayerPlaylistAPI

/// The YouTubePlayerPlaylistAPI
/// Playing a video in a playlist, setting playback behavior for playlists and retrieving playlist information
/// - Read more: https://developers.google.com/youtube/iframe_api_reference#playing-a-video-in-a-playlist
public protocol YouTubePlayerPlaylistAPI: AnyObject {
    
    /// This function loads and plays the next video in the playlist
    func nextVideo()
    
    /// This function loads and plays the previous video in the playlist
    func previousVideo()
    
    /// This function loads and plays the specified video in the playlist
    /// - Parameter index: The index of the video that you want to play in the playlist
    func playVideo(
        at index: Int
    )
    
    /// This function indicates whether the video player should continuously play a playlist
    /// or if it should stop playing after the last video in the playlist ends
    /// - Parameter enabled: Bool value if is enabled
    func setLoop(
        enabled: Bool
    )
    
    /// This function indicates whether a playlist's videos should be shuffled
    /// so that they play back in an order different from the one that the playlist creator designated
    /// - Parameter enabled: Bool value if is enabled
    func setShuffle(
        enabled: Bool
    )
    
    /// Retrieve an array of the video IDs in the playlist as they are currently ordered
    /// - Parameter completion: The completion closure
    func getPlaylist(
        completion: @escaping (Result<[String], YouTubePlayerAPIError>) -> Void
    )
    
    /// Retrieve the index of the playlist video that is currently playing.
    /// - Parameter completion: The completion closure
    func getPlaylistIndex(
        completion: @escaping (Result<Int, YouTubePlayerAPIError>) -> Void
    )
    
}

// MARK: - YouTubePlayerVolumeAPI

/// The YouTubePlayerVolumeAPI
/// Changing the player volume
/// - Read more: https://developers.google.com/youtube/iframe_api_reference#changing-the-player-volume
public protocol YouTubePlayerVolumeAPI: AnyObject {
    
    /// Mutes the player
    func mute()
    
    /// Unmutes the player
    func unmute()
    
    /// Retrieve the Bool value if the player is muted
    /// - Parameter completion: The completion closure
    func isMuted(
        completion: @escaping (Result<Bool, YouTubePlayerAPIError>) -> Void
    )
    
    /// Retrieve the player's current volume, an integer between 0 and 100
    /// - Parameter completion: The completion closure
    func getVolume(
        completion: @escaping (Result<Int, YouTubePlayerAPIError>) -> Void
    )
    
    /// Sets the volume.
    /// Accepts an integer between 0 and 100
    /// - Note: This function is part of the official YouTube Player iFrame API
    ///  but due to limitations and restrictions of the underlying WKWebView
    ///  the call has no effect on the actual volume of the device
    /// - Parameter volume: The volume
    func set(
        volume: Int
    )
    
}

// MARK: - YouTubePlayerPlaybackRateAPI

/// The YouTubePlayerPlaybackRateAPI
/// Setting the playback rate
/// - Read more: https://developers.google.com/youtube/iframe_api_reference#Playback_rate
public protocol YouTubePlayerPlaybackRateAPI: AnyObject {
    
    /// This function retrieves the playback rate of the currently playing video
    /// - Parameter completion: The completion closure
    func getPlaybackRate(
        completion: @escaping (Result<YouTubePlayer.PlaybackRate, YouTubePlayerAPIError>) -> Void
    )
    
    /// This function sets the suggested playback rate for the current video
    /// - Parameter playbackRate: The playback rate
    func set(
        playbackRate: YouTubePlayer.PlaybackRate
    )
    
    /// Retrieves the set of playback rates in which the current video is available
    /// - Parameter completion: The completion closure
    func getAvailablePlaybackRates(
        completion: @escaping (Result<[YouTubePlayer.PlaybackRate], YouTubePlayerAPIError>) -> Void
    )
    
}

// MARK: - YouTubePlayerPlaybackAPI

/// The YouTubePlayerPlaybackAPI
/// Playback status
/// - Read more: https://developers.google.com/youtube/iframe_api_reference#Playback_status
public protocol YouTubePlayerPlaybackAPI: AnyObject {
    
    /// Retrieve a number between 0 and 1 that specifies the percentage of the video that the player shows as buffered
    /// - Parameter completion: The completion closure
    func getVideoLoadedFraction(
        completion: @escaping (Result<Double, YouTubePlayerAPIError>) -> Void
    )
    
    /// Retrieve the PlaybackState of the player video
    /// - Parameter completion: The completion closure
    func getPlaybackState(
        completion: @escaping (Result<YouTubePlayer.PlaybackState, YouTubePlayerAPIError>) -> Void
    )
    
    /// Retrieve the elapsed time in seconds since the video started playing
    /// - Parameter completion: The completion closure
    func getCurrentTime(
        completion: @escaping (Result<Double, YouTubePlayerAPIError>) -> Void
    )
    
    /// Retrieve the current PlaybackMetadata
    /// - Parameter completion: The completion closure
    func getPlaybackMetadata(
        completion: @escaping (Result<YouTubePlayer.PlaybackMetadata, YouTubePlayerAPIError>) -> Void
    )
    
}

// MARK: - YouTubePlayerVideoInformationAPI

/// The YouTubePlayerVideoInformationAPI
/// Retrieving video information
/// - Read more: https://developers.google.com/youtube/iframe_api_reference#Retrieving_video_information
public protocol YouTubePlayerVideoInformationAPI: AnyObject {
    
    /// Show Stats for Nerds which displays additional video information
    func showStatsForNerds()
    
    /// Hide Stats for Nerds
    func hideStatsForNerds()
    
    /// Retrieve the YouTubePlayer Information
    /// - Parameter completion: The completion closure
    func getInformation(
        completion: @escaping (Result<YouTubePlayer.Information, YouTubePlayerAPIError>) -> Void
    )
    
    /// Retrieve the duration in seconds of the currently playing video
    /// - Parameter completion: The completion closure
    func getDuration(
        completion: @escaping (Result<Double, YouTubePlayerAPIError>) -> Void
    )
    
    /// Retrieve the YouTube.com URL for the currently loaded/playing video
    /// - Parameter completion: The completion closure
    func getVideoURL(
        completion: @escaping (Result<String, YouTubePlayerAPIError>) -> Void
    )
    
    /// Retrieve the embed code for the currently loaded/playing video
    /// - Parameter completion: The completion closure
    func getVideoEmbedCode(
        completion: @escaping (Result<String, YouTubePlayerAPIError>) -> Void
    )
    
}
