import Foundation

// MARK: - YouTubePlayer+JavaScriptPlayerOptions

public extension YouTubePlayer {
    
    /// The YouTube player JavaScript options.
    struct JavaScriptPlayerOptions: Hashable, Sendable {
        
        // MARK: Properties
        
        /// The source.
        public var source: YouTubePlayer.Source?
        
        /// The parameters.
        public var parameters: YouTubePlayer.Parameters
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer.JavaScriptPlayerOptions``
        /// - Parameters:
        ///   - source: The source. Default value `nil`
        ///   - parameters: The parameters.
        public init(
            source: YouTubePlayer.Source? = nil,
            parameters: YouTubePlayer.Parameters
        ) {
            self.source = source
            self.parameters = parameters
        }
        
    }
    
}

// MARK: - EncodableWithConfiguration

extension YouTubePlayer.JavaScriptPlayerOptions: EncodableWithConfiguration {
    
    /// The encoding configuration.
    public struct EncodingConfiguration: Codable, Hashable, Sendable {
        
        // MARK: Properties
        
        /// A Boolean value that indicates whether HTML5 videos play inline or use the native full-screen controller.
        let allowsInlineMediaPlayback: Bool
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer.JavaScriptPlayerOptions.EncodingConfiguration``
        /// - Parameter allowsInlineMediaPlayback: A Boolean value that indicates whether HTML5 videos play inline or use the native full-screen controller.
        public init(
            allowsInlineMediaPlayback: Bool
        ) {
            self.allowsInlineMediaPlayback = allowsInlineMediaPlayback
        }
        
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

// MARK: - JSON Encode

public extension YouTubePlayer.JavaScriptPlayerOptions {
    
    /// JSON encodes this instance.
    /// - Parameters:
    ///   - configuration: The encoding configuration.
    ///   - jsonEncoder: The JSON encoder.
    func jsonEncode(
        configuration: EncodingConfiguration,
        jsonEncoder: JSONEncoder = {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = [
                .sortedKeys,
                .withoutEscapingSlashes
            ]
            return jsonEncoder
        }()
    ) throws -> Data {
        // Check if iOS 17 or macOS 14.0 or greater are available
        if #available(iOS 17.0, macOS 14.0, visionOS 1.0, *) {
            // Try to encode with configuration
            return try jsonEncoder.encode(
                self,
                configuration: configuration
            )
        } else {
            /// An encoding container
            struct EncodingContainer: Encodable {
                /// The JavaScript player options.
                let options: YouTubePlayer.JavaScriptPlayerOptions
                
                /// The JavaScript player options encoding configuration.
                let encodingConfiguration: YouTubePlayer.JavaScriptPlayerOptions.EncodingConfiguration
                
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
                        options: self,
                        encodingConfiguration: configuration
                    )
                )
        }
    }
    
}
