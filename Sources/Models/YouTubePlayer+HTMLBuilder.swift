import Foundation

// MARK: - YouTubePlayer+HTMLBuilder

public extension YouTubePlayer {
    
    /// A YouTube player HTML builder object.
    struct HTMLBuilder: Sendable {
        
        // MARK: Typealias
        
        /// A function type that provides the HTML content string based on builder configuration and the JSON encoded YouTube player options.
        public typealias HTMLProvider = @Sendable (Self, YouTubePlayer.Options.JSONEncodedString) throws -> String
        
        // MARK: Properties
        
        /// The YouTube player JavaScrpt variable name.
        public var youTubePlayerJavaScriptVariableName: String
        
        /// The YouTube player event callback url scheme.
        public var youTubePlayerEventCallbackURLScheme: String
        
        /// The YouTube player event callback data parameter name.
        public var youTubePlayerEventCallbackDataParameterName: String
        
        /// The YouTube player iFrame API source URL.
        public var youTubePlayerIframeAPISourceURL: URL
        
        /// A closure providing the template
        /// - Important: Please be cautious when providing a custom `HTMLProvider`. It is recommended to stick with the default implementation. However, if you want full control, you can provide a custom implementation.
        public var htmlProvider: HTMLProvider
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer/HTMLBuilder``
        /// - Parameters:
        ///   - youTubePlayerJavaScriptVariableName: The YouTube player JavaScrpt variable name. Default value `youtubePlayer`
        ///   - youTubePlayerEventCallbackURLScheme: The YouTube player event callback url scheme. Default value `youtubeplayer`
        ///   - youTubePlayerEventCallbackDataParameterName: The YouTube player event callback data parameter name. Default value `data`
        ///   - youTubePlayerIframeAPISourceURL: The YouTube player iFrame API source URL. Default value `https://www.youtube.com/iframe_api`
        ///   - htmlProvider: A closure which provides the HTML for the YouTube player. Default value `Self.defaultHTMLProvider()`
        ///  - Important: Please be cautious when providing a custom `HTMLProvider`. It is recommended to stick with the default implementation. However, if you want full control, you can provide a custom implementation.
        public init(
            youTubePlayerJavaScriptVariableName: String = "youtubePlayer",
            youTubePlayerEventCallbackURLScheme: String = "youtubeplayer",
            youTubePlayerEventCallbackDataParameterName: String = "data",
            youTubePlayerIframeAPISourceURL: URL = .init(string: "https://www.youtube.com/iframe_api")!,
            htmlProvider: @escaping HTMLProvider = Self.defaultHTMLProvider()
        ) {
            self.youTubePlayerJavaScriptVariableName = youTubePlayerJavaScriptVariableName
            self.youTubePlayerEventCallbackURLScheme = youTubePlayerEventCallbackURLScheme
            self.youTubePlayerEventCallbackDataParameterName = youTubePlayerEventCallbackDataParameterName
            self.youTubePlayerIframeAPISourceURL = youTubePlayerIframeAPISourceURL
            self.htmlProvider = htmlProvider
        }
        
    }
    
}

// MARK: - Call as Function

public extension YouTubePlayer.HTMLBuilder {
    
    /// Builds the HTML.
    /// - Parameter jsonEncodedPlayerOptionsString: The JSON encoded YouTube player options string.
    func callAsFunction(
        jsonEncodedPlayerOptionsString: YouTubePlayer.Options.JSONEncodedString
    ) throws -> String {
        return try self.htmlProvider(
            self,
            jsonEncodedPlayerOptionsString
        )
    }
    
}

// MARK: - Equatable

extension YouTubePlayer.HTMLBuilder: Equatable {
    
    /// Returns a Boolean value indicating whether two values are equal.
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        lhs.youTubePlayerJavaScriptVariableName == rhs.youTubePlayerJavaScriptVariableName
            && lhs.youTubePlayerEventCallbackURLScheme == rhs.youTubePlayerEventCallbackURLScheme
            && lhs.youTubePlayerEventCallbackDataParameterName == rhs.youTubePlayerEventCallbackDataParameterName
            && lhs.youTubePlayerIframeAPISourceURL == rhs.youTubePlayerIframeAPISourceURL
    }
    
}

// MARK: - Hashable

extension YouTubePlayer.HTMLBuilder: Hashable {
    
    /// Hashes the essential components of this value by feeding them into the given hasher.
    /// - Parameter hasher: The hasher to use when combining the components of this instance.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.youTubePlayerJavaScriptVariableName)
        hasher.combine(self.youTubePlayerEventCallbackURLScheme)
        hasher.combine(self.youTubePlayerEventCallbackDataParameterName)
        hasher.combine(self.youTubePlayerIframeAPISourceURL)
    }
    
}

// MARK: - Codable

extension YouTubePlayer.HTMLBuilder: Codable {
    
    /// The coding keys.
    private enum CodingKeys: CodingKey {
        case youTubePlayerJavaScriptVariableName
        case youTubePlayerEventCallbackURLScheme
        case youTubePlayerEventCallbackDataParameterName
        case youTubePlayerIframeAPISourceURL
    }
    
    /// Creates a new instance of ``YouTubePlayer/HTMLBuilder``
    /// - Parameter decoder: The decoder.
    public init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            youTubePlayerJavaScriptVariableName: container.decode(String.self, forKey: .youTubePlayerJavaScriptVariableName),
            youTubePlayerEventCallbackURLScheme: container.decode(String.self, forKey: .youTubePlayerEventCallbackURLScheme),
            youTubePlayerEventCallbackDataParameterName: container.decode(String.self, forKey: .youTubePlayerEventCallbackDataParameterName),
            youTubePlayerIframeAPISourceURL: container.decode(URL.self, forKey: .youTubePlayerIframeAPISourceURL)
        )
    }
    
    /// Encode.
    /// - Parameter encoder: The encoder.
    public func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.youTubePlayerJavaScriptVariableName, forKey: .youTubePlayerJavaScriptVariableName)
        try container.encode(self.youTubePlayerEventCallbackURLScheme, forKey: .youTubePlayerEventCallbackURLScheme)
        try container.encode(self.youTubePlayerEventCallbackDataParameterName, forKey: .youTubePlayerEventCallbackDataParameterName)
        try container.encode(self.youTubePlayerIframeAPISourceURL, forKey: .youTubePlayerIframeAPISourceURL)
    }
    
}

// MARK: - Default HTML Provider

public extension YouTubePlayer.HTMLBuilder {
    
    /// The default HTML provider.
    /// - Parameter excludedEventNames: The event names which should be excluded. Default value `.init()`
    static func defaultHTMLProvider(
        excludedEventNames: Set<YouTubePlayer.Event.Name> = .init()
    ) -> HTMLProvider {
        { htmlBuilder, jsonEncodedPlayerOptionsString in
            """
            <!DOCTYPE html>
            <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no">
                <style>
                    body {
                        margin: 0;
                        width: 100%;
                        height: 100%;
                    }
                    html {
                        width: 100%;
                        height: 100%;
                    }
                    .player-container iframe,
                    .player-container object,
                    .player-container embed {
                        position: absolute;
                        top: 0;
                        left: 0;
                        width: 100% !important;
                        height: 100% !important;
                    }
                    ::-webkit-scrollbar {
                        display: none !important;
                    }
                </style>
            </head>
            <body>
                <div class="player-container">
                    <div id="\(htmlBuilder.youTubePlayerJavaScriptVariableName)"></div>
                </div>
            
                <script src="\(htmlBuilder.youTubePlayerIframeAPISourceURL)"
                    onerror="window.location.href='\(htmlBuilder.youTubePlayerEventCallbackURLScheme)://\(YouTubePlayer.Event.Name.iFrameApiFailedToLoad.rawValue)'">
                </script>
            
                <script>
                    var \(htmlBuilder.youTubePlayerJavaScriptVariableName);

                    function onYouTubeIframeAPIReady() {
                        \(htmlBuilder.youTubePlayerJavaScriptVariableName) = new YT.Player(
                            '\(htmlBuilder.youTubePlayerJavaScriptVariableName)',
                            \(jsonEncodedPlayerOptionsString)
                        );
                        \(htmlBuilder.youTubePlayerJavaScriptVariableName).setSize(
                            window.innerWidth,
                            window.innerHeight
                        );
                        sendYouTubePlayerEvent('\(YouTubePlayer.Event.Name.iFrameApiReady.rawValue)');
                    }
            
                    function sendYouTubePlayerEvent(eventName, event) {
                        const url = new URL(`\(htmlBuilder.youTubePlayerEventCallbackURLScheme)://${eventName}`);
                        if (event && event.data !== null) {
                            url.searchParams.set(
                                '\(htmlBuilder.youTubePlayerEventCallbackDataParameterName)',
                                typeof event.data === 'object' ? JSON.stringify(event.data) : event.data
                            );
                        }
                        window.location.href = url.toString();
                    }

                    \(
                        YouTubePlayer
                            .Event
                            .Name
                            .allCases
                            .filter { $0 != .iFrameApiReady && $0 != .iFrameApiFailedToLoad }
                            .filter { !excludedEventNames.contains($0) }
                            .map(\.rawValue)
                            .map { eventName in
                                """
                                function \(eventName)(event) {
                                    sendYouTubePlayerEvent('\(eventName)', event);
                                }
                                """
                            }
                            .joined(separator: "\n\n")
                    )
                </script>
            </body>
            </html>
            """
        }
    }
    
}
