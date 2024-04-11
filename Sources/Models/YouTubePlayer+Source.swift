import Foundation

// MARK: - YouTubePlayer+Source

public extension YouTubePlayer {
    
    /// The YouTubePlayer Source
    enum Source: Codable, Hashable, Sendable {
        /// Video
        case video(
            id: String,
            startSeconds: Int? = nil,
            endSeconds: Int? = nil
        )
        /// Playlist
        case playlist(
            id: String,
            index: Int? = nil,
            startSeconds: Int? = nil
        )
        /// Channel
        case channel(
            name: String,
            index: Int? = nil,
            startSeconds: Int? = nil
        )
    }
    
}

// MARK: - Identifiable

extension YouTubePlayer.Source: Identifiable {
    
    /// The stable identity of the entity associated with this instance
    public var id: String {
        switch self {
        case .video(let id, _, _),
             .playlist(let id, _, _),
             .channel(let id, _, _):
            return id
        }
    }
    
}

// MARK: - Set Seconds

public extension YouTubePlayer.Source {
    
    /// Sets the start time.
    /// - Parameter startTime: The start time.
    mutating func set(
        startTime: Measurement<UnitDuration>
    ) {
        let startSeconds = Int(startTime.converted(to: .seconds).value)
        switch self {
        case .video(let id, _, let endSeconds):
            self = .video(
                id: id,
                startSeconds: startSeconds,
                endSeconds: endSeconds
            )
        case .playlist(let id, let index, _):
            self = .playlist(
                id: id,
                index: index,
                startSeconds: startSeconds
            )
        case .channel(let name, let index, _):
            self = .channel(
                name: name,
                index: index,
                startSeconds: startSeconds
            )
        }
    }
    
}

// MARK: - Source+url

public extension YouTubePlayer.Source {
    
    /// Creats `YouTubePlayer.Source` from a given URL string, if available
    /// - Parameter url: The URL string
    static func url(
        _ urlString: String
    ) -> Self? {
        // Initialize URL from string and call URL-based convenience method
        guard let url: URL = {
            if #available(iOS 17.0, tvOS 17.0, watchOS 10.0, macOS 14.0, *) {
                return .init(
                    string: urlString,
                    encodingInvalidCharacters: false
                )
            } else {
                return .init(
                    string: urlString
                )
            }
        }() else {
            return nil
        }
        return self.url(url)
    }
    
    /// Creats `YouTubePlayer.Source` from a given URL, if available
    /// - Parameter url: The URL
    static func url(
        _ url: URL
    ) -> Self? {
        // Initialize URLComonents from URL
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        // Retrieve start seconds from "t" url parameter, if available
        let startSeconds = urlComponents?.queryItems?["t"].flatMap(Int.init)
        // Initialize PathComponents and drop first which is the leading "/"
        let pathComponents = url.pathComponents.dropFirst()
        // Check if URL host has YouTube share url host
        if url.host?.lowercased().hasSuffix("youtu.be") == true {
            // Check if a video id is available
            if let videoId = pathComponents.first {
                // Return video source
                return .video(
                    id: videoId,
                    startSeconds: startSeconds
                )
            }
        } else if url.host?.lowercased().contains("youtube") == true {
            // Otherwise switch on first path component
            switch pathComponents.first {
            case "watch":
                // Check if a playlist identifier is available
                if let playlistId = urlComponents?.queryItems?["list"] {
                    // Return playlist source
                    return .playlist(
                        id: playlistId
                    )
                }
                // Check if video id is available
                if let videoId = urlComponents?.queryItems?["v"] {
                    // Return video source
                    return .video(
                        id: videoId,
                        startSeconds: startSeconds
                    )
                }
            case "c", "user":
                // Check if a channel name is available
                if let channelName = url.pathComponents[safe: 2] {
                    // Return channel source
                    return .channel(
                        name: channelName
                    )
                }
            default:
                // Check if a video identifier is available
                if let videoId = url.pathComponents[safe: 2] {
                    // Return video source
                    return .video(
                        id: videoId,
                        startSeconds: startSeconds
                    )
                }
            }
        }
        // Otherwise return nil
        return nil
    }
}

// MARK: - Sequence<URLQueryItem>+subscribt

private extension Sequence where Element == URLQueryItem {
    
    /// Retrieve a URLQueryItem value by a given name, if available
    subscript(_ name: String) -> String? {
        self.first { $0.name == name }?.value
    }
    
}

// MARK: - Collection+Safe

private extension Collection {
    
    /// Retrieve an Element at the specified index if it is withing bounds, otherwise return nil.
    /// - Parameter index: The Index
    subscript(safe index: Index) -> Element? {
        self.indices.contains(index) ? self[index] : nil
    }
    
}
