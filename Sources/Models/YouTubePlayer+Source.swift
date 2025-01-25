import Foundation

// MARK: - YouTubePlayer+Source

public extension YouTubePlayer {
    
    /// A YouTube player source.
    enum Source: Codable, Hashable, Sendable {
        /// Video.
        case video(id: String)
        /// Videos.
        case videos(ids: [String])
        /// Playlist.
        case playlist(id: String)
        /// Channel.
        case channel(name: String)
    }
    
}

// MARK: - Identifiable

extension YouTubePlayer.Source: Identifiable {
    
    /// The identifier.
    public var id: String {
        switch self {
        case .video(let id):
            return id
        case .videos(let ids):
            return ids.joined(separator: ",")
        case .playlist(let id):
            return id
        case .channel(let name):
            return name
        }
    }
    
}

// MARK: - URL

public extension YouTubePlayer.Source {
    
    /// The URL representation of the source.
    var url: URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "www.youtube.com"
        switch self {
        case .video(let id):
            guard !id.isEmpty else {
                return nil
            }
            urlComponents.path = "/watch"
            urlComponents.queryItems = [
                .init(
                    name: "v",
                    value: id
                )
            ]
        case .videos:
            return nil
        case .playlist(let id):
            urlComponents.path = "/playlist"
            urlComponents.queryItems = [
                .init(
                    name: "list",
                    value: id
                )
            ]
        case .channel(let name):
            guard !name.isEmpty else {
                return nil
            }
            urlComponents.path = "/@\(name)"
        }
        return urlComponents.url
    }
    
}

// MARK: - Video ID

public extension YouTubePlayer.Source {
    
    /// The video identifier, if available.
    var videoID: String? {
        if case .video(let id) = self {
            return id
        } else {
            return nil
        }
    }
    
}

// MARK: - Video IDs

public extension YouTubePlayer.Source {
    
    /// The video identifiers, if available.
    var videoIDs: [String]? {
        if case .videos(let ids) = self {
            return ids
        } else {
            return nil
        }
    }
    
}

// MARK: - Playlist ID

public extension YouTubePlayer.Source {
    
    /// The playlist identifier, if available.
    var playlistID: String? {
        if case .playlist(let id) = self {
            return id
        } else {
            return nil
        }
    }
    
}

// MARK: - Channel Name

public extension YouTubePlayer.Source {
    
    /// The channel name, if available.
    var channelName: String? {
        if case .channel(let name) = self {
            return name
        } else {
            return nil
        }
    }
    
}

// MARK: - ExpressibleByArrayLiteral

extension YouTubePlayer.Source: ExpressibleByArrayLiteral {
    
    /// Creates a new instance of ``YouTubePlayer.Source``
    /// - Parameter videoIDs: The video identifiers.
    public init(
        arrayLiteral videoIDs: String...
    ) {
        self = .videos(ids: videoIDs)
    }
    
}

// MARK: - ExpressibleByURL

extension YouTubePlayer.Source: ExpressibleByURL {
    
    /// Creates a new instance of ``YouTubePlayer.Source``
    /// - Parameter url: The URL.
    public init?(
        url: URL
    ) {
        /// Returns the first match of a regular expression in a given string.
        /// - Parameters:
        ///   - regularExpression: The regular expression.
        ///   - string: The string.
        func firstMatch(
            of regularExpression: NSRegularExpression,
            in string: String
        ) -> String? {
            guard let match = regularExpression
                .firstMatch(
                    in: string,
                    range: .init(string.startIndex..., in: string)
                ),
                let range = Range(match.range(at: 1), in: string) else {
                return nil
            }
            return .init(string[range])
        }
        let urlString = url.absoluteString
        for regularExpression in Self.playlistRegularExpressions {
            if let playlistID = firstMatch(of: regularExpression, in: urlString) {
                self = .playlist(id: playlistID)
                return
            }
        }
        for regularExpression in Self.videoRegularExpressions {
            if let videoID = firstMatch(of: regularExpression, in: urlString) {
                self = .video(id: videoID)
                return
            }
        }
        for regularExpression in Self.channelRegularExpressions {
            if let channelName = firstMatch(of: regularExpression, in: urlString) {
                self = .channel(name: channelName)
                return
            }
        }
        return nil
    }

    /// The video regular expressions.
    private static let videoRegularExpressions: [NSRegularExpression] = [
        "youtu\\.be/([a-zA-Z0-9_-]+)",
        "youtube\\.com/watch\\?v=([a-zA-Z0-9_-]+)",
        "youtube\\.com/v/([a-zA-Z0-9_-]+)",
        "youtube\\.com/embed/([a-zA-Z0-9_-]+)",
        "youtube\\.com/shorts/([a-zA-Z0-9_-]+)",
        "youtube\\.com/live/([a-zA-Z0-9_-]+)",
        "youtube-nocookie\\.com/embed/([a-zA-Z0-9_-]+)",
        "youtube\\.com/e/([a-zA-Z0-9_-]+)"
    ]
    .compactMap { pattern in
        try? .init(
            pattern: pattern,
            options: .caseInsensitive
        )
    }
    
    /// The playlist regular expressions.
    private static let playlistRegularExpressions: [NSRegularExpression] = [
        "youtube\\.com/playlist\\?list=([a-zA-Z0-9_-]+)",
        "youtube\\.com/watch.*?[?&]list=([a-zA-Z0-9_-]+)",
        "youtube\\.com/embed/videoseries\\?list=([a-zA-Z0-9_-]+)",
        "videoseries\\?list=([a-zA-Z0-9_-]+)"
    ]
    .compactMap { pattern in
        try? .init(
            pattern: pattern,
            options: .caseInsensitive
        )
    }
    
    /// The channel regular expressions.
    private static let channelRegularExpressions: [NSRegularExpression] = [
        "youtube\\.com/channel/([a-zA-Z0-9_-]+)",
        "youtube\\.com/c/([a-zA-Z0-9_-]+)",
        "youtube\\.com/user/([a-zA-Z0-9_-]+)",
        "youtube\\.com/@([a-zA-Z0-9_.-]+)",
        "youtube\\.com/feed/([a-zA-Z0-9_-]+)"
    ]
    .compactMap { pattern in
        try? .init(
            pattern: pattern,
            options: .caseInsensitive
        )
    }
    
}
