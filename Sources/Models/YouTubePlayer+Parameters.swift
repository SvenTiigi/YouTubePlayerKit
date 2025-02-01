import Foundation

// MARK: - YouTubePlayer+Parameters

public extension YouTubePlayer {
    
    /// The YouTube player parameters.
    /// - SeeAlso: [YouTube Player Parameters Documentation](https://developers.google.com/youtube/player_parameters)
    /// - Note: The parameters `list`, `listType`, `playlist`, `playsinline`, `enablejsapi` are not directly configurable.
    /// The YouTubePlayerKit automatically sets these paramters based on the provided ``YouTubePlayer.Source`` and ``YouTubePlayer.Configuration``
    struct Parameters: Hashable, Sendable {
        
        /// Controls whether the video automatically begins playing when the player loads.
        /// - Note: On mobile devices, playback might be blocked by the browser or operating system policies that prevent automatic playback with sound.
        /// - Default: `false`
        public var autoPlay: Bool?
        
        /// Enables continuous playback loop.
        ///
        /// When enabled:
        /// - Single video: The video will play again once it finishes
        /// - Playlist: The playlist will repeat after playing the last video
        /// - Default: `false`
        public var loopEnabled: Bool?
        
        /// Specifies the time when the player should begin playing the video.
        /// - Parameter value: The time in seconds from the start of the video.
        /// - Note: The player will begin at the closest keyframe to the specified time.
        /// - Important: Must be less than `endTime` if both are specified.
        public var startTime: Measurement<UnitDuration>?
        
        /// Specifies the time when the player should stop playing the video.
        /// - Parameter value: The time in seconds from the beginning of the video.
        /// - Note: The player will stop at the closest keyframe to the specified time.
        /// - Important: Must be greater than `startTime` if both are specified.
        public var endTime: Measurement<UnitDuration>?
        
        /// Controls the display of player controls.
        ///
        /// Values and their effects:
        /// - `false`: Player controls are hidden
        /// - `true`: Player controls display immediately
        /// - Note: Controls will be disabled during ads regardless of this setting.
        /// - Default: `true`
        public var showControls: Bool?
        
        /// Controls the display of the fullscreen button.
        ///
        /// When set to `false`, prevents the fullscreen button from displaying in the player.
        /// - Note: This does not prevent programmatic fullscreen activation.
        /// - Default: `true`
        public var showFullscreenButton: Bool?
        
        /// The color of the video progress bar.
        ///
        /// Specifies the color that will be used in the player's video progress bar
        /// to highlight the amount of the video that the viewer has already watched.
        /// - SeeAlso: `ProgressBarColor`
        public var progressBarColor: ProgressBarColor?
        
        /// Prevents the player from responding to keyboard controls.
        ///
        /// When enabled, disables player keyboard controls including:
        /// - Spacebar (play/pause)
        /// - Arrow keys (seek/volume)
        /// - Numbers 0-9 (seek percentage)
        /// - F (toggle fullscreen)
        /// - M (toggle mute)
        /// - C (toggle captions)
        /// - I (toggle miniplayer)
        /// - Default: `false`
        public var keyboardControlsDisabled: Bool?
        
        /// Sets the player's interface language.
        ///
        /// Accepts:
        /// - ISO 639-1 two-letter language code (e.g., "fr" for French)
        /// - Fully specified locale (e.g., "pt-BR" for Brazilian Portuguese)
        /// - Note: Controls the language of player interface elements only, not captions.
        /// - SeeAlso: [ISO 639-1 Language Codes](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes)
        public var language: String?
        
        /// The default language for closed captions display.
        /// - Parameter value: An ISO 639-1 two-letter language code (e.g., "en" for English).
        /// - Note: If the specified language track is not available, captions will default to the
        ///         track based on the user's activity or the video's default caption track.
        /// - SeeAlso: [ISO 639-1 Language Codes](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes)
        public var captionLanguage: String?
        
        /// Forces closed captions to be shown by default.
        ///
        /// When enabled, forces the player to display closed captions even if captions are turned off by default.
        /// This setting overrides user preferences and the default state of captions.
        /// - Default: `false`
        public var showCaptions: Bool?
        
        /// Controls whether related videos are restricted to the same channel.
        ///
        /// When `true`, related videos will only be shown from the same channel as the current video.
        /// When `false`, related videos can be shown from any channel.
        /// - Default: `false` (related videos from all channels are shown)
        public var restrictRelatedVideosToSameChannel: Bool?
        
        /// The domain origin URL.
        public var originURL: URL?
        
        /// Specifies the URL of the page containing the embedded player.
        ///
        /// Used by YouTube Analytics to track video playback origin. Should match the actual URL
        /// where the player is embedded.
        /// - Important: Must be a valid URL for accurate analytics data collection.
        /// - Note: This parameter provides additional context to YouTube Analytics but is not required.
        public var referrerURL: URL?

        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer.Parameters``
        /// - Parameters:
        ///   - autoPlay: Controls automatic playback when the player loads. Might be restricted by browser policies if the player is not muted.
        ///   - loopEnabled: Enables continuous playback of video or playlist.
        ///   - startTime: Time in seconds from video start when playback should begin. Must be less than `endTime` if both are set.
        ///   - endTime: Time in seconds from video start when playback should stop. Must be greater than `startTime` if both are set.
        ///   - showControls: Shows or hides player controls.
        ///   - showFullscreenButton: Shows or hides the fullscreen button.
        ///   - progressBarColor: Color used in the video progress bar to show watched portions of the video.
        ///   - keyboardControlsDisabled: When `true`, disables keyboard shortcuts for player control.
        ///   - language: Sets interface language using ISO 639-1 code or locale (e.g., "fr" or "pt-BR").
        ///   - captionLanguage: ISO 639-1 two-letter language code for closed captions (e.g., "en", "es").
        ///   - showCaptions: Forces closed captions display even if turned off in user preferences.
        ///   - restrictRelatedVideosToSameChannel: Controls whether related videos are restricted to the same channel.
        ///   - originURL: The domain origin URL. Default value `YouTubePlayer.Parameters.defaultOriginURL`
        ///   - referrerURL: URL where the player is embedded, used for YouTube Analytics tracking.
        public init(
            autoPlay: Bool? = nil,
            loopEnabled: Bool? = nil,
            startTime: Measurement<UnitDuration>? = nil,
            endTime: Measurement<UnitDuration>? = nil,
            showControls: Bool? = nil,
            showFullscreenButton: Bool? = nil,
            progressBarColor: ProgressBarColor? = nil,
            keyboardControlsDisabled: Bool? = nil,
            language: String? = nil,
            captionLanguage: String? = nil,
            showCaptions: Bool? = nil,
            restrictRelatedVideosToSameChannel: Bool? = nil,
            originURL: URL? = Self.defaultOriginURL,
            referrerURL: URL? = nil
        ) {
            self.autoPlay = autoPlay
            self.loopEnabled = loopEnabled
            self.startTime = startTime
            self.endTime = endTime
            self.startTime = startTime
            self.endTime = endTime
            self.showControls = showControls
            self.showFullscreenButton = showFullscreenButton
            self.progressBarColor = progressBarColor
            self.keyboardControlsDisabled = keyboardControlsDisabled
            self.language = language
            self.captionLanguage = captionLanguage
            self.showCaptions = showCaptions
            self.restrictRelatedVideosToSameChannel = restrictRelatedVideosToSameChannel
            self.originURL = originURL
            self.referrerURL = referrerURL
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
        // Verify query items are available
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = urlComponents.queryItems,
              !queryItems.isEmpty else {
            // Otherwise initialize with default values
            self.init()
            // Return out of initializer
            return
        }
        // Map query items to dictionary
        let queryParameters = [String: String](
            uniqueKeysWithValues: queryItems.compactMap { queryItem in
                guard let value = queryItem.value?.trimmingCharacters(in: .whitespaces),
                      !value.isEmpty else {
                    return nil
                }
                return (queryItem.name, value)
            }
        )
        /// Returns the value of a query parameter for a given coding key.
        /// - Parameter codingKeys: A coding key.
        func queryParameter(
            for codingKeys: CodingKeys
        ) -> String? {
            let queryParameter = queryParameters[codingKeys.rawValue]
            switch codingKeys {
            case .startTime:
                return queryParameter ?? queryParameters["t"]
            default:
                return queryParameter
            }
        }
        self.init(
            autoPlay: queryParameter(for: .autoPlay).flatMap(Int.init).flatMap(Bool.init(bit:)),
            loopEnabled: queryParameter(for: .loopEnabled).flatMap(Int.init).flatMap(Bool.init(bit:)),
            startTime: queryParameter(for: .startTime).flatMap(Int.init).flatMap { .init(value: .init($0), unit: .seconds) },
            endTime: queryParameter(for: .endTime).flatMap(Int.init).map { .init(value: .init($0), unit: .seconds) },
            showControls: queryParameter(for: .showControls).flatMap(Int.init).flatMap(Bool.init(bit:)),
            showFullscreenButton: queryParameter(for: .showFullscreenButton).flatMap(Int.init).flatMap(Bool.init(bit:)),
            progressBarColor: queryParameter(for: .progressBarColor).flatMap(ProgressBarColor.init),
            keyboardControlsDisabled: queryParameter(for: .keyboardControlsDisabled).flatMap(Int.init).flatMap(Bool.init(bit:)),
            language: queryParameter(for: .language),
            captionLanguage: queryParameter(for: .captionLanguage),
            showCaptions: queryParameter(for: .showCaptions).flatMap(Int.init).flatMap(Bool.init(bit:)),
            restrictRelatedVideosToSameChannel: queryParameter(for: .restrictRelatedVideosToSameChannel).flatMap(Int.init).flatMap(Bool.init(bit:)),
            originURL: queryParameter(for: .origin).flatMap(URL.init) ?? Self.defaultOriginURL,
            referrerURL: queryParameter(for: .referrer).flatMap(URL.init)
        )
    }
    
}

// MARK: - Default Origin URL

public extension YouTubePlayer.Parameters {
    
    /// The default origin URL.
    static let defaultOriginURL = URL(string: "https://youtubeplayer")
    
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

public extension YouTubePlayer.Parameters {
    
    /// A YouTube player list type.
    enum ListType: String, Codable, Hashable, Sendable, CaseIterable {
        /// Playlist
        case playlist
        /// Channel / User uploads
        case channel = "user_uploads"
    }
    
}

// MARK: - Encodable

extension YouTubePlayer.Parameters: EncodableWithConfiguration {
    
    /// The encoding configuration.
    public struct EncodingConfiguration: Codable, Hashable, Sendable {
        
        // MARK: Properties
        
        /// The source.
        public let source: YouTubePlayer.Source?
        
        /// A Boolean value that indicates whether HTML5 videos play inline or use the native full-screen controller.
        public let allowsInlineMediaPlayback: Bool
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer.Options.Parameters.EncodingConfiguration``
        /// - Parameters:
        ///   - source: The source. Default value `nil`
        ///   - allowsInlineMediaPlayback: A Boolean value that indicates whether HTML5 videos play inline or use the native full-screen controller. Default value `true`
        public init(
            source: YouTubePlayer.Source? = nil,
            allowsInlineMediaPlayback: Bool = true
        ) {
            self.source = source
            self.allowsInlineMediaPlayback = allowsInlineMediaPlayback
        }
        
    }
    
    /// The CodingKeys
    enum CodingKeys: String, CodingKey {
        case autoPlay = "autoplay"
        case loopEnabled = "loop"
        case startTime = "start"
        case endTime = "end"
        case showControls = "controls"
        case showFullscreenButton = "fs"
        case progressBarColor = "color"
        case keyboardControlsDisabled = "disablekb"
        case language = "hl"
        case captionLanguage = "cc_lang_pref"
        case showCaptions = "cc_load_policy"
        case restrictRelatedVideosToSameChannel = "rel"
        case origin
        case referrer = "widget_referrer"
        case list
        case listType
        case playlist
        case playInline = "playsinline"
        case enableJavaScriptAPI = "enablejsapi"
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
        try container.encodeIfPresent(self.loopEnabled?.bit, forKey: .loopEnabled)
        try container.encodeIfPresent(self.startTime.flatMap { Int($0.converted(to: .seconds).value) }, forKey: .startTime)
        try container.encodeIfPresent(self.endTime.flatMap { Int($0.converted(to: .seconds).value) }, forKey: .endTime)
        try container.encodeIfPresent(self.showControls?.bit, forKey: .showControls)
        try container.encodeIfPresent(self.showFullscreenButton?.bit, forKey: .showFullscreenButton)
        try container.encodeIfPresent(self.progressBarColor, forKey: .progressBarColor)
        try container.encodeIfPresent(self.keyboardControlsDisabled?.bit, forKey: .keyboardControlsDisabled)
        try container.encodeIfPresent(self.language, forKey: .language)
        try container.encodeIfPresent(self.captionLanguage, forKey: .captionLanguage)
        try container.encodeIfPresent(self.showCaptions?.bit, forKey: .showCaptions)
        try container.encodeIfPresent(self.restrictRelatedVideosToSameChannel?.bit, forKey: .restrictRelatedVideosToSameChannel)
        try container.encodeIfPresent(self.originURL, forKey: .origin)
        try container.encodeIfPresent(self.referrerURL, forKey: .referrer)
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
        try container.encodeIfPresent(configuration.allowsInlineMediaPlayback.bit, forKey: .playInline)
    }
    
}

// MARK: - Bool+bit

private extension Bool {
    
    /// The Binary Digit (bit) representation of this Bool value
    var bit: Int {
        self ? 1 : 0
    }
    
    /// Creates a Boolean value from a binary digit.
    /// - Parameter bit: An integer value that should be either 0 or 1
    /// - Returns: A boolean value where 1 maps to `true` and 0 maps to `false`, or `nil` if the input is not 0 or 1
    init?(bit: Int) {
        switch bit {
        case 0:
            self = false
        case 1:
            self = true
        default:
            return nil
        }
    }
    
}
