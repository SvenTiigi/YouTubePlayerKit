import Foundation

// MARK: - YouTubePlayer+JavaScript

public extension YouTubePlayer {
    
    /// A YouTube player JavaScript.
    struct JavaScript: Hashable, Sendable {
        
        // MARK: Typealias
        
        /// The content type.
        public typealias Content = String
        
        // MARK: Properties
        
        /// The content.
        private let content: Content
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer/JavaScript``
        /// - Parameter content: The content.
        public init(
            _ content: Content = .init()
        ) {
            let statementTerminator: Character = ";"
            let content = content
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: .init(charactersIn: .init(statementTerminator)))
                .trimmingCharacters(in: .whitespacesAndNewlines)
            self.content = !content.isEmpty && content.last != statementTerminator ? content + .init(statementTerminator) : content
        }
        
    }
    
}

// MARK: - Variable

public extension YouTubePlayer.JavaScript {
    
    /// A YouTube player JavaScript variable.
    enum Variable: String, Codable, Hashable, Sendable, CaseIterable {
        /// YouTube player
        case youTubePlayer
        
        /// The placeholder raw value.
        public var placeholderRawValue: String {
            "__\(self.rawValue.uppercased())__"
        }
    }

}

// MARK: - Code

public extension YouTubePlayer.JavaScript {
    
    /// Returns the content of this JavaScript by inserting the variable names.
    /// - Parameter variableNames: The variable names.
    func content(
        variableNames: [Variable: String] = .init()
    ) -> Content {
        var content = self.content
        for variable in Variable.allCases {
            content = content.replacingOccurrences(
                of: variable.placeholderRawValue,
                with: variableNames[variable] ?? variable.rawValue
            )
        }
        return content
    }
    
}

// MARK: - Codable

extension YouTubePlayer.JavaScript: Codable {
    
    /// Creates a new instance of ``YouTubePlayer/JavaScript``
    /// - Parameter decoder: The decoder.
    public init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.singleValueContainer()
        self.init(
            try container.decode(String.self)
        )
    }
    
    /// Encode.
    /// - Parameter encoder: The encoder.
    public func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.content)
    }
    
}

// MARK: - ExpressibleByStringLiteral

extension YouTubePlayer.JavaScript: ExpressibleByStringLiteral {
    
    /// Creates a new instance of ``YouTubePlayer/JavaScript``
    /// - Parameter content: The content.
    public init(
        stringLiteral content: Content
    ) {
        self.init(content)
    }
    
}

// MARK: - ExpressibleByStringInterpolation

extension YouTubePlayer.JavaScript: ExpressibleByStringInterpolation {
    
    /// A YouTube player JavaScript string interpolation.
    public struct StringInterpolation: StringInterpolationProtocol {
        
        // MARK: Properties
        
        /// The content.
        fileprivate var content: Content
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer/JavaScript/StringInterpolation``
        /// - Parameters:
        ///   - literalCapacity: The literal capacity.
        ///   - interpolationCount: The interpolation count.
        public init(
            literalCapacity: Int,
            interpolationCount: Int
        ) {
            self.content = .init()
        }
        
        // MARK: StringInterpolationProtocol
        
        /// Appends a literal segment to the interpolation.
        /// - Parameter literal: A string literal containing the characters that appear next in the string literal.
        public mutating func appendLiteral(
            _ literal: String
        ) {
            self.content.append(literal)
        }
        
        /// Append a ``YouTubePlayer/JavaScript/Variable`` to the interpolation.
        /// - Parameter variable: The variable.
        public mutating func appendInterpolation(
            _ variable: Variable
        ) {
            self.content.append(variable.placeholderRawValue)
        }
        
        /// Append a `LosslessStringConvertible` component to the interpolation.
        /// - Parameter component: The component.
        public mutating func appendInterpolation(
            _ component: LosslessStringConvertible
        ) {
            self.content.append(String(component))
        }
        
    }
    
    /// Creates a new instance of ``YouTubePlayer/JavaScript``
    /// - Parameter stringInterpolation: The string interpolation.
    public init(
        stringInterpolation: StringInterpolation
    ) {
        self.init(stringInterpolation.content)
    }
    
}

// MARK: - CustomStringConvertible

extension YouTubePlayer.JavaScript: CustomStringConvertible {
    
    /// A textual representation of this instance.
    public var description: String {
        self.content
    }
    
}

// MARK: - YouTubePlayer

public extension YouTubePlayer.JavaScript {
    
    /// Returns a JavaScript by applying the given operator on the YouTube player JavaScript variable.
    /// - Parameter operator: The operator e.g. function or property.
    static func youTubePlayer(
        operator: String
    ) -> Self {
        "\(.youTubePlayer).\(`operator`);"
    }
    
    /// Returns a JavaScript which invokes the given function with its parameters on the YouTube player JavaScript variable.
    /// - Parameters:
    ///   - functionName: The name of the function to invoke.
    ///   - parameters: The parameters. Default value `.init()`
    static func youTubePlayer(
        functionName: String,
        parameters: [LosslessStringConvertible] = .init()
    ) -> Self {
        self.youTubePlayer(
            operator: [
                functionName,
                "(",
                parameters.map { String($0) }.joined(separator: ", "),
                ")"
            ]
            .joined()
        )
    }
    
    /// Returns a JavaScript which invokes the given function with its encodable parameter on the YouTube player JavaScript variable.
    /// - Parameters:
    ///   - functionName: The name of the function to invoke.
    ///   - jsonParameter: The JSON encodable parameter.
    ///   - jsonEncoder: The JSONEncoder used to encode the parameter.
    static func youTubePlayer(
        functionName: String,
        jsonParameter: Encodable,
        jsonEncoder: JSONEncoder = {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = [
                .sortedKeys,
                .withoutEscapingSlashes
            ]
            return jsonEncoder
        }()
    ) throws -> Self {
        self.youTubePlayer(
            functionName: functionName,
            parameters: [
                String(
                    decoding: try jsonEncoder.encode(jsonParameter),
                    as: UTF8.self
                )
            ]
        )
    }
    
}

// MARK: - Ignore Return Value

public extension YouTubePlayer.JavaScript {
    
    /// Wraps the JavaScript content to explicitly return `null` after execution.
    func ignoreReturnValue() -> Self {
        .init(self.content + " null;")
    }
    
}

// MARK: - Immediately Invoked Function Expression (IIFE)

public extension YouTubePlayer.JavaScript {
    
    /// Wraps the JavaScript content in an immediately invoked function expression (IIFE).
    func asImmediatelyInvokedFunctionExpression() -> Self {
        .init(
            """
            (function() {
                \(self.content)
            })();
            """
        )
    }
    
}
