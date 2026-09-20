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
        
        /// The nonempty YouTube player script message handler name.
        public var youTubePlayerScriptMessageHandlerName: String
        
        /// Additional event names to subscribe to alongside the well-known events.
        /// - Note: The default HTML provider forwards these events through the event publisher.
        public var additionalEventNames: Set<YouTubePlayer.Event.Name>

        /// The YouTube player iFrame API source URL.
        public var youTubePlayerIframeAPISourceURL: URL
        
        /// A closure providing the template
        /// - Important: Please be cautious when providing a custom `HTMLProvider`. It is recommended to stick with the default implementation. However, if you want full control, you can provide a custom implementation.
        public var htmlProvider: HTMLProvider
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer/HTMLBuilder``
        /// - Parameters:
        ///   - youTubePlayerJavaScriptVariableName: The YouTube player JavaScrpt variable name. Default value `youtubePlayer`
        ///   - youTubePlayerScriptMessageHandlerName: The YouTube player script message handler name. Default value `youtubePlayerScriptMessageHandler`
        ///   - additionalEventNames: Additional YouTube IFrame API events to subscribe to. Default value `.init()`
        ///   - youTubePlayerIframeAPISourceURL: The YouTube player iFrame API source URL. Default value `https://www.youtube.com/iframe_api`
        ///   - htmlProvider: A closure which provides the HTML for the YouTube player. Default value `Self.defaultHTMLProvider()`
        ///  - Important: Please be cautious when providing a custom `HTMLProvider`. It is recommended to stick with the default implementation. However, if you want full control, you can provide a custom implementation.
        public init(
            youTubePlayerJavaScriptVariableName: String = "youtubePlayer",
            youTubePlayerScriptMessageHandlerName: String = "youtubePlayerScriptMessageHandler",
            additionalEventNames: Set<YouTubePlayer.Event.Name> = .init(),
            youTubePlayerIframeAPISourceURL: URL = .init(string: "https://www.youtube.com/iframe_api")!,
            htmlProvider: @escaping HTMLProvider = Self.defaultHTMLProvider()
        ) {
            self.youTubePlayerJavaScriptVariableName = youTubePlayerJavaScriptVariableName
            self.youTubePlayerScriptMessageHandlerName = youTubePlayerScriptMessageHandlerName
            self.additionalEventNames = additionalEventNames
            self.youTubePlayerIframeAPISourceURL = youTubePlayerIframeAPISourceURL
            self.htmlProvider = htmlProvider
        }
        
    }
    
}

// MARK: - Call as Function

public extension YouTubePlayer.HTMLBuilder {
    
    /// Builds the HTML.
    /// - Parameter jsonEncodedPlayerOptionsString: The JSON encoded YouTube player options string.
    /// - Throws: An error if the handler name is empty or the HTML provider fails.
    func callAsFunction(
        jsonEncodedPlayerOptionsString: YouTubePlayer.Options.JSONEncodedString
    ) throws -> String {
        try self.validate()
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
            && lhs.youTubePlayerScriptMessageHandlerName == rhs.youTubePlayerScriptMessageHandlerName
            && lhs.additionalEventNames == rhs.additionalEventNames
            && lhs.youTubePlayerIframeAPISourceURL == rhs.youTubePlayerIframeAPISourceURL
    }
    
}

// MARK: - Hashable

extension YouTubePlayer.HTMLBuilder: Hashable {
    
    /// Hashes the essential components of this value by feeding them into the given hasher.
    /// - Parameter hasher: The hasher to use when combining the components of this instance.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.youTubePlayerJavaScriptVariableName)
        hasher.combine(self.youTubePlayerScriptMessageHandlerName)
        hasher.combine(self.additionalEventNames)
        hasher.combine(self.youTubePlayerIframeAPISourceURL)
    }
    
}

// MARK: - Codable

extension YouTubePlayer.HTMLBuilder: Codable {
    
    /// The coding keys.
    private enum CodingKeys: CodingKey {
        case youTubePlayerJavaScriptVariableName
        case youTubePlayerScriptMessageHandlerName
        case additionalEventNames
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
            youTubePlayerScriptMessageHandlerName: container.decode(String.self, forKey: .youTubePlayerScriptMessageHandlerName),
            additionalEventNames: container.decode(Set<YouTubePlayer.Event.Name>.self, forKey: .additionalEventNames),
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
        try container.encode(self.youTubePlayerScriptMessageHandlerName, forKey: .youTubePlayerScriptMessageHandlerName)
        try container.encode(self.additionalEventNames, forKey: .additionalEventNames)
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
            try htmlBuilder.validate()
            let eventNames = Set(YouTubePlayer.Event.Name.allCases)
                .union(htmlBuilder.additionalEventNames)
                .subtracting(excludedEventNames)
                .subtracting([.iFrameApiReady, .iFrameApiFailedToLoad])
                .map(\.rawValue)
                .sorted()
            let messageHandlerName = try Self.javaScriptString(htmlBuilder.youTubePlayerScriptMessageHandlerName)
            let eventNamesJSON = try Self.javaScriptString(eventNames)
            let playerVariableName = try Self.javaScriptString(htmlBuilder.youTubePlayerJavaScriptVariableName)
            return """
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
            
                <script>
                    var \(htmlBuilder.youTubePlayerJavaScriptVariableName);

                    function onYouTubeIframeAPIReady() {
                        const playerOptions = \(jsonEncodedPlayerOptionsString);
                        playerOptions.events = Object.fromEntries(
                            \(eventNamesJSON).map(eventName => [
                                eventName,
                                event => sendYouTubePlayerEvent(eventName, event)
                            ])
                        );
                        window[\(playerVariableName)] = new YT.Player(
                            \(playerVariableName),
                            playerOptions
                        );
                        window[\(playerVariableName)].setSize(
                            window.innerWidth,
                            window.innerHeight
                        );
                        sendYouTubePlayerEvent('\(YouTubePlayer.Event.Name.iFrameApiReady.rawValue)');
                    }
            
                    function sendYouTubePlayerEvent(eventName, event) {
                        window.webkit.messageHandlers[\(messageHandlerName)].postMessage(
                            {
                                \(YouTubePlayer.Event.CodingKeys.name.stringValue): eventName,
                                \(YouTubePlayer.Event.CodingKeys.data.stringValue): (event == null || event.data == null) ? null : (typeof event.data === 'object' ? JSON.stringify(event.data) : String(event.data))
                            }
                        );
                    }

                </script>
                <script src="\(htmlBuilder.youTubePlayerIframeAPISourceURL)"
                    onerror="sendYouTubePlayerEvent('\(YouTubePlayer.Event.Name.iFrameApiFailedToLoad.rawValue)')">
                </script>
            </body>
            </html>
            """
        }
    }
    
}

// MARK: - Validation

extension YouTubePlayer.HTMLBuilder {

    /// Validates the message handler name before building HTML or registering with WebKit.
    /// - Throws: An API error if the message handler name is empty.
    func validate() throws(YouTubePlayer.APIError) {
        guard !self.youTubePlayerScriptMessageHandlerName.isEmpty else {
            throw .init(
                reason: "The YouTube player script message handler name must not be empty."
            )
        }
    }

}

// MARK: - JavaScript Encoding

private extension YouTubePlayer.HTMLBuilder {

    /// Encodes a value for use inside an HTML script element.
    /// - Parameter value: The value to encode as JSON.
    /// - Returns: JSON that cannot terminate the enclosing script element.
    /// - Throws: An error if the value cannot be encoded.
    static func javaScriptString(
        _ value: some Encodable
    ) throws -> String {
        return String(
            decoding: try JSONEncoder().encode(value),
            as: UTF8.self
        )
        .replacingOccurrences(of: "<", with: "\\u003C")
        .replacingOccurrences(of: "\u{2028}", with: "\\u2028")
        .replacingOccurrences(of: "\u{2029}", with: "\\u2029")
    }

}
