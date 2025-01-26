import Foundation

// MARK: - YouTubePlayer+Parameters

public extension YouTubePlayer {
    
    /// The YouTube player parameters
    /// - Read more: https://developers.google.com/youtube/player_parameters
    struct Parameters: Hashable, Sendable {
        
        /// This parameter specifies whether the initial video
        /// will automatically start to play when the player loads
        public var autoPlay: Bool?
        
        /// This parameter specifies the default language that the player
        /// will use to display captions. Set the parameter's value
        ///  to an ISO 639-1 two-letter language code.
        public var captionLanguage: String?
        
        /// Setting the parameter's value to true causes closed
        /// captions to be shown by default, even if the user has turned captions off
        public var showCaptions: Bool?
        
        /// This parameter specifies the color that will be used in
        /// the player's video progress bar to highlight the amount
        /// of the video that the viewer has already see
        /// - Note: Setting the color parameter to white will disable the modestbranding option.
        public var progressBarColor: ProgressBarColor?
        
        /// This parameter indicates whether the video player controls are displayed
        public var showControls: Bool?
        
        /// Setting the parameter's value to true causes
        /// the player to not respond to keyboard controls
        public var keyboardControlsDisabled: Bool?
        
        /// This parameter specifies the time, from the start of the video,
        /// when the player should stop playing the video.
        public var endTime: Measurement<UnitDuration>?
        
        /// Setting this parameter to false prevents
        /// the fullscreen button from displaying in the player
        public var showFullscreenButton: Bool?
        
        /// Sets the player's interface language.
        /// The parameter value is an ISO 639-1 two-letter language code or a fully specified locale
        public var language: String?
        
        /// Setting the parameter's value to false causes video annotations to not be shown
        public var showAnnotations: Bool?
        
        /// In the case of a single video player, a true value causes
        /// the player to play the initial video again and again.
        /// In the case of a playlist player (or custom player),
        /// the player plays the entire playlist and then starts again at the first video.
        public var loopEnabled: Bool?
        
        /// If the rel parameter is set to false, related videos
        /// will come from the same channel as the video that was just played.
        public var showRelatedVideos: Bool?
        
        /// This parameter causes the player to begin playing the video.
        public var startTime: Measurement<UnitDuration>?
        
        /// This parameter identifies the URL where the player is embedded.
        /// This value is used in YouTube Analytics reporting when the YouTube player is embedded
        public var referrer: String?

        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer.Parameters``
        public init(
            autoPlay: Bool? = nil,
            captionLanguage: String? = nil,
            showCaptions: Bool? = nil,
            progressBarColor: ProgressBarColor? = nil,
            showControls: Bool? = nil,
            keyboardControlsDisabled: Bool? = nil,
            endTime: Measurement<UnitDuration>? = nil,
            showFullscreenButton: Bool? = nil,
            language: String? = nil,
            showAnnotations: Bool? = nil,
            loopEnabled: Bool? = nil,
            showRelatedVideos: Bool? = nil,
            startTime: Measurement<UnitDuration>? = nil,
            referrer: String? = nil
        ) {
            self.autoPlay = autoPlay
            self.captionLanguage = captionLanguage
            self.showCaptions = showCaptions
            self.progressBarColor = progressBarColor
            self.showControls = showControls
            self.keyboardControlsDisabled = keyboardControlsDisabled
            self.endTime = endTime
            self.showFullscreenButton = showFullscreenButton
            self.language = language
            self.showAnnotations = showAnnotations
            self.loopEnabled = loopEnabled
            self.showRelatedVideos = showRelatedVideos
            self.startTime = startTime
            self.referrer = referrer
        }
        
    }
    
}

// MARK: - ExpressibleByURL

extension YouTubePlayer.Parameters: ExpressibleByURL {
    
    /// Creates a new instance of ``YouTubePlayer.Parameters``
    /// - Parameter url: The URL.
    public init?(
        url: URL
    ) {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = urlComponents.queryItems,
              !queryItems.isEmpty else {
            self.init()
            return
        }
        let queryParameters = [String: String](
            uniqueKeysWithValues: queryItems.compactMap { queryItem in
                guard let value = queryItem.value, !value.isEmpty else {
                    return nil
                }
                return (queryItem.name, value)
            }
        )
        self.init(
            autoPlay: queryParameters[CodingKeys.autoPlay.rawValue].flatMap(Int.init).map { $0 == 1 },
            captionLanguage: queryParameters[CodingKeys.captionLanguage.rawValue],
            showCaptions: queryParameters[CodingKeys.showCaptions.rawValue].flatMap(Int.init).map { $0 == 1 },
            progressBarColor: queryParameters[CodingKeys.progressBarColor.rawValue].flatMap(ProgressBarColor.init),
            showControls: queryParameters[CodingKeys.showControls.rawValue].flatMap(Int.init).map { $0 == 1 },
            keyboardControlsDisabled: queryParameters[CodingKeys.keyboardControlsDisabled.rawValue].flatMap(Int.init).map { $0 == 1 },
            endTime: queryParameters[CodingKeys.endTime.rawValue].flatMap(Int.init).map { .init(value: .init($0), unit: .seconds) },
            showFullscreenButton: queryParameters[CodingKeys.showFullscreenButton.rawValue].flatMap(Int.init).map { $0 == 1 },
            language: queryParameters[CodingKeys.language.rawValue],
            showAnnotations: queryParameters[CodingKeys.showAnnotations.rawValue].flatMap(Int.init).map { $0 != 3 },
            loopEnabled: queryParameters[CodingKeys.loopEnabled.rawValue].flatMap(Int.init).map { $0 == 1 },
            showRelatedVideos: queryParameters[CodingKeys.showRelatedVideos.rawValue].flatMap(Int.init).map { $0 == 1 },
            startTime: {
                if let startTime = queryParameters[CodingKeys.startTime.rawValue].flatMap(Int.init) {
                    return .init(value: .init(startTime), unit: .seconds)
                } else if let timeSeconds = queryParameters["t"].flatMap(Int.init) {
                    return .init(value: .init(timeSeconds), unit: .seconds)
                } else {
                    return nil
                }
            }(),
            referrer: queryParameters[CodingKeys.referrer.rawValue]
        )
    }
    
}

// MARK: - Encodable

extension YouTubePlayer.Parameters: EncodableWithConfiguration {
    
    /// The encoding configuration.
    public struct EncodingConfiguration: Codable, Hashable, Sendable {
        
        // MARK: Properties
        
        /// The source.
        public let source: YouTubePlayer.Source?
        
        /// The origin URL.
        public let originURL: URL?
        
        /// A Boolean value that indicates whether HTML5 videos play inline or use the native full-screen controller.
        public let allowsInlineMediaPlayback: Bool
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer.Options.Parameters.EncodingConfiguration``
        /// - Parameters:
        ///   - source: The source. Default value `nil`
        ///   - originURL: The origin URL. Default value `nil`
        ///   - allowsInlineMediaPlayback: A Boolean value that indicates whether HTML5 videos play inline or use the native full-screen controller. Default value `true`
        public init(
            source: YouTubePlayer.Source? = nil,
            originURL: URL? = nil,
            allowsInlineMediaPlayback: Bool = true
        ) {
            self.source = source
            self.originURL = originURL
            self.allowsInlineMediaPlayback = allowsInlineMediaPlayback
        }
        
    }
    
    /// The CodingKeys
    enum CodingKeys: String, CodingKey {
        case autoPlay = "autoplay"
        case captionLanguage = "cc_lang_pref"
        case showCaptions = "cc_load_policy"
        case progressBarColor = "color"
        case showControls = "controls"
        case keyboardControlsDisabled = "disablekb"
        case enableJavaScriptAPI = "enablejsapi"
        case endTime = "end"
        case showFullscreenButton = "fs"
        case language = "hl"
        case showAnnotations = "iv_load_policy"
        case list
        case listType
        case loopEnabled = "loop"
        case origin
        case playlist
        case playInline = "playsinline"
        case showRelatedVideos = "rel"
        case startTime = "start"
        case referrer = "widget_referrer"
    }
    
    /// Encode.
    /// - Parameters:
    ///   - encoder: The encoder.
    ///   - configuration: The configuration.
    public func encode(
        to encoder: Encoder,
        configuration: EncodingConfiguration
    ) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.autoPlay?.bit, forKey: .autoPlay)
        try container.encodeIfPresent(self.captionLanguage, forKey: .captionLanguage)
        try container.encodeIfPresent(self.showCaptions?.bit, forKey: .showCaptions)
        try container.encodeIfPresent(self.progressBarColor, forKey: .progressBarColor)
        try container.encodeIfPresent(self.showControls?.bit, forKey: .showControls)
        try container.encodeIfPresent(self.keyboardControlsDisabled?.bit, forKey: .keyboardControlsDisabled)
        try container.encodeIfPresent(self.endTime.flatMap { Int($0.converted(to: .seconds).value) }, forKey: .endTime)
        try container.encodeIfPresent(self.showFullscreenButton?.bit, forKey: .showFullscreenButton)
        try container.encodeIfPresent(self.language, forKey: .language)
        try container.encodeIfPresent(self.showAnnotations.flatMap { $0 ? 1 : 3 }, forKey: .showAnnotations)
        try container.encodeIfPresent(self.loopEnabled?.bit, forKey: .loopEnabled)
        try container.encodeIfPresent(self.showRelatedVideos?.bit, forKey: .showRelatedVideos)
        try container.encodeIfPresent(self.startTime.flatMap { Int($0.converted(to: .seconds).value) }, forKey: .startTime)
        try container.encodeIfPresent(self.referrer, forKey: .referrer)
        try container.encode(true.bit, forKey: .enableJavaScriptAPI)
        switch configuration.source {
        case .video(let id):
            if self.loopEnabled == true {
                try container.encode(id, forKey: .playlist)
            }
        case .videos(let ids):
            try container.encode(ids.joined(separator: ","), forKey: .playlist)
        case .playlist(let id):
            try container.encode(ListType.playlist.rawValue, forKey: .listType)
            try container.encode(
                {
                    let playlistIDPrefix = "PL"
                    if id.lowercased().starts(with: playlistIDPrefix.lowercased()) {
                        return id
                    } else {
                        return playlistIDPrefix + id
                    }
                }(),
                forKey: .list
            )
        case .channel(let name):
            try container.encode(ListType.channel.rawValue, forKey: .listType)
            try container.encode(name, forKey: .list)
        case nil:
            break
        }
        try container.encodeIfPresent(configuration.originURL, forKey: .origin)
        try container.encodeIfPresent(configuration.allowsInlineMediaPlayback.bit, forKey: .playInline)
    }
    
}

// MARK: - Bool+bit

private extension Bool {
    
    /// The Binary Digit (bit) representation of this Bool value
    var bit: Int {
        self ? 1 : 0
    }
    
}

// MARK: - ProgressBarColor

public extension YouTubePlayer.Parameters {
    
    /// A YouTube player progress bar color.
    enum ProgressBarColor: String, Codable, Hashable, Sendable, CaseIterable {
        /// YouTube red color
        case red
        /// White color
        case white
    }
    
}

// MARK: - ListType

extension YouTubePlayer.Parameters {
    
    /// A YouTube player list type.
    enum ListType: String, Codable, Hashable, Sendable, CaseIterable {
        /// Playlist
        case playlist
        /// Channel / User uploads
        case channel = "user_uploads"
    }
    
}
