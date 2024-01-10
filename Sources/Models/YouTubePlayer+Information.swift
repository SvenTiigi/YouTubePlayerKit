import Foundation

// MARK: - YouTubePlayer+Information

public extension YouTubePlayer {
    
    /// The YouTubePlayer Information
    struct Information: Codable, Hashable, Sendable {
        
        // MARK: Properties
        
        /// The optional video bytes loaded
        public let videoBytesLoaded: Double?
        
        /// The optional video bytes total
        public let videoBytesTotal: Double?
        
        /// The optional video bytes loaded fraction
        public let videoLoadedFraction: Double?
        
        /// The optional video start bytes
        public let videoStartBytes: Double?
        
        /// The optional playlist
        public let playlist: String?
        
        /// The optional playlist index
        public let playlistIndex: Int?
        
        /// The optional playlist id
        public let playlistId: String?
        
        /// Bool value if is muted
        public let muted: Bool
        
        /// The volume
        public let volume: Int
        
        /// The YouTubePlayer PlaybackState
        public let playerState: YouTubePlayer.PlaybackState
        
        /// The YouTubePlayer PlaybackRate
        public let playbackRate: YouTubePlayer.PlaybackRate
        
        /// The available YouTubePlayer PlaybackRates
        public let availablePlaybackRates: [YouTubePlayer.PlaybackRate]
        
        /// The YouTubePlayer PlaybackQuality
        public let playbackQuality: YouTubePlayer.PlaybackQuality
        
        /// The available YouTubePlayer PlaybackQualities
        public let availableQualityLevels: [YouTubePlayer.PlaybackQuality]
        
        /// The current elapsed time
        public let currentTime: Double
        
        /// The duration
        public let duration: Double
        
        /// The video embed code
        public let videoEmbedCode: String
        
        /// The video url
        public let videoUrl: String
        
        /// The media reference time
        public let mediaReferenceTime: Double
        
        /// The YouTubePlayer PlaybackMetadata
        public let videoData: YouTubePlayer.PlaybackMetadata
        
        // MARK: Initializer
        
        /// Creates a new instance of `YouTubePlayer.Information`
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
