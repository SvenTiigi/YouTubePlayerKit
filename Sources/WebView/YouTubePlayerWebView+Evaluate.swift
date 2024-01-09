import Foundation

// MARK: - YouTubePlayerWebView+JavaScript

extension YouTubePlayerWebView {
    
    /// A JavaScript
    struct JavaScript: Codable, Hashable {
        
        // MARK: Properties
        
        /// The raw value of the JavaScript
        let rawValue: String
        
        // MARK: Initializer
        
        /// Creates a new instance of `YouTubePlayerWebView.JavaScript`
        /// - Parameter rawValue: The JavaScript
        init(
            _ rawValue: String
        ) {
            self.rawValue = rawValue.last != ";" ? "\(rawValue);" : rawValue
        }
        
    }
    
}

// MARK: - YouTubePlayerWebView+JavaScript+player

extension YouTubePlayerWebView.JavaScript {
   
    /// Bool value if the JavaScript contains a YouTube player usage e.g. function call or property access
    var containsPlayerUsage: Bool {
        self.rawValue.starts(with: YouTubePlayer.HTML.playerVariableName)
    }
    
    /// Create YouTubePlayer JavaScript
    /// - Parameter operator: The operator (function, property)
    static func player(
        _ operator: String
    ) -> Self {
        .init("\(YouTubePlayer.HTML.playerVariableName).\(`operator`)")
    }
    
    /// Create YouTubePlayer JavaScript with function
    /// - Parameters:
    ///   - function: The function name
    ///   - parameters: The parameters.
    static func player(
        function: String,
        parameters: String...
    ) -> Self {
        self.player("\(function)(\(parameters.joined(separator: ", ")))")
    }
    
}

// MARK: - YouTubePlayerWebView+JavaScript+embedInAnonymousFunction

extension YouTubePlayerWebView.JavaScript {
    
    /// Embed JavaScript in an anonymous function
    func embedInAnonymousFunction() -> Self {
        .init("(function(){\(self.rawValue)})()")
    }
    
}

// MARK: - YouTubePlayerWebView+evaluate

extension YouTubePlayerWebView {
    
    /// Evaluates the given JavaScript and converts the JavaScript result
    /// by using the supplied `JavaScriptEvaluationResponseConverter` to the given `Response` type
    /// - Parameters:
    ///   - javaScript: The JavaScript that should be evaluated
    ///   - converter: The JavaScriptEvaluationResponseConverter
    ///   - completion: The completion closure when the JavaScript has finished executing
    func evaluate<Response>(
        javaScript: JavaScript,
        converter: JavaScriptEvaluationResponseConverter<Response>,
        completion: @escaping (Result<Response, YouTubePlayer.APIError>) -> Void
    ) {
        // Initialize evaluate javascript closure
        let evaluateJavaScript = { [weak self] in
            // Evaluate JavaScript
            self?.evaluateJavaScript(
                javaScript.rawValue
            ) { javaScriptResponse, error in
                // Initialize Result
                let result: Result<Response, YouTubePlayer.APIError> = {
                    // Check if an Error is available
                    if let error = error {
                        // Return failure with YouTubePlayerAPIError
                        return .failure(
                            .init(
                                javaScript: javaScript.rawValue,
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
        // Initialize execute javascript closure
        let executeJavaScript = {
            // Check if is main thread
            if Thread.isMainThread {
                // Evaluate javascript
                evaluateJavaScript()
            } else {
                // Dispatch on main queue
                DispatchQueue.main.async {
                    // Evaluate javascript
                    evaluateJavaScript()
                }
            }
        }
        // Check if JavaScript contains player usage
        if javaScript.containsPlayerUsage {
            // Switch on player state
            switch self.player?.state {
            case nil, .idle:
                // Verify a player is available
                guard let player = self.player else {
                    // Otherwise return out of function and complete with failure
                    return completion(
                        .failure(
                            .init(
                                javaScript: javaScript.rawValue,
                                reason: "YouTubePlayer has been deallocated"
                            )
                        )
                    )
                }
                // Subscribe to state publisher
                let cancellable = player
                    .statePublisher
                    // Only include non idle states
                    .filter { $0.isIdle == false }
                    // Receive the first state
                    .first()
                    .sink { _ in
                        // Execute the JavaScript
                        executeJavaScript()
                    }
                // Dispatch on main queue
                DispatchQueue.main.async { [weak self] in
                    // Retain cancellable
                    self?.cancellables.insert(cancellable)
                }
            case .ready, .error:
                // Synchronously execute the JavaScript
                executeJavaScript()
            }
        } else {
            // Otherwise synchronously execute the JavaScript
            executeJavaScript()
        }
    }
    
    /// Evaluates the given JavaScript
    /// - Parameter javaScript: The JavaScript that should be evaluated
    func evaluate(
        javaScript: JavaScript
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
        
        /// The JavaScript Response typealias
        typealias JavaScriptResponse = Any?
        
        /// The Convert closure typealias
        typealias Convert = (JavaScript, JavaScriptResponse) -> Result<Output, YouTubePlayer.APIError>
        
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
        ) -> Result<Output, YouTubePlayer.APIError> {
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
                        javaScript: javaScript.rawValue,
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
                                javaScript: javaScript.rawValue,
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
                                javaScript: javaScript.rawValue,
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
                                javaScript: javaScript.rawValue,
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
