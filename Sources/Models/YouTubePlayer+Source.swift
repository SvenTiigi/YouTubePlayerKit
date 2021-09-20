import Foundation

// MARK: - YouTubePlayer+Source

public extension YouTubePlayer {
    
    /// The YouTubePlayer Source
    enum Source: Hashable {
        /// Video
        case video(
            id: String,
            startSeconds: UInt? = nil,
            endSeconds: UInt? = nil
        )
        /// Playlist
        case playlist(
            id: String,
            index: UInt? = nil,
            startSeconds: UInt? = nil
        )
        /// Channel
        case channel(
            id: String,
            index: UInt? = nil,
            startSeconds: UInt? = nil
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
        let urlComponents = URLComponents(string: url)
        let startSeconds = urlComponents?.queryItems?["t"].flatMap(UInt.init)
        let url = URL(string: url)
        let pathComponents = url?.pathComponents.dropFirst()
        if url?.host?.hasSuffix("youtu.be") == true {
            if let videoId = pathComponents?.first {
                return .video(
                    id: videoId,
                    startSeconds: startSeconds
                )
            }
        } else {
            switch pathComponents?.first {
            case "watch":
                if let playlistId = urlComponents?.queryItems?["list"] {
                    return .playlist(id: playlistId)
                }
                if let videoId = urlComponents?.queryItems?["v"] {
                    return .video(
                        id: videoId,
                        startSeconds: startSeconds
                    )
                }
            case "embed":
                if url?.pathComponents.indices.contains(1) == true,
                    let videoId = url?.pathComponents[1] {
                    return .video(
                        id: videoId,
                        startSeconds: startSeconds
                    )
                }
            case "channel":
                if url?.pathComponents.indices.contains(1) == true,
                    let channelId = url?.pathComponents[1] {
                    return .channel(id: channelId)
                }
            default:
                break
            }
        }
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
