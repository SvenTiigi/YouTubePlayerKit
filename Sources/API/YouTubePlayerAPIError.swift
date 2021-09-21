import Foundation

// MARK: - YouTubePlayerAPIError

/// A YouTubePlayerAPI Error
public struct YouTubePlayerAPIError: Error {
    
    // MARK: Properties
    
    /// The JavaScript that has been executed and caused the Error
    public let javaScript: String
    
    /// The optional JavaScript response object
    public let javaScriptResponse: Any?
    
    /// The optional underlying Error
    public let underlyingError: Error?
    
    /// The optional error reason message
    public let reason: String?
    
    // MARK: Initializer
    
    /// Creates a new instance of `YouTubePlayerAPIError`
    /// - Parameters:
    ///   - javaScript: The JavaScript that has been executed and caused the Error
    ///   - javaScriptResponse: The optional JavaScript response object. Default value `nil`
    ///   - underlyingError: The optional underlying Error. Default value `nil`
    ///   - reason: The optional error reason message. Default value `nil`
    public init(
        javaScript: String,
        javaScriptResponse: Any? = nil,
        underlyingError: Error? = nil,
        reason: String? = nil
    ) {
        self.javaScript = javaScript
        self.javaScriptResponse = javaScriptResponse
        self.underlyingError = underlyingError
        self.reason = reason
    }
    
}
