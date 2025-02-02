import Foundation

// MARK: - YouTubePlayer+Parameters

public extension YouTubePlayer {
    
    /// The YouTube player parameters.
    /// - SeeAlso: [YouTube Player Parameters Documentation](https://developers.google.com/youtube/player_parameters)
    /// - Note: The parameters `list`, `listType`, `playlist`, `playsinline`, `enablejsapi` are not directly configurable.
    /// The YouTubePlayerKit automatically sets these paramters based on the provided ``YouTubePlayer/Source`` and ``YouTubePlayer/Configuration``
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
        
        /// Creates a new instance of ``YouTubePlayer/Parameters``
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
    
    /// Creates a new instance of ``YouTubePlayer/Parameters``
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
            autoPlay: queryParameter(for: .autoPlay).flatMap(Bit.init)?.value,
            loopEnabled: queryParameter(for: .loopEnabled).flatMap(Bit.init)?.value,
            startTime: queryParameter(for: .startTime).flatMap(Int.init).flatMap { .init(value: .init($0), unit: .seconds) },
            endTime: queryParameter(for: .endTime).flatMap(Int.init).map { .init(value: .init($0), unit: .seconds) },
            showControls: queryParameter(for: .showControls).flatMap(Bit.init)?.value,
            showFullscreenButton: queryParameter(for: .showFullscreenButton).flatMap(Bit.init)?.value,
            progressBarColor: queryParameter(for: .progressBarColor).flatMap(ProgressBarColor.init),
            keyboardControlsDisabled: queryParameter(for: .keyboardControlsDisabled).flatMap(Bit.init)?.value,
            language: queryParameter(for: .language),
            captionLanguage: queryParameter(for: .captionLanguage),
            showCaptions: queryParameter(for: .showCaptions).flatMap(Bit.init)?.value,
            restrictRelatedVideosToSameChannel: queryParameter(for: .restrictRelatedVideosToSameChannel).flatMap(Bit.init)?.value,
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

// MARK: - CodingKeys

public extension YouTubePlayer.Parameters {
    
    /// The coding keys.
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
    
}

// MARK: - Decodable

extension YouTubePlayer.Parameters: Decodable {
    
    /// Creates a new instance of ``YouTubePlayer/Parameters``
    /// - Parameter decoder: The decoder.
    public init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            autoPlay: container.decodeIfPresent(Bit.self, forKey: .autoPlay)?.value,
            loopEnabled: container.decodeIfPresent(Bit.self, forKey: .loopEnabled)?.value,
            startTime: container.decodeIfPresent(Double.self, forKey: .startTime).flatMap { .init(value: $0, unit: .seconds) },
            endTime: container.decodeIfPresent(Double.self, forKey: .endTime).flatMap { .init(value: $0, unit: .seconds) },
            showControls: container.decodeIfPresent(Bit.self, forKey: .showControls)?.value,
            showFullscreenButton: container.decodeIfPresent(Bit.self, forKey: .showFullscreenButton)?.value,
            progressBarColor: container.decodeIfPresent(ProgressBarColor.self, forKey: .progressBarColor),
            keyboardControlsDisabled: container.decodeIfPresent(Bit.self, forKey: .keyboardControlsDisabled)?.value,
            language: container.decodeIfPresent(String.self, forKey: .language),
            captionLanguage: container.decodeIfPresent(String.self, forKey: .captionLanguage),
            showCaptions: container.decodeIfPresent(Bit.self, forKey: .showCaptions)?.value,
            restrictRelatedVideosToSameChannel: container.decodeIfPresent(Bit.self, forKey: .restrictRelatedVideosToSameChannel)?.value,
            originURL: container.decodeIfPresent(URL.self, forKey: .origin),
            referrerURL: container.decodeIfPresent(URL.self, forKey: .referrer)
        )
    }
    
}

// MARK: - EncodableWithConfiguration

extension YouTubePlayer.Parameters: EncodableWithConfiguration {
    
    /// The encoding configuration.
    public struct EncodingConfiguration: Codable, Hashable, Sendable {
        
        // MARK: Properties
        
        /// The source.
        public let source: YouTubePlayer.Source?
        
        /// A Boolean value that indicates whether HTML5 videos play inline or use the native full-screen controller.
        public let allowsInlineMediaPlayback: Bool
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer/Parameters/EncodingConfiguration``
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
    
    /// Encode.
    /// - Parameters:
    ///   - encoder: The encoder.
    ///   - configuration: The configuration.
    public func encode(
        to encoder: Encoder,
        configuration: EncodingConfiguration
    ) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.autoPlay.flatMap(Bit.init), forKey: .autoPlay)
        try container.encodeIfPresent(self.loopEnabled.flatMap(Bit.init), forKey: .loopEnabled)
        try container.encodeIfPresent(self.startTime.flatMap { Int($0.converted(to: .seconds).value) }, forKey: .startTime)
        try container.encodeIfPresent(self.endTime.flatMap { Int($0.converted(to: .seconds).value) }, forKey: .endTime)
        try container.encodeIfPresent(self.showControls.flatMap(Bit.init), forKey: .showControls)
        try container.encodeIfPresent(self.showFullscreenButton.flatMap(Bit.init), forKey: .showFullscreenButton)
        try container.encodeIfPresent(self.progressBarColor, forKey: .progressBarColor)
        try container.encodeIfPresent(self.keyboardControlsDisabled.flatMap(Bit.init), forKey: .keyboardControlsDisabled)
        try container.encodeIfPresent(self.language, forKey: .language)
        try container.encodeIfPresent(self.captionLanguage, forKey: .captionLanguage)
        try container.encodeIfPresent(self.showCaptions.flatMap(Bit.init), forKey: .showCaptions)
        try container.encodeIfPresent(self.restrictRelatedVideosToSameChannel.flatMap(Bit.init), forKey: .restrictRelatedVideosToSameChannel)
        try container.encodeIfPresent(self.originURL, forKey: .origin)
        try container.encodeIfPresent(self.referrerURL, forKey: .referrer)
        try container.encode(Bit(true), forKey: .enableJavaScriptAPI)
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
        try container.encodeIfPresent(Bit(configuration.allowsInlineMediaPlayback), forKey: .playInline)
    }
    
}

// MARK: - Bit

/// A Binary Digit (bit).
private struct Bit: Codable, Hashable, Sendable {
    
    // MARK: Properties
    
    /// The value.
    let value: Bool
    
    // MARK: Initializer
    
    /// Creates a new instance of ``Bit``
    /// - Parameter value: The value.
    init(
        _ value: Bool
    ) {
        self.value = value
    }
    
    /// Creates a new instance of ``Bit``
    /// - Parameter int: The integer value.
    init?(
        _ int: Int
    ) {
        switch int {
        case 0:
            self.init(false)
        case 1:
            self.init(true)
        default:
            return nil
        }
    }
    
    /// Creates a new instance of ``Bit``
    /// - Parameter string: The string value.
    init?(
        _ string: String
    ) {
        guard !string.isEmpty else {
            return nil
        }
        if let int = Int(string), let bit = Bit(int) {
            self = bit
        } else if let bool = Bool(string) {
            self.init(bool)
        } else {
            return nil
        }
    }
    
    // MARK: Decodable
    
    /// Creates a new instance of ``Bit``
    /// - Parameter decoder: The decoder.
    init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.singleValueContainer()
        if let bool = try? container.decode(Bool.self) {
            self.init(bool)
        } else if let int = try? container.decode(Int.self), let bit = Bit(int) {
            self = bit
        } else if let string = try? container.decode(String.self), let bit = Bit(string) {
            self = bit
        } else {
            throw DecodingError
                .dataCorruptedError(
                    in: container,
                    debugDescription: "Unsupported bit representation"
                )
        }
    }
    
    // MARK: Encodable
    
    /// Encode.
    /// - Parameter encoder: The encoder.
    func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.value ? 1 : 0)
    }
    
}
