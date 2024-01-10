import Foundation

// MARK: - YouTubePlayer+Source

public extension YouTubePlayer {
    
    /// The YouTubePlayer Source
    enum Source: Hashable, Sendable {
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

// MARK: - Source+url

public extension YouTubePlayer.Source {
    
    /// Creats `YouTubePlayer.Source` from a given URL string, if available
    /// - Parameter url: The URL string
    static func url(
        _ url: String
    ) -> Self? {
        // Initialize URLComonents from URL string
        let urlComponents = URLComponents(string: url)
        // Initialize URL from string
        let url = URL(string: url)
        // Retrieve start seconds from "t" url parameter, if available
        let startSeconds = urlComponents?.queryItems?["t"].flatMap(Int.init)
        // Initialize PathComponents and drop first which is the leading "/"
        let pathComponents = url?.pathComponents.dropFirst()
        // Check if URL host has YouTube share url host
        if url?.host?.hasSuffix("youtu.be") == true {
            // Check if a video id is available
            if let videoId = pathComponents?.first {
                // Return video source
                return .video(
                    id: videoId,
                    startSeconds: startSeconds
                )
            }
        } else {
            // Otherwise switch on first path component
            switch pathComponents?.first {
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
                if let channelName = url?.pathComponents[safe: 2] {
                    // Return channel source
                    return .channel(
                        name: channelName
                    )
                }
            default:
                // Check if a video identifier is available
                if let videoId = url?.pathComponents[safe: 2] {
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
