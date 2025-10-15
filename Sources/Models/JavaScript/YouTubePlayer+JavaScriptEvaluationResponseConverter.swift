import Foundation

// MARK: - YouTubePlayer+JavaScriptEvaluationResponseConverter

public extension YouTubePlayer {
    
    /// A generic JavaScript evaluation response converter
    struct JavaScriptEvaluationResponseConverter<Output>: Sendable {
        
        // MARK: Typealias
        
        /// The JavaScript response.
        public typealias JavaScriptResponse = Any?
        
        /// A closure to convert the response of a JavaScript evaluation to the declared `Response` type.
        public typealias Convert = @Sendable (
            YouTubePlayer.JavaScript.Content,
            JavaScriptResponse
        ) throws(YouTubePlayer.APIError) -> Output
        
        // MARK: Properties
        
        /// A closure to convert the response of a JavaScript evaluation to the declared `Response` type.
        private let convert: Convert
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer/JavaScriptEvaluationResponseConverter``
        /// - Parameter convert: A closure to convert the response of a JavaScript evaluation to the declared `Response` type.
        public init(
            convert: @escaping Convert
        ) {
            self.convert = convert
        }
        
    }
    
}

// MARK: - Call as Function

public extension YouTubePlayer.JavaScriptEvaluationResponseConverter {
    
    /// Converts the response of the given Javascript to the given response type.
    /// - Parameters:
    ///   - javaScript: The JavaScript content.
    ///   - javaScriptResponse: The JavaScript response
    func callAsFunction(
        javaScript: YouTubePlayer.JavaScript.Content,
        javaScriptResponse: JavaScriptResponse
    ) throws(YouTubePlayer.APIError) -> Output {
        try self.convert(
            javaScript,
            javaScriptResponse
        )
    }
    
}

// MARK: - Void

public extension YouTubePlayer.JavaScriptEvaluationResponseConverter where Output == Void {
    
    /// A converter that ignores the JavaScript evaluation response and returns `Void`.
    static let void = Self { _, _ in }
    
}

// MARK: - Type Cast

public extension YouTubePlayer.JavaScriptEvaluationResponseConverter {
    
    /// Type-Cast the JavaScript Response to a new Output type
    /// - Parameters:
    ///   - newOutputType: The NewOutput Type. Default value `.self`
    static func typeCast<NewOutput>(
        to newOutputType: NewOutput.Type = NewOutput.self
    ) -> YouTubePlayer.JavaScriptEvaluationResponseConverter<NewOutput> {
        .init { javaScript, javaScriptResponse throws(YouTubePlayer.APIError) in
            // Verify JavaScript response can be casted to NewOutput type
            guard let output = javaScriptResponse as? NewOutput else {
                // Otherwise throw error
                throw .init(
                    javaScript: javaScript,
                    javaScriptResponse: javaScriptResponse.flatMap(String.init(describing:)),
                    reason: [
                        "Type-Cast failed",
                        "Expected type: \(String(describing: NewOutput.self))",
                        "Found: \(String(describing: javaScriptResponse))"
                    ]
                    .joined(separator: ". ")
                )
            }
            // Return NewOutput
            return output
        }
    }
    
}

// MARK: - Decode

public extension YouTubePlayer.JavaScriptEvaluationResponseConverter {
    
    /// Convert and Decode JavaScript Response to a Decodable type
    /// - Parameters:
    ///   - type: The Decodable Type. Default value `.self`
    ///   - decoder: The JSONDecoder. Default value `.init()`
    func decode<D: Decodable & Sendable>(
        as type: D.Type = D.self,
        decoder: @Sendable @escaping @autoclosure () -> JSONDecoder = .init()
    ) -> YouTubePlayer.JavaScriptEvaluationResponseConverter<D> {
        .init { javaScript, javaScriptResponse throws(YouTubePlayer.APIError) in
            // Convert current Converter
            let output = try self(
                javaScript: javaScript,
                javaScriptResponse: javaScriptResponse
            )
            // Declare output Data
            let outputData: Data
            do {
                // Initialize output Data by trying to retrieve JSON Data
                outputData = try JSONSerialization.data(withJSONObject: output)
            } catch {
                // Throw error
                throw .init(
                    javaScript: javaScript,
                    javaScriptResponse: .init(describing: output),
                    underlyingError: error,
                    reason: "Malformed JSON"
                )
            }
            // Declare Decodable
            let decodable: D
            do {
                // Try to decode output to Decodable type
                decodable = try decoder().decode(
                    D.self,
                    from: outputData
                )
            } catch {
                // Throw error
                throw .init(
                    javaScript: javaScript,
                    javaScriptResponse: .init(describing: output),
                    underlyingError: error,
                    reason: "Decoding failed: \(error)"
                )
            }
            // Return Decodable
            return decodable
        }
    }
    
}
