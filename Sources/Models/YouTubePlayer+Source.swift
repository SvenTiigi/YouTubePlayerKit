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
            .afterPathComponent("v"),
            .afterPathComponent("embed"),
            .afterPathComponent("shorts"),
            .afterPathComponent("live"),
            .afterPathComponent("e")
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
            .afterPathComponent("channel"),
            .afterPathComponent("c"),
            .afterPathComponent("user"),
            .firstPathComponentWithPrefix("@", removePrefix: true),
            .afterPathComponent("feed")
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
        /// Extracts the path component after the match of the given one.
        case afterPathComponent(String)
        /// Extracts the value of the query item where the name matches and the supplied path components.
        case queryItem(name: String, pathComponents: [String])
    }
    
    /// Extracts a value from this url using the provided ``URL.ExtractionRule``
    /// - Parameter rule: The url extraction rule.
    func extract(
        using rule: ExtractionRule
    ) -> String? {
        lazy var pathComponents = self.pathComponents.dropFirst().filter { !$0.isEmpty }
        switch rule {
        case .firstPathComponent(let host):
            guard self.host == host,
                  let firstPathComponent = pathComponents.first else {
                return nil
            }
            return firstPathComponent
        case .firstPathComponentWithPrefix(let prefix, let removePrefix):
            guard let firstPathComponent = pathComponents.first,
                  firstPathComponent.first == prefix,
                  case let prefixRemovedFirstPathComponent = String(firstPathComponent.dropFirst()),
                  !prefixRemovedFirstPathComponent.isEmpty else {
                return nil
            }
            return removePrefix ? prefixRemovedFirstPathComponent : firstPathComponent
        case .afterPathComponent(let pathComponent):
            guard let pathComponentIndex = pathComponents.firstIndex(of: pathComponent),
                  case let nextPathComponentIndex = pathComponentIndex + 1,
                  pathComponents.indices.contains(nextPathComponentIndex) else {
                return nil
            }
            return pathComponents[nextPathComponentIndex]
        case .queryItem(let name, let expectedPathComponents):
            guard pathComponents == expectedPathComponents,
                  let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true),
                  let queryItem = urlComponents.queryItems?.first(where: { $0.name == name }),
                  let queryItemValue = queryItem.value,
                  !queryItemValue.isEmpty else {
                return nil
            }
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
