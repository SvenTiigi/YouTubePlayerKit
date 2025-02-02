import Foundation
import struct WebKit.WKError

// MARK: - YouTubePlayerAPIError

public extension YouTubePlayer {
    
    /// A YouTube player API error.
    struct APIError: Swift.Error {
        
        // MARK: Properties
        
        /// The JavaScript that has been executed and caused the error.
        public let javaScript: YouTubePlayer.JavaScript.Content?
        
        /// The optional JavaScript response.
        public let javaScriptResponse: String?
        
        /// The optional underlying error.
        public let underlyingError: Swift.Error?
        
        /// The optional error reason message.
        public let reason: String?
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer/APIError``
        /// - Parameters:
        ///   - javaScript: The JavaScript that has been executed and caused the error. Default value `nil`
        ///   - javaScriptResponse: The optional JavaScript response. Default value `nil`
        ///   - underlyingError: The optional underlying error. Default value `nil`
        ///   - reason: The optional error reason message. Default value `nil`
        public init(
            javaScript: YouTubePlayer.JavaScript.Content? = nil,
            javaScriptResponse: String? = nil,
            underlyingError: Swift.Error? = nil,
            reason: String? = nil
        ) {
            self.javaScript = javaScript
            self.javaScriptResponse = javaScriptResponse
            self.underlyingError = underlyingError
            self.reason = reason
        }
        
    }
    
}

// MARK: - WebKit Error

public extension YouTubePlayer.APIError {
    
    /// The web kit error code of the underlying error, if available.
    var webKitErrorCode: WKError.Code? {
        (self.underlyingError as? WKError)?.code
    }
    
}

// MARK: - CustomStringConvertible

extension YouTubePlayer.APIError: CustomStringConvertible {
    
    /// A textual representation of this instance.
    public var description: String {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [
            .sortedKeys,
            .withoutEscapingSlashes,
            .prettyPrinted
        ]
        guard let jsonData = try? jsonEncoder.encode(self) else {
            return """
            YouTubePlayer API Error:
            JavaScript: \(self.javaScript ?? .init())
            JavaScript Response: \(self.javaScriptResponse ?? .init())
            Underyling Error: \(self.underlyingError.flatMap(String.init(describing:)) ?? .init())
            Reason: \(self.reason ?? .init())
            WebKit Error Code: \(self.webKitErrorCode.flatMap { String($0.rawValue) } ?? .init())
            """
        }
        return .init(
            decoding: jsonData,
            as: UTF8.self
        )
    }
    
}

// MARK: - Encodable

extension YouTubePlayer.APIError: Encodable {
    
    /// The CodingKeys.
    private enum CodingKeys: CodingKey {
        case javaScript
        case javaScriptResponse
        case underlyingError
        case reason
        case webKitErrorCode
    }
    
    /// Encode.
    /// - Parameter encoder: The encoder.
    public func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.javaScript, forKey: .javaScript)
        try container.encode(self.javaScriptResponse, forKey: .javaScriptResponse)
        try container.encode(self.underlyingError.flatMap(String.init(describing:)), forKey: .underlyingError)
        try container.encode(self.reason, forKey: .reason)
        try container.encodeIfPresent(self.webKitErrorCode?.rawValue, forKey: .webKitErrorCode)
    }
    
}
