import Foundation

// MARK: - YouTubePlayer+HTMLBuilder

public extension YouTubePlayer {
    
    /// A YouTube player HTML builder object.
    struct HTMLBuilder: Sendable {
        
        // MARK: Typealias
        
        /// The JSON encoded YouTube player options.
        public typealias JSONEncodedYouTubePlayerOptions = String
        
        /// A function type that provides the HTML content string based on builder configuration and the JSON encoded YouTube player options.
        public typealias HTMLProvider = @Sendable (Self, JSONEncodedYouTubePlayerOptions) throws -> String
        
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
        public var htmlProvider: HTMLProvider
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer.HTMLBuilder``
        /// - Parameters:
        ///   - youTubePlayerJavaScriptVariableName: The YouTube player JavaScrpt variable name. Default value `youtubePlayer`
        ///   - youTubePlayerEventCallbackURLScheme: The YouTube player event callback url scheme. Default value `youtubeplayer`
        ///   - youTubePlayerEventCallbackDataParameterName: The YouTube player event callback data parameter name. Default value `data`
        ///   - youTubePlayerIframeAPISourceURL: The YouTube player iFrame API source URL. Default value `https://www.youtube.com/iframe_api`
        public init(
            youTubePlayerJavaScriptVariableName: String = "youtubePlayer",
            youTubePlayerEventCallbackURLScheme: String = "youtubeplayer",
            youTubePlayerEventCallbackDataParameterName: String = "data",
            youTubePlayerIframeAPISourceURL: URL = .init(string: "https://www.youtube.com/iframe_api")!,
            htmlProvider: @escaping HTMLProvider = Self.defaultHTMLProvider
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
    /// - Parameter jsonEncodedYouTubePlayerOptions: The JSON encoded YouTube player options.
    func callAsFunction(
        jsonEncodedYouTubePlayerOptions: JSONEncodedYouTubePlayerOptions
    ) throws -> String {
        return try self.htmlProvider(
            self,
            jsonEncodedYouTubePlayerOptions
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

// MARK: - Default HTML Provider

public extension YouTubePlayer.HTMLBuilder {
    
    /// The default HTML provider.
    static let defaultHTMLProvider: HTMLProvider = { htmlBuilder, jsonEncodedYouTubePlayerOptions in
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
                onerror="window.location.href='\(htmlBuilder.youTubePlayerEventCallbackURLScheme)://\(YouTubePlayer.JavaScriptEvent.Name.onIframeApiFailedToLoad.rawValue)'">
            </script>
        
            <script>
                var \(htmlBuilder.youTubePlayerJavaScriptVariableName);

                function onYouTubeIframeAPIReady() {
                    \(htmlBuilder.youTubePlayerJavaScriptVariableName) = new YT.Player(
                        '\(htmlBuilder.youTubePlayerJavaScriptVariableName)',
                        \(jsonEncodedYouTubePlayerOptions)
                    );
                    \(htmlBuilder.youTubePlayerJavaScriptVariableName).setSize(
                        window.innerWidth,
                        window.innerHeight
                    );
                    sendYouTubePlayerEvent('\(YouTubePlayer.JavaScriptEvent.Name.onIframeApiReady.rawValue)');
                }
        
                function sendYouTubePlayerEvent(eventName, event) {
                    const url = new URL(`\(htmlBuilder.youTubePlayerEventCallbackURLScheme)://${eventName}`);
                    if (event && event.data !== null) {
                        url.searchParams.set('\(htmlBuilder.youTubePlayerEventCallbackDataParameterName)', event.data);
                    }
                    window.location.href = url.toString();
                }

                \(
                    YouTubePlayer
                        .JavaScriptEvent
                        .Name
                        .allCases
                        .filter { $0 != .onIframeApiReady && $0 != .onIframeApiFailedToLoad }
                        .map { javaScriptEventName in
                            """
                            function \(javaScriptEventName)(event) {
                                sendYouTubePlayerEvent('\(javaScriptEventName)', event);
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
