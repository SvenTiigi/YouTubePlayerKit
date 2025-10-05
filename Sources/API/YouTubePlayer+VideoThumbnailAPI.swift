import Foundation
import SwiftUI

// MARK: - Video Thumbnail API

public extension YouTubePlayer {
    
    /// Returns the video thumbnail URL of the currently loaded video, if available.
    /// - Parameters:
    ///   - resolution: The resolution of the video thumbnail. Default value `.standard`
    func getVideoThumbnailURL(
        resolution: YouTubeVideoThumbnail.Resolution = .standard
    ) async throws(APIError) -> URL? {
        guard let videoID = try await self.getPlaybackMetadata().videoId else {
            return nil
        }
        return YouTubeVideoThumbnail(
            videoID: videoID,
            resolution: resolution
        )
        .url
    }
    
    /// Returns the video thumbnail of the currently loaded video, if available.
    /// - Parameters:
    ///   - resolution: The resolution of the video thumbnail. Default value `.standard`
    ///   - urlSession: The URLSession. Default value `.shared`
    func getVideoThumbnailImage(
        resolution: YouTubeVideoThumbnail.Resolution = .standard,
        urlSession: URLSession = .shared
    ) async throws -> YouTubeVideoThumbnail.Image? {
        guard let videoID = try await self.getPlaybackMetadata().videoId else {
            return nil
        }
        return try await YouTubeVideoThumbnail(
            videoID: videoID,
            resolution: resolution
        )
        .image(urlSession: urlSession)
    }
    
}
