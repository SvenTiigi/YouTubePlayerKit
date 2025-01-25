import Foundation

// MARK: - YouTubePlayerWebView+JavaScript

extension YouTubePlayerWebView {
    
    /// A JavaScript.
    struct JavaScript: Codable, Hashable, Sendable {
        
        // MARK: Properties
        
        /// The raw value of the JavaScript
        let rawValue: String
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayerWebView.JavaScript``
        /// - Parameter rawValue: The JavaScript
        init(
            _ rawValue: String
        ) {
            self.rawValue = rawValue.last != ";" ? "\(rawValue);" : rawValue
        }
        
    }
    
}

// MARK: - CustomStringConvertible

extension YouTubePlayerWebView.JavaScript: CustomStringConvertible {
    
    /// A textual representation of this instance.
    var description: String {
        self.rawValue
    }
    
}

// MARK: - YouTubePlayerWebView+JavaScript+player

extension YouTubePlayerWebView.JavaScript {
   
    /// Bool value if the JavaScript contains a YouTube player usage e.g. function call or property access
    var containsPlayerUsage: Bool {
        self.rawValue.starts(with: YouTubePlayerWebView.HTML.javaScriptPlayerVariableName)
    }
    
    /// Creates a YouTube player JavaScript
    /// - Parameter operator: The operator (function, property)
    static func player(
        _ operator: String
    ) -> Self {
        .init("\(YouTubePlayerWebView.HTML.javaScriptPlayerVariableName).\(`operator`)")
    }
    
    /// Creates a YouTube player JavaScript with function
    /// - Parameters:
    ///   - function: The function name
    ///   - parameters: The parameters.
    static func player(
        function: String,
        parameters: [LosslessStringConvertible] = .init()
    ) -> Self {
        self.player("\(function)(\(parameters.map { String($0) }.joined(separator: ", ")))")
    }
    
    /// Creates a YouTube player JavaScript with function
    /// - Parameters:
    ///   - function: The function name
    ///   - parameter: The encodable parameter.
    ///   - encoder: The JSON encoder. Default value `.init()`
    static func player(
        function: String,
        parameter: Encodable,
        encoder: JSONEncoder = .init()
    ) throws(YouTubePlayer.APIError) -> Self {
        let encodedParameter: Data
        do {
            encodedParameter = try encoder.encode(parameter)
        } catch {
            throw .init(
                javaScript: YouTubePlayerWebView
                    .JavaScript
                    .player(function: function)
                    .rawValue,
                javaScriptResponse: nil,
                underlyingError: error,
                reason: "Failed to encode parameter"
            )
        }
        return self.player(
            function: function,
            parameters: [
                String(
                    decoding: encodedParameter,
                    as: UTF8.self
                )
            ]
        )
    }
    
}

// MARK: - YouTubePlayerWebView+JavaScript+ignoreReturnValue

extension YouTubePlayerWebView.JavaScript {
    
    /// Wraps the JavaScript to ignore the return value.
    func ignoreReturnValue() -> Self {
        .init(self.rawValue + " null;")
    }
    
}
