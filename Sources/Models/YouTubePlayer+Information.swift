import Foundation

// MARK: - YouTubePlayer+Information

public extension YouTubePlayer {
    
    /// The YouTube player information.
    struct Information: Codable, Hashable, Sendable {
        
        // MARK: Properties
        
        /// The video bytes loaded.
        public let videoBytesLoaded: Double?
        
        /// The video bytes total.
        public let videoBytesTotal: Double?
        
        /// The video bytes loaded fraction.
        public let videoLoadedFraction: Double?
        
        /// The video start bytes.
        public let videoStartBytes: Double?
        
        /// The playlist.
        public let playlist: String?
        
        /// The playlist index.
        public let playlistIndex: Int?
        
        /// The playlist identifier.
        public let playlistId: String?
        
        /// A Boolean indicating whether the player is muted or not.
        public let muted: Bool
        
        /// The volume from 0 to 100.
        public let volume: Int
        
        /// The YouTube player playback state.
        public let playerState: YouTubePlayer.PlaybackState
        
        /// The YouTube player playback rate.
        public let playbackRate: YouTubePlayer.PlaybackRate
        
        /// The available YouTube player playback rates.
        public let availablePlaybackRates: [YouTubePlayer.PlaybackRate]
        
        /// The YouTube player playback quality.
        public let playbackQuality: YouTubePlayer.PlaybackQuality
        
        /// The available YouTube player playback qualities.
        public let availableQualityLevels: [YouTubePlayer.PlaybackQuality]
        
        /// The current elapsed time.
        public let currentTime: Double
        
        /// The duration.
        public let duration: Double
        
        /// The video embed code.
        public let videoEmbedCode: String
        
        /// The video url.
        public let videoUrl: String
        
        /// The media reference time.
        public let mediaReferenceTime: Double
        
        /// The YouTube player playback metadata.
        public let videoData: YouTubePlayer.PlaybackMetadata
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer/Information``
        /// - Parameters:
        ///   - videoBytesLoaded: The video bytes loaded.
        ///   - videoBytesTotal: The video bytes total.
        ///   - videoLoadedFraction: The video bytes loaded fraction.
        ///   - videoStartBytes: The video start bytes.
        ///   - playlist: The playlist.
        ///   - playlistIndex: The playlist index.
        ///   - playlistId: The playlist identifier.
        ///   - muted: A Boolean indicating whether the player is muted or not.
        ///   - volume: The volume from 0 to 100.
        ///   - playerState: The YouTube player playback state.
        ///   - playbackRate: The YouTube player playback rate.
        ///   - availablePlaybackRates: The available YouTube player playback rates.
        ///   - playbackQuality: The YouTube player playback quality.
        ///   - availableQualityLevels: The available YouTube player playback qualities.
        ///   - currentTime: The current elapsed time.
        ///   - duration: The duration.
        ///   - videoEmbedCode: The video embed code.
        ///   - videoUrl: The video url.
        ///   - mediaReferenceTime: The media reference time.
        ///   - videoData: The YouTube player playback metadata.
        public init(
            videoBytesLoaded: Double?,
            videoBytesTotal: Double,
            videoLoadedFraction: Double?,
            videoStartBytes: Double,
            playlist: String?,
            playlistIndex: Int?,
            playlistId: String?,
            muted: Bool,
            volume: Int,
            playerState: YouTubePlayer.PlaybackState,
            playbackRate: YouTubePlayer.PlaybackRate,
            availablePlaybackRates: [YouTubePlayer.PlaybackRate],
            playbackQuality: YouTubePlayer.PlaybackQuality,
            availableQualityLevels: [YouTubePlayer.PlaybackQuality],
            currentTime: Double,
            duration: Double,
            videoEmbedCode: String,
            videoUrl: String,
            mediaReferenceTime: Double,
            videoData: YouTubePlayer.PlaybackMetadata
        ) {
            self.videoBytesLoaded = videoBytesLoaded
            self.videoBytesTotal = videoBytesTotal
            self.videoLoadedFraction = videoLoadedFraction
            self.videoStartBytes = videoStartBytes
            self.playlist = playlist
            self.playlistIndex = playlistIndex
            self.playlistId = playlistId
            self.muted = muted
            self.volume = volume
            self.playerState = playerState
            self.playbackRate = playbackRate
            self.availablePlaybackRates = availablePlaybackRates
            self.playbackQuality = playbackQuality
            self.availableQualityLevels = availableQualityLevels
            self.currentTime = currentTime
            self.duration = duration
            self.videoEmbedCode = videoEmbedCode
            self.videoUrl = videoUrl
            self.mediaReferenceTime = mediaReferenceTime
            self.videoData = videoData
        }
        
    }
    
}
