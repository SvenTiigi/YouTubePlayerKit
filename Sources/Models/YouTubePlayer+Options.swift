import Foundation

// MARK: - YouTubePlayer+Options

public extension YouTubePlayer {
    
    /// The YouTube player options.
    struct Options: Hashable, Sendable {
        
        // MARK: Properties
        
        /// The source.
        public var source: YouTubePlayer.Source?
        
        /// The parameters.
        public var parameters: YouTubePlayer.Parameters
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer/Options``
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

extension YouTubePlayer.Options: EncodableWithConfiguration {
    
    /// The encoding configuration.
    public struct EncodingConfiguration: Codable, Hashable, Sendable {
        
        // MARK: Properties
        
        /// A Boolean value that indicates whether HTML5 videos play inline or use the native full-screen controller.
        let allowsInlineMediaPlayback: Bool
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer/Options/EncodingConfiguration``
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
                .Event
                .Name
                .allCases
                .filter { event in
                    // Exclude iFrame related events
                    event != .iFrameApiReady && event != .iFrameApiFailedToLoad
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

public extension YouTubePlayer.Options {
    
    /// A JSON encoded string representation of the ``YouTubePlayer/Options``.
    typealias JSONEncodedString = String
    
    /// Returns a JSON encoded string representation of this instance.
    /// - Parameters:
    ///   - configuration: The encoding configuration.
    ///   - jsonEncoder: The JSON encoder.
    func jsonEncodedString(
        configuration: EncodingConfiguration,
        jsonEncoder: JSONEncoder = {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = [
                .sortedKeys,
                .withoutEscapingSlashes
            ]
            return jsonEncoder
        }()
    ) throws -> JSONEncodedString {
        .init(
            decoding: try self.jsonEncode(
                configuration: configuration,
                jsonEncoder: jsonEncoder
            ),
            as: UTF8.self
        )
    }
    
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
                let options: YouTubePlayer.Options
                
                /// The JavaScript player options encoding configuration.
                let encodingConfiguration: YouTubePlayer.Options.EncodingConfiguration
                
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
