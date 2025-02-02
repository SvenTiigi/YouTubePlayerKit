import Foundation

// MARK: - YouTubePlayer+Source

public extension YouTubePlayer {
    
    /// A YouTube player source.
    enum Source: Hashable, Sendable {
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
        case .videos(let ids):
            guard !ids.isEmpty else {
                return nil
            }
            urlComponents.path = "/watch_videos"
            urlComponents.queryItems = [
                .init(
                    name: "video_ids",
                    value: ids.joined(separator: ",")
                )
            ]
        case .playlist(let id):
            guard !id.isEmpty else {
                return nil
            }
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
    
    /// Creates a new instance of ``YouTubePlayer/Source``
    /// - Parameter videoIDs: The video identifiers.
    public init(
        arrayLiteral videoIDs: String...
    ) {
        self = .videos(ids: videoIDs)
    }
    
}

// MARK: - ExpressibleByURL

extension YouTubePlayer.Source: ExpressibleByURL {
    
    /// Creates a new instance of ``YouTubePlayer/Source``
    /// - Parameter url: The URL.
    public init?(
        url: URL
    ) {
        // For each url extraction rule set
        for urlExtractionRuleSet in [
            Self.playlistExtractionRuleSet,
            Self.videoExtractionRuleSet,
            Self.videosExtractionRuleSet,
            Self.channelURLExtractionRuleSet
        ] {
            // Verify if a source can be extracted from rule set
            guard let source = url.extract(using: urlExtractionRuleSet) else {
                // Otherwise continue with next rule set
                continue
            }
            // Initialize with source
            self = source
            // Return out of function
            return
        }
        // Return nil as url could not be parsed
        return nil
    }
    
    /// The `.video(id:)` case ``URL.ExtractionRuleSet``
    private static let videoExtractionRuleSet = URL.ExtractionRuleSet(
        rules: [
            .firstPathComponent(host: "youtu.be"),
            .queryItem(
                name: "v",
                pathComponents: ["watch"]
            ),
            .pathComponent(after: "v"),
            .pathComponent(after: "embed"),
            .pathComponent(after: "shorts"),
            .pathComponent(after: "live"),
            .pathComponent(after: "e")
        ],
        output: Self.video
    )
    
    /// The `.videos(ids:)` case ``URL.ExtractionRuleSet``
    private static let videosExtractionRuleSet = URL.ExtractionRuleSet(
        rules: [
            .queryItem(
                name: "video_ids",
                pathComponents: ["watch_videos"]
            )
        ],
        output: { match -> Self? in
            guard case let videoIDs = match.components(separatedBy: ","),
                  !videoIDs.isEmpty else {
                return nil
            }
            return .videos(ids: videoIDs)
        }
    )
    
    /// The `.playlist(id:)` case ``URL.ExtractionRuleSet``
    private static let playlistExtractionRuleSet = URL.ExtractionRuleSet(
        rules: [
            .queryItem(
                name: "list",
                pathComponents: ["playlist"]
            ),
            .queryItem(
                name: "list",
                pathComponents: ["watch"]
            ),
            .queryItem(
                name: "list",
                pathComponents: ["embed", "videoseries"]
            )
        ],
        output: Self.playlist
    )
    
    /// The `.channel(name:)` case ``URL.ExtractionRuleSet``
    private static let channelURLExtractionRuleSet = URL.ExtractionRuleSet(
        rules: [
            .pathComponent(after: "channel"),
            .pathComponent(after: "c"),
            .pathComponent(after: "user"),
            .firstPathComponentWithPrefix("@", removePrefix: true),
            .pathComponent(after: "feed")
        ],
        output: Self.channel
    )
    
}

// MARK: - URL+extract(using:)

private extension URL {
    
    /// An extraction rule.
    enum ExtractionRule: Hashable, Sendable {
        /// Extracts the first path component if the host matches.
        case firstPathComponent(host: String)
        /// Extracts the first path component where the prefix matches and optionally removes it.
        case firstPathComponentWithPrefix(Character, removePrefix: Bool)
        /// Extracts the path component after the provided one..
        case pathComponent(after: String)
        /// Extracts the value of the query item where the name matches and the supplied path components.
        case queryItem(name: String, pathComponents: [String])
    }
    
    /// Extracts a value from this url using the provided ``URL.ExtractionRule``
    /// - Parameter rule: The url extraction rule.
    func extract(
        using rule: ExtractionRule
    ) -> String? {
        // Initialize path components by dropping the first path component which is represented as "/"
        lazy var pathComponents = Array(self.pathComponents.dropFirst())
        switch rule {
        case .firstPathComponent(let host):
            // Verify host matches and the first path component is available
            guard self.host == host else {
                // Otherwise return nil
                return nil
            }
            // Return the first path component
            return pathComponents.first
        case .firstPathComponentWithPrefix(let prefix, let removePrefix):
            // Verify the first path component is available and has the provided prefix
            guard let firstPathComponent = pathComponents.first,
                  firstPathComponent.first == prefix,
                  case let prefixRemovedFirstPathComponent = String(firstPathComponent.dropFirst()),
                  !prefixRemovedFirstPathComponent.isEmpty else {
                // Otherwise return nil
                return nil
            }
            // Return first path component with or without prefix
            return removePrefix ? prefixRemovedFirstPathComponent : firstPathComponent
        case .pathComponent(let pathComponent):
            // Verify index of path component is available and the next path component is available
            guard let pathComponentIndex = pathComponents.firstIndex(of: pathComponent),
                  case let nextPathComponentIndex = pathComponentIndex + 1,
                  pathComponents.indices.contains(nextPathComponentIndex) else {
                // Otherwise return nil
                return nil
            }
            // Return next path component
            return pathComponents[nextPathComponentIndex]
        case .queryItem(let name, let expectedPathComponents):
            // Verify that the path components match and that the query item is available
            guard pathComponents == expectedPathComponents,
                  let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true),
                  let queryItem = urlComponents.queryItems?.first(where: { $0.name == name }),
                  let queryItemValue = queryItem.value,
                  !queryItemValue.isEmpty else {
                // Otherwise return nil
                return nil
            }
            // Return value of query item
            return queryItemValue
        }
    }
    
    /// An extraction rule set.
    struct ExtractionRuleSet<Output>: Sendable {
        
        /// The extraction rules.
        let rules: [ExtractionRule]
        
        /// A closure used to convert the match to the output, if possible.
        let output: @Sendable (String) -> Output?
        
    }
    
    /// Extracts the `Output` from this url using the provided ``URL.ExtractionRuleSet``.
    /// - Parameter ruleSet: The url extraction rule set.
    func extract<Output>(
        using ruleSet: ExtractionRuleSet<Output>
    ) -> Output? {
        // For each rule
        for rule in ruleSet.rules {
            // Verify a match is available and can be converted to the output
            guard let match = self.extract(using: rule),
                  let output = ruleSet.output(match) else {
                // Otherwise continue with the next rule
                continue
            }
            // Return output
            return output
        }
        // Return nil as no rule has matched
        return nil
    }
    
}

// MARK: - Codable

extension YouTubePlayer.Source: Codable {
    
    /// Creates a new instance of ``YouTubePlayer/Source``
    /// - Parameter decoder: The decoder.
    public init(
        from decoder: Decoder
    ) throws {
        lazy var decodingError = DecodingError
            .dataCorrupted(
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unsupported source representation"
                )
            )
        if let urlString = try? decoder.singleValueContainer().decode(String.self),
           let source = Self(urlString: urlString) {
            self = source
        } else if let videoIDs = try? decoder.singleValueContainer().decode([String].self),
                  !videoIDs.isEmpty {
            self = .videos(ids: videoIDs)
        } else if let container = try? decoder.container(keyedBy: YouTubePlayer.Parameters.CodingKeys.self) {
            if let listType = try? container.decode(YouTubePlayer.Parameters.ListType.self, forKey: .listType),
               let list = try? container.decode(String.self, forKey: .list) {
                switch listType {
                case .playlist:
                    self = .playlist(id: list)
                case .channel:
                    self = .channel(name: list)
                }
            } else if let playlist = try? container.decode(String.self, forKey: .playlist),
                      case let videoIDs = playlist.components(separatedBy: ","),
                      !videoIDs.isEmpty {
                if videoIDs.count == 1, let videoID = videoIDs.first {
                    self = .video(id: videoID)
                } else {
                    self = .videos(ids: videoIDs)
                }
            } else {
                throw decodingError
            }
        } else {
            throw decodingError
        }
    }
    
    /// Encode.
    /// - Parameter encoder: The encoder.
    public func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.url)
    }
    
}
