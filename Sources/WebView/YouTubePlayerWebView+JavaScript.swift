import Foundation

// MARK: - YouTubePlayerWebView+JavaScript

extension YouTubePlayerWebView {
    
    /// A JavaScript.
    struct JavaScript: Codable, Hashable, Sendable {
        
        // MARK: Properties
        
        /// The JavaScript code.
        let code: String
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayerWebView.JavaScript``
        /// - Parameter code: The JavaScript code.
        init(
            _ code: String
        ) {
            self.code = code.last != ";" ? "\(code);" : code
        }
        
    }
    
}

// MARK: - CustomStringConvertible

extension YouTubePlayerWebView.JavaScript: CustomStringConvertible {
    
    /// A textual representation of this instance.
    var description: String {
        self.code
    }
    
}

// MARK: - Player

extension YouTubePlayerWebView.JavaScript {
    
    /// Returns a new JavaScript instance by invoking the provided closure with the name of the YouTube player JavaScript variable.
    /// - Parameter code: A closure providing the JavaScript code by using the provided YouTube player JavaScript variable.
    static func player(
        _ code: (String) -> String
    ) -> Self {
        .init(
            code(YouTubePlayerWebView.HTML.javaScriptPlayerVariableName)
        )
    }
    
    /// Returns a new JavaScript by applying the given operator on the YouTube player JavaScript variable.
    /// - Parameter operator: The operator (function, property)
    static func player(
        _ operator: String
    ) -> Self {
        .player { playerVariableName in
            [
                playerVariableName,
                `operator`
            ]
            .joined(separator: ".")
        }
    }
    
    /// Returns a new JavaScript with the provided function and parameters.
    /// - Parameters:
    ///   - function: The function name
    ///   - parameters: The parameters.
    static func player(
        function: String,
        parameters: [LosslessStringConvertible] = .init()
    ) -> Self {
        self.player(
            [
                function,
                "(",
                parameters.map { String($0) }.joined(separator: ", "),
                ")"
            ]
            .joined()
        )
    }
    
    /// Returns a new JavaScript with the provided function and JSON encoded parameter.
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
                    .code,
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

// MARK: - Ignore Return Value

extension YouTubePlayerWebView.JavaScript {
    
    /// Wraps the JavaScript code to explicitly return `null` after execution.
    func ignoreReturnValue() -> Self {
        .init(self.code + " null;")
    }
    
}

// MARK: - Immediately Invoked Function Expression (IIFE)

extension YouTubePlayerWebView.JavaScript {
    
    /// Wraps the JavaScript code in an immediately invoked function expression (IIFE).
    func asImmediatelyInvokedFunctionExpression() -> Self {
        .init(
            """
            (function() {
                \(self.code)
            })();
            """
        )
    }
    
}
