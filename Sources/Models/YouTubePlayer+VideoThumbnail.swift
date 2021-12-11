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
        
        /// The YouTubePlayer Source
        private let source: Source
        
        // MARK: Initializer
        
        /// Creates a new instance of `YouTubePlayer.VideoThumbnail`
        /// - Parameter source: The YouTubePlayer Source
        public init(
            source: Source
        ) {
            self.source = source
        }
        
    }
    
}

// MARK: - VideoThumbnail+Resolution

public extension YouTubePlayer.VideoThumbnail {
    
    /// A VideoThumbnail Resolution
    enum Resolution: String, Codable, Hashable, CaseIterable {
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

// MARK: - VideoThumbnail+URL

public extension YouTubePlayer.VideoThumbnail {
    
    /// Retrieve the VideoThumbnail URL for a given Resolution
    /// - Parameter resolution: The Resolution. Default value `.maximum`
    /// - Returns: A string representation of the URL
    func url(
        resolution: Resolution = .maximum
    ) -> String {
        [
            Self.hostURL,
            self.source.id,
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
    ///   - resolution: The specified Resolution. Default value `.maximum`
    ///   - urlSession: The URLSession used to load the Image. Default value `.shared`
    ///   - completion: The completion closure
    func image(
        resolution: Resolution = .maximum,
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

// MARK: - VideoThumbnail+ImagePublisher

public extension YouTubePlayer.VideoThumbnail {
    
    /// Retrieve a Publisher that emits the Image of this VideoThumbnail or an ImageError
    /// - Parameters:
    ///   - resolution: The specified Resolution. Default value `.maximum`
    ///   - urlSession: The URLSession used to load the Image. Default value `.shared`
    func imagePublisher(
        resolution: Resolution = .maximum,
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

// Compiler-Check for Swift Version >= 5.5
// Temporarily: Exclude macOS as macOS 12.0 GitHub CI image is currently not available
#if swift(>=5.5) && !os(macOS)

@available(iOS 15.0.0, macOS 12.0.0, *)
public extension YouTubePlayer.VideoThumbnail {
    
    /// Retrieve the Image of this VideoThumbnail
    /// - Parameters:
    ///   - resolution: The specified Resolution. Default value `.maximum`
    ///   - urlSession: The URLSession used to load the Image. Default value `.shared`
    func image(
        resolution: Resolution = .maximum,
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

#endif
