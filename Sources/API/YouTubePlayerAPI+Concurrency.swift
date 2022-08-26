#if compiler(>=5.5) && canImport(_Concurrency)
import Foundation

// MARK: - YouTubePlayer360DegreePerspectiveAPI+Concurrency

public extension YouTubePlayer360DegreePerspectiveAPI {
    
    /// Retrieves properties that describe the viewer's current perspective
    func get360DegreePerspective() async throws -> YouTubePlayer.Perspective360Degree {
        try await withCheckedThrowingContinuation { continuation in
            self.get360DegreePerspective { result in
                continuation.resume(with: result)
            }
        }
    }
    
}

// MARK: - YouTubePlayerPlaylistAPI+Concurrency

public extension YouTubePlayerPlaylistAPI {
    
    /// This function returns an array of the video IDs in the playlist as they are currently ordered
    func getPlaylist() async throws -> [String] {
        try await withCheckedThrowingContinuation { continuation in
            self.getPlaylist { result in
                continuation.resume(with: result)
            }
        }
    }
    
    /// This function returns the index of the playlist video that is currently playing.
    func getPlaylistIndex() async throws -> Int {
        try await withCheckedThrowingContinuation { continuation in
            self.getPlaylistIndex { result in
                continuation.resume(with: result)
            }
        }
    }
    
}

// MARK: - YouTubePlayerVolumeAPI+Concurrency

public extension YouTubePlayerVolumeAPI {
    
    /// Returns Bool value if the player is muted
    func isMuted() async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            self.isMuted { result in
                continuation.resume(with: result)
            }
        }
    }
    
    /// Returns the player's current volume, an integer between 0 and 100
    func getVolume() async throws -> Int {
        try await withCheckedThrowingContinuation { continuation in
            self.getVolume { result in
                continuation.resume(with: result)
            }
        }
    }
    
}

// MARK: - YouTubePlayerPlaybackRateAPI+Concurrency

public extension YouTubePlayerPlaybackRateAPI {
    
    /// This function retrieves the playback rate of the currently playing video
    func getPlaybackRate() async throws -> YouTubePlayer.PlaybackRate {
        try await withCheckedThrowingContinuation { continuation in
            self.getPlaybackRate { result in
                continuation.resume(with: result)
            }
        }
    }
    
    /// This function returns the set of playback rates in which the current video is available
    func getAvailablePlaybackRates() async throws -> [YouTubePlayer.PlaybackRate] {
        try await withCheckedThrowingContinuation { continuation in
            self.getAvailablePlaybackRates { result in
                continuation.resume(with: result)
            }
        }
    }
    
}

// MARK: - YouTubePlayerPlaybackAPI+Concurrency

public extension YouTubePlayerPlaybackAPI {
    
    /// Returns a number between 0 and 1 that specifies the percentage of the video that the player shows as buffered
    func getVideoLoadedFraction() async throws -> Double {
        try await withCheckedThrowingContinuation { continuation in
            self.getVideoLoadedFraction { result in
                continuation.resume(with: result)
            }
        }
    }
    
    /// Returns the PlaybackState of the player video
    func getPlaybackState() async throws -> YouTubePlayer.PlaybackState {
        try await withCheckedThrowingContinuation { continuation in
            self.getPlaybackState { result in
                continuation.resume(with: result)
            }
        }
    }
    
    /// Returns the elapsed time in seconds since the video started playing
    func getCurrentTime() async throws -> Double {
        try await withCheckedThrowingContinuation { continuation in
            self.getCurrentTime { result in
                continuation.resume(with: result)
            }
        }
    }
    
    /// Returns the current PlaybackMetadata
    func getPlaybackMetadata() async throws -> YouTubePlayer.PlaybackMetadata {
        try await withCheckedThrowingContinuation { continuation in
            self.getPlaybackMetadata { result in
                continuation.resume(with: result)
            }
        }
    }
    
}

// MARK: - YouTubePlayerVideoInformationAPI+Concurrency

public extension YouTubePlayerVideoInformationAPI {
    
    /// Retrieve the YouTubePlayer Information
    func getInformation() async throws -> YouTubePlayer.Information {
        try await withCheckedThrowingContinuation { continuation in
            self.getInformation { result in
                continuation.resume(with: result)
            }
        }
    }
    
    /// Returns the duration in seconds of the currently playing video
    func getDuration() async throws -> Double {
        try await withCheckedThrowingContinuation { continuation in
            self.getDuration { result in
                continuation.resume(with: result)
            }
        }
    }
    
    /// Returns the YouTube.com URL for the currently loaded/playing video
    func getVideoURL() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            self.getVideoURL { result in
                continuation.resume(with: result)
            }
        }
    }
    
    /// Returns the embed code for the currently loaded/playing video
    func getVideoEmbedCode() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            self.getVideoEmbedCode { result in
                continuation.resume(with: result)
            }
        }
    }
    
}
#endif
