#if os(macOS)
import AppKit
#else
import UIKit
#endif
import Combine

// MARK: - YouTubePlayer+VideoThumbnail

public extension YouTubePlayer {
    
    /// A YouTubePlayer VideoThumbnail
    struct VideoThumbnail: Hashable {
        
        // MARK: Static-Properties
        
        /// The YouTube VideoThumbnail host url. Default value `https://i.ytimg.com/vi`
        public static var hostURL = "https://i.ytimg.com/vi"
        
        /// The YouTube VideoThumbnail file extension. Default value `jpg`
        public static var fileExtension = "jpg"
        
        // MARK: Properties
        
        /// The YouTubePlayer Source Identifier
        private let sourceID: Source.ID
        
        // MARK: Initializer
        
        /// Creates a new instance of `YouTubePlayer.VideoThumbnail`
        /// - Parameter sourceID: The YouTubePlayer Source Identifier
        public init(
            sourceID: Source.ID
        ) {
            self.sourceID = sourceID
        }
        
    }
    
}

// MARK: - VideoThumbnail+init(source:)

public extension YouTubePlayer.VideoThumbnail {
    
    /// The Unsupported Source Error
    struct UnsupportedSourceError: Hashable, Error {
        
        // MARK: Properties
        
        /// The unsupported YouTubePlayer Source
        public let source: YouTubePlayer.Source
        
        // MARK: Initializer
        
        /// Creates a new instance of `YouTubePlayer.VideoThumbnail.UnsupportedSourceError`
        /// - Parameter source: The unsupported YouTubePlayer Source
        public init(
            source: YouTubePlayer.Source
        ) {
            self.source = source
        }
        
    }
    
    /// Creates a new instance of `YouTubePlayer.VideoThumbnail`
    /// from a YouTubePlayer Source  or throws an `UnsupportedSourceError`.
    /// Supported YouTubePlayer Sources are `video` and `playlist`
    /// - Parameter videoURL: The video URL
    init(
        source: YouTubePlayer.Source
    ) throws {
        switch source {
        case .video(let id, _, _), .playlist(let id, _, _):
            self.init(sourceID: id)
        case .channel:
            throw UnsupportedSourceError(
                source: source
            )
        }
    }
    
}

// MARK: - VideoThumbnail+init(videoURL:)

public extension YouTubePlayer.VideoThumbnail {
    
    /// The VideoThumbnail BadVideoURLError
    struct BadVideoURLError: Codable, Hashable, Error {
        
        // MARK: Properties
        
        /// The bad video URL
        public let videoURL: String
        
        // MARK: Initializer
        
        /// Creates a new instance of `YouTubePlayer.VideoThumbnail.BadVideoURLError`
        /// - Parameter videoURL: The bad video URL
        public init(
            videoURL: String
        ) {
            self.videoURL = videoURL
        }
        
    }
    
    /// Creates a new instance of `YouTubePlayer.VideoThumbnail`
    /// from a video URL or throws an `BadVideoURLError`
    /// - Parameter videoURL: The video URL
    init(
        videoURL: String
    ) throws {
        // Verify YouTubePlayer Source can be initialized from video URL
        guard let source: YouTubePlayer.Source = .url(videoURL) else {
            // Otherwise throw BadVideoURLError
            throw BadVideoURLError(
                videoURL: videoURL
            )
        }
        // Initialize with Source
        try self.init(source: source)
    }
    
}

// MARK: - VideoThumbnail+Resolution

public extension YouTubePlayer.VideoThumbnail {
    
    /// A VideoThumbnail Resolution
    /// - Read more: https://developers.google.com/youtube/v3/docs/thumbnails
    enum Resolution: String, Codable, Hashable, CaseIterable {
        /// The default thumbnail image. The default thumbnail for a video or a resource
        /// that refers to a video, such as a playlist item or search result is 120px wide and 90px tall.
        case `default`
        /// A higher resolution version of the thumbnail image.
        /// For a video (or a resource that refers to a video),
        /// this image is 320px wide and 180px tall.
        case medium = "mqdefault"
        /// A high resolution version of the thumbnail image.
        /// For a video (or a resource that refers to a video),
        /// this image is 480px wide and 360px tall.
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

// MARK: - VideoThumbnail+Resolution+size

public extension YouTubePlayer.VideoThumbnail.Resolution {
    
    /// The size in pixels
    var size: CGSize {
        switch self {
        case .default:
            return .init(
                width: 120,
                height: 90
            )
        case .medium:
            return .init(
                width: 320,
                height: 180
            )
        case .high:
            return .init(
                width: 480,
                height: 360
            )
        case .standard:
            return .init(
                width: 640,
                height: 480
            )
        case .maximum:
            return .init(
                width: 1280,
                height: 720
            )
        }
    }
    
}

// MARK: - VideoThumbnail+URL

public extension YouTubePlayer.VideoThumbnail {
    
    /// Retrieve the VideoThumbnail URL for a given Resolution
    /// - Parameter resolution: The Resolution. Default value `.standard`
    /// - Returns: A string representation of the URL
    func url(
        resolution: Resolution = .standard
    ) -> String {
        [
            Self.hostURL,
            self.sourceID,
            [
                resolution.rawValue,
                Self.fileExtension
            ]
            .joined(separator: ".")
        ]
        .joined(separator: "/")
    }
    
}

// MARK: - VideoThumbnail+Image

public extension YouTubePlayer.VideoThumbnail {
    
    #if os(macOS)
    /// The Image typealias representing a NSImage
    typealias Image = NSImage
    #else
    /// The Image typealias representing an UIImage
    typealias Image = UIImage
    #endif
    
    /// A YouTubePlayer VideoThumbnail ImageError
    enum ImageError: Error {
        /// Bad request url
        case badRequestURL(String)
        /// Failed to retrieve Image with optional Error
        case failed(Error?)
    }
    
    /// Retrieve the Image of this VideoThumbnail
    /// - Parameters:
    ///   - resolution: The specified Resolution. Default value `.standard`
    ///   - urlSession: The URLSession used to load the Image. Default value `.shared`
    ///   - completion: The completion closure
    func image(
        resolution: Resolution = .standard,
        urlSession: URLSession = .shared,
        completion: @escaping (Result<Image, ImageError>) -> Void
    ) {
        // Make URL for the specified Resolution
        let url = self.url(resolution: resolution)
        // Verify request URL can be initialized from URL
        guard let requestURL = URL(string: url) else {
            // Otherwise complete with failure
            return completion(
                .failure(.badRequestURL(url))
            )
        }
        // Perform DataTask with request URL
        urlSession.dataTask(
            with: requestURL
        ) { data, _, error in
            // Initialize Result
            let result: Result<Image, ImageError> = {
                // Verify data can be initialized to an Image
                guard let image = data.flatMap(Image.init(data:)) else {
                    // Otherwise return failure
                    return .failure(.failed(error))
                }
                // Return success with Image
                return .success(image)
            }()
            // Dispatch on main queue
            DispatchQueue.main.async {
                // Complete with result
                completion(result)
            }
        }
        .resume()
    }
    
}

// MARK: - VideoThumbnail+image

public extension YouTubePlayer.VideoThumbnail {
    
    /// Retrieve the Image of this VideoThumbnail
    /// - Parameters:
    ///   - resolution: The specified Resolution. Default value `.standard`
    ///   - urlSession: The URLSession used to load the Image. Default value `.shared`
    func image(
        resolution: Resolution = .standard,
        urlSession: URLSession = .shared
    ) async throws -> Image {
        try await withCheckedThrowingContinuation { continuation in
            self.image(
                resolution: resolution,
                urlSession: urlSession,
                completion: continuation.resume
            )
        }
    }
    
}

// MARK: - VideoThumbnail+imagePublisher

public extension YouTubePlayer.VideoThumbnail {
    
    /// Retrieve a Publisher that emits the Image of this VideoThumbnail or an ImageError
    /// - Parameters:
    ///   - resolution: The specified Resolution. Default value `.standard`
    ///   - urlSession: The URLSession used to load the Image. Default value `.shared`
    func imagePublisher(
        resolution: Resolution = .standard,
        urlSession: URLSession = .shared
    ) -> AnyPublisher<Image, ImageError> {
        Deferred {
            Future { promise in
                self.image(
                    resolution: resolution,
                    urlSession: urlSession,
                    completion: promise
                )
            }
        }
        .eraseToAnyPublisher()
    }
    
}
