import Foundation

// MARK: - YouTubePlayerAPIError

public extension YouTubePlayer {
    
    /// A YouTube player API error.
    struct APIError: Swift.Error {
        
        // MARK: Properties
        
        /// The JavaScript code that has been executed and caused the error.
        public let javaScriptCode: YouTubePlayer.JavaScript.Code?
        
        /// The optional JavaScript response.
        public let javaScriptResponse: String?
        
        /// The optional underlying error.
        public let underlyingError: Swift.Error?
        
        /// The optional error reason message.
        public let reason: String?
        
        // MARK: Initializer
        
        /// Creates a new instance of ``YouTubePlayer.APIError``
        /// - Parameters:
        ///   - javaScriptCode: The JavaScript code that has been executed and caused the error. Default value `nil`
        ///   - javaScriptResponse: The optional JavaScript response. Default value `nil`
        ///   - underlyingError: The optional underlying error. Default value `nil`
        ///   - reason: The optional error reason message. Default value `nil`
        public init(
            javaScriptCode: YouTubePlayer.JavaScript.Code? = nil,
            javaScriptResponse: String? = nil,
            underlyingError: Swift.Error? = nil,
            reason: String? = nil
        ) {
            self.javaScriptCode = javaScriptCode
            self.javaScriptResponse = javaScriptResponse
            self.underlyingError = underlyingError
            self.reason = reason
        }
        
    }
    
}
