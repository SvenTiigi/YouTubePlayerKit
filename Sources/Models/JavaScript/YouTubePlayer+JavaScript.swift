import Foundation

// MARK: - YouTubePlayer+JavaScript

public extension YouTubePlayer {
    
    /// A YouTube player JavaScript.
    struct JavaScript: Codable, Hashable, Sendable {
        
        // MARK: Typealias
        
        /// A YouTube player JavaScript code type.
        public typealias Code = String
        
        // MARK: Properties
        
        /// The code.
        private let code: Code
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer.JavaScript``
        /// - Parameter code: The code.
        public init(
            _ code: Code = .init()
        ) {
            let statementTerminator: Character = ";"
            let code = code
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: .init(charactersIn: .init(statementTerminator)))
                .trimmingCharacters(in: .whitespacesAndNewlines)
            self.code = !code.isEmpty && code.last != statementTerminator ? code + .init(statementTerminator) : code
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
    
    /// Returns the code of this JavaScript by inserting the variable names.
    /// - Parameter variableNames: The variable names.
    func code(
        variableNames: [Variable: String] = .init()
    ) -> Code {
        var code = self.code
        for variable in Variable.allCases {
            code = code.replacingOccurrences(
                of: variable.placeholderRawValue,
                with: variableNames[variable] ?? variable.rawValue
            )
        }
        return code
    }
    
}

// MARK: - ExpressibleByStringLiteral

extension YouTubePlayer.JavaScript: ExpressibleByStringLiteral {
    
    /// Creates a new instance of ``YouTubePlayer.JavaScript``
    /// - Parameter code: The code.
    public init(
        stringLiteral code: String
    ) {
        self.init(code)
    }
    
}

// MARK: - ExpressibleByStringInterpolation

extension YouTubePlayer.JavaScript: ExpressibleByStringInterpolation {
    
    /// A YouTube player JavaScript string interpolation.
    public struct StringInterpolation: StringInterpolationProtocol {
        
        // MARK: Properties
        
        /// The code.
        fileprivate var code: String
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer.JavaScript.StringInterpolation``
        /// - Parameters:
        ///   - literalCapacity: The literal capacity.
        ///   - interpolationCount: The interpolation count.
        public init(
            literalCapacity: Int,
            interpolationCount: Int
        ) {
            self.code = .init()
        }
        
        // MARK: StringInterpolationProtocol
        
        /// Appends a literal segment to the interpolation.
        /// - Parameter literal: A string literal containing the characters that appear next in the string literal.
        public mutating func appendLiteral(
            _ literal: String
        ) {
            self.code.append(literal)
        }
        
        /// Append a ``YouTubePlayer.JavaScript.Variable`` to the interpolation.
        /// - Parameter variable: The variable.
        public mutating func appendInterpolation(
            _ variable: Variable
        ) {
            self.code.append(variable.placeholderRawValue)
        }
        
        /// Append a ``LosslessStringConvertible`` component to the interpolation.
        /// - Parameter component: The component.
        public mutating func appendInterpolation(
            _ component: LosslessStringConvertible
        ) {
            self.code.append(String(component))
        }
        
    }
    
    /// Creates a new instance of ``YouTubePlayer.JavaScript``
    /// - Parameter stringInterpolation: The string interpolation.
    public init(
        stringInterpolation: StringInterpolation
    ) {
        self.init(stringInterpolation.code)
    }
    
}

// MARK: - CustomStringConvertible

extension YouTubePlayer.JavaScript: CustomStringConvertible {
    
    /// A textual representation of this instance.
    public var description: String {
        self.code
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
    ///   - parameter: The JSON encodable parameter.
    ///   - parameterJSONEncoder: The JSONEncoder used to encode the parameter.
    static func youTubePlayer(
        functionName: String,
        parameter: Encodable,
        parameterJSONEncoder: JSONEncoder = {
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
                    decoding: try parameterJSONEncoder.encode(parameter),
                    as: UTF8.self
                )
            ]
        )
    }
    
}

// MARK: - Ignore Return Value

public extension YouTubePlayer.JavaScript {
    
    /// Wraps the JavaScript code to explicitly return `null` after execution.
    func ignoreReturnValue() -> Self {
        .init(self.code + " null;")
    }
    
}

// MARK: - Immediately Invoked Function Expression (IIFE)

public extension YouTubePlayer.JavaScript {
    
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
