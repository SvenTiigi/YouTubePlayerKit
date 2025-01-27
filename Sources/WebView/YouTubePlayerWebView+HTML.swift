import Foundation

// MARK: - YouTubePlayerWebView+HTML

extension YouTubePlayerWebView {
    
    /// A YouTube player web view HTML.
    struct HTML: Codable, Hashable, Sendable {
        
        // MARK: Static-Properties
        
        /// The JavaScript source URL string.
        static let javaScriptSourceURLString = "https://www.youtube.com/iframe_api"
        
        /// The JavaScript player variable name.
        static let javaScriptPlayerVariableName = "youtubePlayer"
        
        /// The JavaScript event callback URL scheme
        static let javaScriptEventCallbackURLScheme = "youtubeplayer"
        
        /// The JavaScript event callback data parameter name
        static let javaScriptEventCallbackDataParameterName = "data"
        
        // MARK: Properties
        
        /// The contents.
        let contents: String
        
        /// The player options JSON string.
        let playerOptionsJSON: String
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayerWebView.HTML``
        /// - Parameters:
        ///   - contents: The contents.
        ///   - playerOptionsJSON: The player options JSON string.
        private init(
            contents: String,
            playerOptionsJSON: String
        ) {
            self.contents = contents
            self.playerOptionsJSON = playerOptionsJSON
        }
        
    }
    
}

// MARK: - Initializer

extension YouTubePlayerWebView.HTML {
    
    /// Creates a new instance of ``YouTubePlayerWebView.HTML``
    /// - Parameters:
    ///   - source: The source.
    ///   - parameters: The parameters.
    ///   - originURL: The origin URL. Default value `nil`
    ///   - allowsInlineMediaPlayback: A Boolean value that indicates whether HTML5 videos can play Picture in Picture. Default value `true`
    init(
        source: YouTubePlayer.Source?,
        parameters: YouTubePlayer.Parameters,
        originURL: URL? = nil,
        allowsInlineMediaPlayback: Bool = true
    ) throws {
        // Initialize Options
        let options = JavaScriptPlayerOptions(
            source: source,
            parameters: parameters
        )
        // Try to encode options
        let encodedOptions: Data = try {
            // Initialize JSONEncoder
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = [.withoutEscapingSlashes]
            // Initialize encoding configuration
            let optionsEncodingConfiguration = JavaScriptPlayerOptions.EncodingConfiguration(
                originURL: originURL,
                allowsInlineMediaPlayback: allowsInlineMediaPlayback
            )
            // Check if iOS 17 or macOS 14.0 or greater are available
            if #available(iOS 17.0, macOS 14.0, visionOS 1.0, *) {
                // Try to encode with configuration
                return try jsonEncoder.encode(
                    options,
                    configuration: optionsEncodingConfiguration
                )
            } else {
                /// An encoding container
                struct EncodingContainer: Encodable {
                    /// The JavaScript player options.
                    let options: JavaScriptPlayerOptions
                    
                    /// The JavaScript player options encoding configuration.
                    let encodingConfiguration: JavaScriptPlayerOptions.EncodingConfiguration
                    
                    /// Encode.
                    /// - Parameter encoder: The encoder.
                    func encode(
                        to encoder: Encoder
                    ) throws {
                        try self.options.encode(
                            to: encoder,
                            configuration: self.encodingConfiguration
                        )
                    }
                }
                // Try to encode encoding container
                return try jsonEncoder
                    .encode(
                        EncodingContainer(
                            options: options,
                            encodingConfiguration: optionsEncodingConfiguration
                        )
                    )
            }
        }()
        let javaScriptPlayerOptions = String(
            decoding: encodedOptions,
            as: UTF8.self
        )
        self.init(
            contents: Self.template(
                javaScriptSourceURLString: Self.javaScriptSourceURLString,
                javaScriptPlayerVariableName: Self.javaScriptPlayerVariableName,
                javaScriptEventCallbackURLScheme: Self.javaScriptEventCallbackURLScheme,
                javaScriptEventCallbackDataParameterName: Self.javaScriptEventCallbackDataParameterName,
                javaScriptPlayerOptions: javaScriptPlayerOptions
            ),
            playerOptionsJSON: javaScriptPlayerOptions
        )
    }
    
}

// MARK: - JavaScriptPlayerOptions

private extension YouTubePlayerWebView.HTML {
    
    /// The JavaScript player options.
    struct JavaScriptPlayerOptions: EncodableWithConfiguration {
        
        // MARK: Properties
        
        /// The source.
        var source: YouTubePlayer.Source?
        
        /// The parameters.
        var parameters: YouTubePlayer.Parameters
        
        // MARK: EncodableWithConfiguration
        
        /// The encoding configuration.
        struct EncodingConfiguration {
            
            /// The origin URL.
            let originURL: URL?
            
            /// A Boolean value that indicates whether HTML5 videos play inline or use the native full-screen controller.
            let allowsInlineMediaPlayback: Bool
            
        }
        
        /// The coding keys.
        private enum CodingKeys: CodingKey {
            case width
            case height
            case videoId
            case playerVars
            case events
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
            try container.encode("100%", forKey: .width)
            try container.encode("100%", forKey: .height)
            if case .video(let id) = self.source {
                try container.encode(id, forKey: .videoId)
            }
            try container.encode(
                self.parameters,
                forKey: .playerVars,
                configuration: .init(
                    source: self.source,
                    originURL: configuration.originURL,
                    allowsInlineMediaPlayback: configuration.allowsInlineMediaPlayback
                )
            )
            try container.encode(
                YouTubePlayer
                    .JavaScriptEvent
                    .Name
                    .allCases
                    .filter { event in
                        // Exclude onIframe related events
                        event != .onIframeApiReady && event != .onIframeApiFailedToLoad
                    }
                    .reduce(
                        into: [String: String]()
                    ) { result, event in
                        result[event.rawValue] = event.rawValue
                    },
                forKey: .events
            )
        }
        
    }
    
}

// MARK: - Template

private extension YouTubePlayerWebView.HTML {
    
    /// The HTML template.
    /// - Parameters:
    ///   - javaScriptSourceURLString: The JavaScript source URL string.
    ///   - javaScriptPlayerVariableName: The JavaScript player variable name.
    ///   - javaScriptEventCallbackURLScheme: The JavaScript event callback URL scheme.
    ///   - javaScriptEventCallbackDataParameterName: The JavaScript event callback data parameter name.
    ///   - javaScriptPlayerOptions: The JavaScript player options.
    static func template(
        javaScriptSourceURLString: String,
        javaScriptPlayerVariableName: String,
        javaScriptEventCallbackURLScheme: String,
        javaScriptEventCallbackDataParameterName: String,
        javaScriptPlayerOptions: String
    ) -> String {
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
                <div id="\(javaScriptPlayerVariableName)"></div>
            </div>
        
            <script src="\(javaScriptSourceURLString)"
                onerror="window.location.href='\(javaScriptEventCallbackURLScheme)://\(YouTubePlayer.JavaScriptEvent.Name.onIframeApiFailedToLoad.rawValue)'">
            </script>
        
            <script>
                var \(javaScriptPlayerVariableName);

                function onYouTubeIframeAPIReady() {
                    \(javaScriptPlayerVariableName) = new YT.Player(
                        '\(javaScriptPlayerVariableName)',
                        \(javaScriptPlayerOptions)
                    );
                    \(javaScriptPlayerVariableName).setSize(
                        window.innerWidth,
                        window.innerHeight
                    );
                    sendYouTubePlayerEvent('\(YouTubePlayer.JavaScriptEvent.Name.onIframeApiReady.rawValue)');
                }
        
                function sendYouTubePlayerEvent(eventName, event) {
                    const url = new URL(`\(javaScriptEventCallbackURLScheme)://${eventName}`);
                    if (event && event.data !== null) {
                        url.searchParams.set('\(javaScriptEventCallbackDataParameterName)', event.data);
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
