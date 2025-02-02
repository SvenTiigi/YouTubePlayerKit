import Foundation

// MARK: - YouTubePlayer+PlaybackMetadata

public extension YouTubePlayer {
    
    /// The YouTube player playback metadata.
    struct PlaybackMetadata: Codable, Hashable, Sendable {
        
        // MARK: Properties
        
        /// The title.
        public let title: String?
        
        /// The author.
        public let author: String?
        
        /// The video identifier.
        public let videoId: Source.ID?
        
        /// Bool value if is playable.
        public let isPlayable: Bool?
        
        /// The error code.
        public let errorCode: Int?
        
        /// The video quality.
        public let videoQuality: String?
        
        /// The video quality features.
        public let videoQualityFeatures: [String]?
        
        /// Bool value if is backgroundable.
        public let backgroundable: Bool?
        
        /// The event identifier.
        public let eventId: String?
        
        /// The cpn.
        public let cpn: String?
        
        /// Bool value if is live.
        public let isLive: Bool?
        
        /// Bool value if is windowed live.
        public let isWindowedLive: Bool?
        
        /// Bool value if is manifestless.
        public let isManifestless: Bool?
        
        /// Bool value if live dvr is allowed.
        public let allowLiveDvr: Bool?
        
        /// Bool value if is listed.
        public let isListed: Bool?
        
        /// Bool value if is multi channel audio.
        public let isMultiChannelAudio: Bool?
        
        /// Bool value if progress bar boundaries are available.
        public let hasProgressBarBoundaries: Bool?
        
        /// Bool value if is premiere.
        public let isPremiere: Bool?
        
        /// The itct.
        public let itct: String?
        
        /// The progress bar start position in utc milliseconds.
        public let progressBarStartPositionUtcTimeMillis: Int?
        
        /// The progress bar end position in utc milliseconds.
        public let progressBarEndPositionUtcTimeMillis: Int?
        
        /// The paid content overlay duration in milliseconds.
        public let paidContentOverlayDurationMs: Int?
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer/PlaybackMetadata``
        /// - Parameters:
        ///   - title: The title.
        ///   - author: The author.
        ///   - videoId: The video identifier.
        ///   - isPlayable: Bool value if is playable.
        ///   - errorCode: The error code.
        ///   - videoQuality: The video quality.
        ///   - videoQualityFeatures: The video quality features.
        ///   - backgroundable: Bool value if is backgroundable.
        ///   - eventId: The event identifier.
        ///   - cpn: The cpn.
        ///   - isLive: Bool value if is live.
        ///   - isWindowedLive: Bool value if is windowed live.
        ///   - isManifestless: Bool value if is manifestless.
        ///   - allowLiveDvr: Bool value if live dvr is allowed.
        ///   - isListed: Bool value if is listed.
        ///   - isMultiChannelAudio: Bool value if is multi channel audio.
        ///   - hasProgressBarBoundaries: Bool value if progress bar boundaries are available.
        ///   - isPremiere: Bool value if is premiere.
        ///   - itct: The itct.
        ///   - progressBarStartPositionUtcTimeMillis: The progress bar start position in utc milliseconds.
        ///   - progressBarEndPositionUtcTimeMillis: The progress bar end position in utc milliseconds.
        ///   - paidContentOverlayDurationMs: The paid content overlay duration in milliseconds.
        public init(
            title: String? = nil,
            author: String? = nil,
            videoId: Source.ID? = nil,
            isPlayable: Bool? = nil,
            errorCode: Int? = nil,
            videoQuality: String? = nil,
            videoQualityFeatures: [String]? = nil,
            backgroundable: Bool? = nil,
            eventId: String? = nil,
            cpn: String? = nil,
            isLive: Bool? = nil,
            isWindowedLive: Bool? = nil,
            isManifestless: Bool? = nil,
            allowLiveDvr: Bool? = nil,
            isListed: Bool? = nil,
            isMultiChannelAudio: Bool? = nil,
            hasProgressBarBoundaries: Bool? = nil,
            isPremiere: Bool? = nil,
            itct: String? = nil,
            progressBarStartPositionUtcTimeMillis: Int? = nil,
            progressBarEndPositionUtcTimeMillis: Int? = nil,
            paidContentOverlayDurationMs: Int? = nil
        ) {
            self.title = title
            self.author = author
            self.videoId = videoId
            self.isPlayable = isPlayable
            self.errorCode = errorCode
            self.videoQuality = videoQuality
            self.videoQualityFeatures = videoQualityFeatures
            self.backgroundable = backgroundable
            self.eventId = eventId
            self.cpn = cpn
            self.isLive = isLive
            self.isWindowedLive = isWindowedLive
            self.isManifestless = isManifestless
            self.allowLiveDvr = allowLiveDvr
            self.isListed = isListed
            self.isMultiChannelAudio = isMultiChannelAudio
            self.hasProgressBarBoundaries = hasProgressBarBoundaries
            self.isPremiere = isPremiere
            self.itct = itct
            self.progressBarStartPositionUtcTimeMillis = progressBarStartPositionUtcTimeMillis
            self.progressBarEndPositionUtcTimeMillis = progressBarEndPositionUtcTimeMillis
            self.paidContentOverlayDurationMs = paidContentOverlayDurationMs
        }
        
    }
    
}
