import Foundation

// MARK: - YouTubePlayerAPIError

public extension YouTubePlayer {
    
    /// A YouTubePlayer API Error
    struct APIError: Swift.Error {
        
        // MARK: Properties
        
        /// The JavaScript that has been executed and caused the Error
        public let javaScript: String
        
        /// The optional JavaScript response object
        public let javaScriptResponse: Any?
        
        /// The optional underlying Error
        public let underlyingError: Swift.Error?
        
        /// The optional error reason message
        public let reason: String?
        
        // MARK: Initializer
        
        /// Creates a new instance of `YouTubePlayer.APIError`
        /// - Parameters:
        ///   - javaScript: The JavaScript that has been executed and caused the Error
        ///   - javaScriptResponse: The optional JavaScript response object. Default value `nil`
        ///   - underlyingError: The optional underlying Error. Default value `nil`
        ///   - reason: The optional error reason message. Default value `nil`
        public init(
            javaScript: String,
            javaScriptResponse: Any? = nil,
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
