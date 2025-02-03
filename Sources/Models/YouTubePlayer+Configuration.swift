import Foundation

// MARK: - YouTubePlayer+Configuration

public extension YouTubePlayer {
    
    /// A YouTube player configuration.
    struct Configuration: Hashable, Sendable {
        
        // MARK: Properties
        
        /// The fullscreen mode.
        /// - Important: Setting the fullscreen mode to ``YouTubePlayer/FullscreenMode/web`` does not guarantee
        /// the use of HTML5 fullscreen mode, as the decision ultimately depends on the underlying YouTube Player iFrame API.
        public let fullscreenMode: FullscreenMode
        
        /// A Boolean value that indicates whether HTML5 videos play inline or use the native full-screen controller.
        public let allowsInlineMediaPlayback: Bool
        
        /// A Boolean value that indicates whether the web view allows media playback over AirPlay.
        public let allowsAirPlayForMediaPlayback: Bool
        
        /// A Boolean value that indicates whether HTML5 videos can play Picture in Picture.
        /// - Important: Picture-in-Picture mode may not work in every situation or with every video. Its support and availability depend on the underlying YouTube Player iFrame API.
        /// - Precondition: Please enable the `Audio`, `AirPlay`, and `Picture in Picture` background modes in your app's capabilities.
        /// - Note: Picture-in-Picture media playback is supported only on iOS and visionOS.
        public let allowsPictureInPictureMediaPlayback: Bool
        
        /// Boolean value indicating whether a non-persistent website data store should be used to get and set the site’s cookies and track cached data objects.
        public let useNonPersistentWebsiteDataStore: Bool
        
        /// A Boolean value indicating if safe area insets should be added automatically to content insets.
        public let automaticallyAdjustsContentInsets: Bool
        
        /// A custom user agent of the underlying web view.
        public let customUserAgent: String?
        
        /// The HTML builder.
        public let htmlBuilder: HTMLBuilder
        
        /// The action to perform when a url gets opened.
        public let openURLAction: OpenURLAction
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer/Configuration``
        /// - Parameters:
        ///   - fullscreenMode: The fullscreen mode. Default value `.preferred`
        ///   - allowsInlineMediaPlayback: A Boolean value that indicates whether HTML5 videos play inline or use the native full-screen controller. Default value `true`
        ///   - allowsAirPlayForMediaPlayback: A Boolean value that indicates whether the web view allows media playback over AirPlay. Default value `true`
        ///   - allowsPictureInPictureMediaPlayback: A Boolean value that indicates whether HTML5 videos can play Picture in Picture. Default value `false`
        ///   - useNonPersistentWebsiteDataStore: Boolean value indicating whether a non-persistent website data store should be used. Default value `true`
        ///   - automaticallyAdjustsContentInsets: A Boolean value indicating if safe area insets should be added automatically to content insets. Default value `true`
        ///   - customUserAgent: A custom user agent of the underlying web view. Default value `nil`
        ///   - htmlBuilder: The HTML builder. Default value `.init()`
        ///   - openURLAction: The action to perform when a url gets opened.. Default value `.default`
        public init(
            fullscreenMode: FullscreenMode = .preferred,
            allowsInlineMediaPlayback: Bool = true,
            allowsAirPlayForMediaPlayback: Bool = true,
            allowsPictureInPictureMediaPlayback: Bool = false,
            useNonPersistentWebsiteDataStore: Bool = true,
            automaticallyAdjustsContentInsets: Bool = true,
            customUserAgent: String? = nil,
            htmlBuilder: HTMLBuilder = .init(),
            openURLAction: OpenURLAction = .default
        ) {
            self.fullscreenMode = fullscreenMode
            self.allowsInlineMediaPlayback = allowsInlineMediaPlayback
            self.allowsAirPlayForMediaPlayback = allowsAirPlayForMediaPlayback
            self.allowsPictureInPictureMediaPlayback = allowsPictureInPictureMediaPlayback
            self.useNonPersistentWebsiteDataStore = useNonPersistentWebsiteDataStore
            self.automaticallyAdjustsContentInsets = automaticallyAdjustsContentInsets
            self.customUserAgent = customUserAgent
            self.htmlBuilder = htmlBuilder
            self.openURLAction = openURLAction
        }
        
    }
    
}

// MARK: - ExpressibleByURL

extension YouTubePlayer.Configuration: ExpressibleByURL {
    
    /// Creates a new instance of ``YouTubePlayer/Configuration``
    /// - Parameter url: The URL.
    public init?(
        url: URL
    ) {
        let queryItems = URLComponents(
            url: url, resolvingAgainstBaseURL: true
        )?
        .queryItems ?? .init()
        self.init(
            allowsInlineMediaPlayback: queryItems
                .first { $0.name == YouTubePlayer.Parameters.CodingKeys.playInline.rawValue }
                .flatMap { $0.value == "1" } ?? true
        )
    }
    
}

// MARK: - Codable

extension YouTubePlayer.Configuration: Codable {
    
    /// The coding keys.
    private enum CodingKeys: CodingKey {
        case fullscreenMode
        case allowsInlineMediaPlayback
        case allowsAirPlayForMediaPlayback
        case allowsPictureInPictureMediaPlayback
        case useNonPersistentWebsiteDataStore
        case automaticallyAdjustsContentInsets
        case customUserAgent
        case htmlBuilder
    }
    
    /// Creates a new instance of ``YouTubePlayer/Configuration``
    /// - Parameter decoder: The decoder.
    public init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            fullscreenMode: container.decode(YouTubePlayer.FullscreenMode.self, forKey: .fullscreenMode),
            allowsInlineMediaPlayback: container.decode(Bool.self, forKey: .allowsInlineMediaPlayback),
            allowsAirPlayForMediaPlayback: container.decode(Bool.self, forKey: .allowsAirPlayForMediaPlayback),
            allowsPictureInPictureMediaPlayback: container.decode(Bool.self, forKey: .allowsPictureInPictureMediaPlayback),
            useNonPersistentWebsiteDataStore: container.decode(Bool.self, forKey: .useNonPersistentWebsiteDataStore),
            automaticallyAdjustsContentInsets: container.decode(Bool.self, forKey: .automaticallyAdjustsContentInsets),
            customUserAgent: container.decodeIfPresent(String.self, forKey: .customUserAgent),
            htmlBuilder: container.decode(YouTubePlayer.HTMLBuilder.self, forKey: .htmlBuilder)
        )
    }
    
    /// Encode.
    /// - Parameter encoder: The encoder.
    public func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.fullscreenMode, forKey: .fullscreenMode)
        try container.encode(self.allowsInlineMediaPlayback, forKey: .allowsInlineMediaPlayback)
        try container.encode(self.allowsAirPlayForMediaPlayback, forKey: .allowsAirPlayForMediaPlayback)
        try container.encode(self.allowsPictureInPictureMediaPlayback, forKey: .allowsPictureInPictureMediaPlayback)
        try container.encode(self.useNonPersistentWebsiteDataStore, forKey: .useNonPersistentWebsiteDataStore)
        try container.encode(self.automaticallyAdjustsContentInsets, forKey: .automaticallyAdjustsContentInsets)
        try container.encode(self.customUserAgent, forKey: .customUserAgent)
        try container.encode(self.htmlBuilder, forKey: .htmlBuilder)
    }
    
}
