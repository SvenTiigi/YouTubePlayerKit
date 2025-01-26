import Foundation

// MARK: - YouTubePlayerWebView+JavaScriptEvaluationResponseConverter

extension YouTubePlayerWebView {
    
    /// A generic JavaScript evaluation response converter
    struct JavaScriptEvaluationResponseConverter<Output> {
        
        // MARK: Typealias
        
        /// The JavaScript Response typealias
        typealias JavaScriptResponse = Any?
        
        /// The Convert closure typealias
        typealias Convert = (JavaScript, JavaScriptResponse) throws(YouTubePlayer.APIError) -> Output
        
        // MARK: Properties
        
        /// The Convert closure
        private let convert: Convert
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayerWebView.JavaScriptEvaluationResponseConverter``
        /// - Parameter convert: The Convert closure
        init(
            convert: @escaping Convert
        ) {
            self.convert = convert
        }
        
        // MARK: Call-As-Function
        
        /// Call `JavaScriptEvaluationResponseConverter` as function
        /// - Parameters:
        ///   - javaScript: The JavaScript string
        ///   - javaScriptResponse: The JavaScriptResponse
        /// - Returns: A Result containing the Output or a YouTubePlayerAPIError
        func callAsFunction(
            javaScript: JavaScript,
            javaScriptResponse: JavaScriptResponse
        ) throws(YouTubePlayer.APIError) -> Output {
            try self.convert(
                javaScript,
                javaScriptResponse
            )
        }
        
    }
    
}

// MARK: - Type Cast

extension YouTubePlayerWebView.JavaScriptEvaluationResponseConverter {
    
    /// Type-Cast the JavaScript Response to a new Output type
    /// - Parameters:
    ///   - newOutputType: The NewOutput Type. Default value `.self`
    static func typeCast<NewOutput>(
        to newOutputType: NewOutput.Type = NewOutput.self
    ) -> YouTubePlayerWebView.JavaScriptEvaluationResponseConverter<NewOutput> {
        .init { javaScript, javaScriptResponse throws(YouTubePlayer.APIError) in
            // Verify JavaScript response can be casted to NewOutput type
            guard let output = javaScriptResponse as? NewOutput else {
                // Otherwise throw error
                throw .init(
                    javaScript: javaScript.code,
                    javaScriptResponse: javaScriptResponse.flatMap(String.init(describing:)),
                    reason: [
                        "Type-Cast failed",
                        "Expected type: \(String(describing: NewOutput.self))",
                        "But found: \(String(describing: javaScriptResponse))"
                    ]
                    .joined(separator: ". ")
                )
            }
            // Return NewOutput
            return output
        }
    }
    
}

// MARK: - Map

extension YouTubePlayerWebView.JavaScriptEvaluationResponseConverter {
    
    /// Transforms the output of the current JavaScript evaluation response converter to a new type using the provided transformation closure.
    /// - Parameter transform: A closure that takes the current converter's output type and returns a new output type.
    func map<NewOutput>(
        _ transform: @escaping (Output) throws -> NewOutput
    ) -> YouTubePlayerWebView.JavaScriptEvaluationResponseConverter<NewOutput> {
        .init { javaScript, javaScriptResponse throws(YouTubePlayer.APIError) in
            // Convert current Converter
            let output = try self(
                javaScript: javaScript,
                javaScriptResponse: javaScriptResponse
            )
            do {
                // Return transformed output
                return try transform(output)
            } catch {
                // Throw error
                throw .init(
                    javaScript: javaScript.code,
                    javaScriptResponse: .init(describing: output),
                    reason: "Failed to transform output \(String(reflecting: Output.self)) to \(String(reflecting: NewOutput.self))"
                )
            }
        }
    }
    
}

// MARK: - Decode

extension YouTubePlayerWebView.JavaScriptEvaluationResponseConverter where Output == [String: Any] {
    
    /// Convert and Decode JavaScript Response to a Decodable type
    /// - Parameters:
    ///   - type: The Decodable Type. Default value `.self`
    ///   - decoder: The JSONDecoder. Default value `.init()`
    func decode<D: Decodable>(
        as type: D.Type = D.self,
        decoder: @autoclosure @escaping () -> JSONDecoder = .init()
    ) -> YouTubePlayerWebView.JavaScriptEvaluationResponseConverter<D> {
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
                    javaScript: javaScript.code,
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
                    javaScript: javaScript.code,
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
