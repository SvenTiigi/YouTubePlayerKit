import Foundation

// Compiler-Check for Swift Version >= 5.5
// Temporarily: Exclude macOS as macOS 12.0 GitHub CI image is currently not available
#if swift(>=5.5) && !os(macOS)

// MARK: - YouTubePlayer360DegreePerspectiveAPI+Concurrency

@available(iOS 15.0.0, macOS 12.0.0, *)
public extension YouTubePlayer360DegreePerspectiveAPI {
    
    /// Retrieves properties that describe the viewer's current perspective
    func get360DegreePerspective() async throws -> YouTubePlayer.Perspective360Degree {
        try await withCheckedThrowingContinuation { continuation in
            self.get360DegreePerspective(
                completion: continuation.resume
            )
        }
    }
    
}

// MARK: - YouTubePlayerPlaylistAPI+Concurrency

@available(iOS 15.0.0, macOS 12.0.0, *)
public extension YouTubePlayerPlaylistAPI {
    
    /// This function returns an array of the video IDs in the playlist as they are currently ordered
    func getPlaylist() async throws -> [String] {
        try await withCheckedThrowingContinuation { continuation in
            self.getPlaylist(
                completion: continuation.resume
            )
        }
    }
    
    /// This function returns the index of the playlist video that is currently playing.
    func getPlaylistIndex() async throws -> Int {
        try await withCheckedThrowingContinuation { continuation in
            self.getPlaylistIndex(
                completion: continuation.resume
            )
        }
    }
    
}

// MARK: - YouTubePlayerVolumeAPI+Concurrency

@available(iOS 15.0.0, macOS 12.0.0, *)
public extension YouTubePlayerVolumeAPI {
    
    /// Returns Bool value if the player is muted
    func isMuted() async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            self.isMuted(
                completion: continuation.resume
            )
        }
    }
    
    /// Returns the player's current volume, an integer between 0 and 100
    func getVolume() async throws -> Int {
        try await withCheckedThrowingContinuation { continuation in
            self.getVolume(
                completion: continuation.resume
            )
        }
    }
    
}

// MARK: - YouTubePlayerPlaybackRateAPI+Concurrency

@available(iOS 15.0.0, macOS 12.0.0, *)
public extension YouTubePlayerPlaybackRateAPI {
    
    /// This function retrieves the playback rate of the currently playing video
    func getPlaybackRate() async throws -> YouTubePlayer.PlaybackRate {
        try await withCheckedThrowingContinuation { continuation in
            self.getPlaybackRate(
                completion: continuation.resume
            )
        }
    }
    
    /// This function returns the set of playback rates in which the current video is available
    func getAvailablePlaybackRates() async throws -> [YouTubePlayer.PlaybackRate] {
        try await withCheckedThrowingContinuation { continuation in
            self.getAvailablePlaybackRates(
                completion: continuation.resume
            )
        }
    }
    
}

// MARK: - YouTubePlayerPlaybackAPI+Concurrency

@available(iOS 15.0.0, macOS 12.0.0, *)
public extension YouTubePlayerPlaybackAPI {
    
    /// Returns a number between 0 and 1 that specifies the percentage of the video that the player shows as buffered
    func getVideoLoadedFraction() async throws -> Double {
        try await withCheckedThrowingContinuation { continuation in
            self.getVideoLoadedFraction(
                completion: continuation.resume
            )
        }
    }
    
    /// Returns the PlaybackState of the player video
    func getPlaybackState() async throws -> YouTubePlayer.PlaybackState {
        try await withCheckedThrowingContinuation { continuation in
            self.getPlaybackState(
                completion: continuation.resume
            )
        }
    }
    
    /// Returns the elapsed time in seconds since the video started playing
    func getCurrentTime() async throws -> Double {
        try await withCheckedThrowingContinuation { continuation in
            self.getCurrentTime(
                completion: continuation.resume
            )
        }
    }
    
    /// Returns the current PlaybackMetadata
    func getPlaybackMetadata() async throws -> YouTubePlayer.PlaybackMetadata {
        try await withCheckedThrowingContinuation { continuation in
            self.getPlaybackMetadata(
                completion: continuation.resume
            )
        }
    }
    
}

// MARK: - YouTubePlayerVideoInformationAPI+Concurrency

@available(iOS 15.0.0, macOS 12.0.0, *)
public extension YouTubePlayerVideoInformationAPI {
    
    /// Retrieve the YouTubePlayer Information
    func getInformation() async throws -> YouTubePlayer.Information {
        try await withCheckedThrowingContinuation { continuation in
            self.getInformation(
                completion: continuation.resume
            )
        }
    }
    
    /// Returns the duration in seconds of the currently playing video
    func getDuration() async throws -> Double {
        try await withCheckedThrowingContinuation { continuation in
            self.getDuration(
                completion: continuation.resume
            )
        }
    }
    
    /// Returns the YouTube.com URL for the currently loaded/playing video
    func getVideoURL() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            self.getVideoURL(
                completion: continuation.resume
            )
        }
    }
    
    /// Returns the embed code for the currently loaded/playing video
    func getVideoEmbedCode() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            self.getVideoEmbedCode(
                completion: continuation.resume
            )
        }
    }
    
    /// Retrieve the VideoThumbnail for the currently loaded video
    func getVideoThumbnail() async throws -> YouTubePlayer.VideoThumbnail {
        try await withCheckedThrowingContinuation { continuation in
            self.getVideoThumbnail(
                completion: continuation.resume
            )
        }
    }
    
    /// Retrieve the VideoThumbnail Image for the currently loaded video
    /// - Parameters:
    ///   - resolution: The specified Resolution. Default value `.maximum`
    ///   - urlSession: The URLSession used to load the Image. Default value `.shared`
    func getVideoThumbnailImage(
        resolution: YouTubePlayer.VideoThumbnail.Resolution = .maximum,
        urlSession: URLSession = .shared
    ) async throws -> YouTubePlayer.VideoThumbnail.Image {
        try await withCheckedThrowingContinuation { continuation in
            self.getVideoThumbnailImage(
                resolution: resolution,
                urlSession: urlSession,
                completion: continuation.resume
            )
        }
    }
    
}

#endif
