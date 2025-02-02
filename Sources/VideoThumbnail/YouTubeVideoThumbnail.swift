import Foundation
import SwiftUI

// MARK: - YouTubeVideoThumbnail

/// A YouTube video thumbnail.
public struct YouTubeVideoThumbnail: Codable, Hashable, Sendable {
    
    // MARK: Properties
    
    /// The video identifier.
    public var videoID: String
    
    /// The resolution.
    public var resolution: Resolution
    
    /// The host.
    public var host: String
    
    // MARK: Initializer
    
    /// Creates a new instance of ``YouTubeVideoThumbnail``
    /// - Parameters:
    ///   - videoID: The video identifier.
    ///   - resolution: The resolution. Default value `.standard`
    ///   - host: The host. Default value `img.youtube.com`
    public init(
        videoID: String,
        resolution: Resolution = .standard,
        host: String = "img.youtube.com"
    ) {
        self.videoID = videoID
        self.resolution = resolution
        self.host = host
    }
    
}

// MARK: - ExpressibleByStringLiteral

extension YouTubeVideoThumbnail: ExpressibleByStringLiteral {
    
    /// Creates a new instance of ``YouTubeVideoThumbnail``
    /// - Parameter videoID: The video identifier.
    public init(
        stringLiteral videoID: String
    ) {
        self.init(videoID: videoID)
    }
    
}

// MARK: - ExpressibleByURL

extension YouTubeVideoThumbnail: ExpressibleByURL {
    
    /// Creates a new instance of ``YouTubeVideoThumbnail``
    /// - Parameter url: The URL.
    public init?(url: URL) {
        guard case .video(let videoID) = YouTubePlayer.Source(url: url) else {
            return nil
        }
        self.init(videoID: videoID)
    }
    
}

// MARK: - Resolution

public extension YouTubeVideoThumbnail {
    
    /// A YouTube video thumbnail resolution.
    enum Resolution: String, Codable, Hashable, Sendable, CaseIterable {
        /// The default thumbnail image. The default thumbnail for a video or a resource
        /// that refers to a video, such as a playlist item or search result is 120px wide and 90px tall.
        /// The default thumbnail for a channel is 88px wide and 88px tall.
        case `default`
        /// A higher resolution version of the thumbnail image.
        /// For a video (or a resource that refers to a video),
        /// this image is 320px wide and 180px tall.
        /// For a channel, this image is 240px wide and 240px tall.
        case medium = "mqdefault"
        /// A high resolution version of the thumbnail image.
        /// For a video (or a resource that refers to a video),
        /// this image is 480px wide and 360px tall.
        /// For a channel, this image is 800px wide and 800px tall.
        case high = "hqdefault"
        /// An even higher resolution version of the thumbnail image than the high resolution image.
        /// This image is available for some videos and other resources
        /// that refer to videos, like playlist items or search results.
        /// This image is 640px wide and 480px tall.
        case standard = "sddefault"
        /// The highest resolution version of the thumbnail image.
        /// This image size is available for some videos and other resources
        /// that refer to videos, like playlist items or search results.
        /// This image is 1280px wide and 720px tall.
        case maximum = "maxresdefault"
    }
    
}

// MARK: - URL

public extension YouTubeVideoThumbnail {
    
    /// The URL of the thumbnail, if available.
    var url: URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = self.host
        urlComponents.path = CollectionOfOne("/")
            + [
                "vi",
                self.videoID,
                [
                    self.resolution.rawValue,
                    "jpg"
                ]
                .joined(separator: ".")
            ]
            .joined(separator: "/")
        return urlComponents.url
    }
    
}

// MARK: - Image

public extension YouTubeVideoThumbnail {
    
    #if os(macOS)
    /// A video thumbnail image.
    typealias Image = NSImage
    #else
    /// A video thumbnail image.
    typealias Image = UIImage
    #endif
    
    /// Returns the image of the thumbnail.
    /// - Parameter urlSession: The URLSession that loads the image. Default value `.shared`
    @MainActor
    func image(
        urlSession: URLSession = .shared
    ) async throws -> Image? {
        guard let url = self.url else {
            return nil
        }
        let (data, response) = try await urlSession.data(from: url)
        guard !data.isEmpty, (response as? HTTPURLResponse)?.statusCode == 200 else {
            return nil
        }
        return .init(data: data)
    }
    
}
