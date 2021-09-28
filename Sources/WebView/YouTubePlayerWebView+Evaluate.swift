import Foundation

// MARK: - YouTubePlayerWebView+evaluate

extension YouTubePlayerWebView {
    
    /// Evaluates the given JavaScript and converts the JavaScript result
    /// by using the supplied `JavaScriptEvaluationResponseConverter` to the given `Response` type
    /// - Parameters:
    ///   - javaScript: The JavaScript that should be evaluated
    ///   - converter: The JavaScriptEvaluationResponseConverter
    ///   - completion: The completion closure when the JavaScript has finished executing
    func evaluate<Response>(
        javaScript: String,
        converter: JavaScriptEvaluationResponseConverter<Response>,
        completion: @escaping (Result<Response, YouTubePlayerAPIError>) -> Void
    ) {
        // Evaluate JavaScript
        self.evaluateJavaScript(
            javaScript
        ) { javaScriptResponse, error in
            // Initialize Result
            let result: Result<Response, YouTubePlayerAPIError> = {
                // Check if an Error is available
                if let error = error {
                    // Return failure with YouTubePlayerAPIError
                    return .failure(
                        .init(
                            javaScript: javaScript,
                            javaScriptResponse: javaScriptResponse,
                            underlyingError: error,
                            reason: (error as NSError)
                                .userInfo["WKJavaScriptExceptionMessage"] as? String
                        )
                    )
                } else {
                    // Execute Converter and retrieve Result
                    return converter(
                        javaScript,
                        javaScriptResponse
                    )
                }
            }()
            // Invoke completion with Result
            completion(result)
        }
    }
    
    /// Evaluates the given JavaScript
    /// - Parameter javaScript: The JavaScript that should be evaluated
    func evaluate(
        javaScript: String
    ) {
        // Evaluate JavaScript with `empty` Converter
        self.evaluate(
            javaScript: javaScript,
            converter: .empty,
            completion: { _ in }
        )
    }
    
}

// MARK: - YouTubePlayerWebView+JavaScriptEvaluationResponseConverter

extension YouTubePlayerWebView {
    
    /// A generic JavaScript evaluation response converter
    struct JavaScriptEvaluationResponseConverter<Output> {
        
        // MARK: Typealias
        
        /// The JavaScript typealias
        typealias JavaScript = String
        
        /// The JavaScript Response typealias
        typealias JavaScriptResponse = Any?
        
        /// The Convert closure typealias
        typealias Convert = (JavaScript, JavaScriptResponse) -> Result<Output, YouTubePlayerAPIError>
        
        // MARK: Properties
        
        /// The Convert closure
        private let convert: Convert
        
        // MARK: Initializer
        
        /// Creates a new instance of `JavaScriptEvaluationResponseConverter`
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
            _ javaScript: JavaScript,
            _ javaScriptResponse: JavaScriptResponse
        ) -> Result<Output, YouTubePlayerAPIError> {
            self.convert(
                javaScript,
                javaScriptResponse
            )
        }
        
    }
    
}

// MARK: - JavaScriptEvaluationResponseConverter+Empty

extension YouTubePlayerWebView.JavaScriptEvaluationResponseConverter where Output == Void {
    
    /// An empty JavaScriptEvaluationResponseConverter
    static let empty = Self { _, _ in .success(())  }
    
}

// MARK: - JavaScriptEvaluationResponseConverter+typeCast

extension YouTubePlayerWebView.JavaScriptEvaluationResponseConverter {
    
    /// Type-Cast the JavaScript Response to a new Output type
    /// - Parameters:
    ///   - newOutputType: The NewOutput Type. Default value `.self`
    static func typeCast<NewOutput>(
        to newOutputType: NewOutput.Type = NewOutput.self
    ) -> YouTubePlayerWebView.JavaScriptEvaluationResponseConverter<NewOutput> {
        .init { javaScript, javaScriptResponse in
            // Verify JavaScript response can be casted to NewOutput type
            guard let output = javaScriptResponse as? NewOutput else {
                // Otherwise return failure
                return .failure(
                    .init(
                        javaScript: javaScript,
                        javaScriptResponse: javaScriptResponse,
                        reason: [
                            "Type-Cast failed",
                            "Expected type: \(String(describing: NewOutput.self))",
                            "But found: \(String(describing: javaScriptResponse))"
                        ]
                        .joined(separator: ". ")
                    )
                )
            }
            // Return NewOutput
            return .success(output)
        }
    }
    
}

// MARK: - JavaScriptEvaluationResponseConverter+rawRepresentable

extension YouTubePlayerWebView.JavaScriptEvaluationResponseConverter {
    
    /// Convert JavaScript Response to a RawRepresentable type
    /// - Parameters:
    ///   - type: The Representable Type. Default value `.self`
    func rawRepresentable<Representable: RawRepresentable>(
        type: Representable.Type = Representable.self
    ) -> YouTubePlayerWebView.JavaScriptEvaluationResponseConverter<Representable>
    where Output == Representable.RawValue {
        .init { javaScript, javaScriptResponse in
            // Convert current Converter
            self(javaScript, javaScriptResponse)
                // FlatMap Result
                .flatMap { output in
                    // Verify Representable can be initialized from output value
                    guard let representable = Representable(rawValue: output) else {
                        // Otherwise return failure
                        return .failure(
                            .init(
                                javaScript: javaScript,
                                javaScriptResponse: output,
                                reason: [
                                    "Unknown",
                                    String(describing: Representable.self),
                                    "RawRepresentable-RawValue:",
                                    "\(output)"
                                ]
                                .joined(separator: " ")
                            )
                        )
                    }
                    // Return Representable
                    return .success(representable)
                }
        }
    }
    
}

// MARK: - JavaScriptEvaluationResponseConverter+decode

extension YouTubePlayerWebView.JavaScriptEvaluationResponseConverter where Output == [String: Any] {
    
    /// Convert and Decode JavaScript Response to a Decodable type
    /// - Parameters:
    ///   - type: The Decodable Type. Default value `.self`
    ///   - decoder: The JSONDecoder. Default value `.init()`
    func decode<D: Decodable>(
        as type: D.Type = D.self,
        decoder: @autoclosure @escaping () -> JSONDecoder = .init()
    ) -> YouTubePlayerWebView.JavaScriptEvaluationResponseConverter<D> {
        .init { javaScript, javaScriptResponse in
            // Convert current Converter
            self(javaScript, javaScriptResponse)
                // FlatMap Result
                .flatMap { output in
                    // Declare output Data
                    let outputData: Data
                    do {
                        // Initialize output Data by trying to retrieve JSON Data
                        outputData = try output.jsonData()
                    } catch {
                        // Return failure
                        return .failure(
                            .init(
                                javaScript: javaScript,
                                javaScriptResponse: output,
                                underlyingError: error,
                                reason: "Malformed JSON"
                            )
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
                        // Return failure
                        return .failure(
                            .init(
                                javaScript: javaScript,
                                javaScriptResponse: output,
                                underlyingError: error,
                                reason: "Decoding failed: \(error)"
                            )
                        )
                    }
                    // Return Decodable
                    return .success(decodable)
                }
        }
    }
    
}
